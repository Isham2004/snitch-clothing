import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_profile.dart';

class ProfileService {
  ProfileService._();
  static final ProfileService instance = ProfileService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  DocumentReference<Map<String, dynamic>> _userDoc(String uid) =>
      _firestore.collection('users').doc(uid);

  CollectionReference<Map<String, dynamic>> _addresses(String uid) =>
      _userDoc(uid).collection('addresses');

  Future<UserProfile?> getProfile(String uid) async {
    final snap = await _userDoc(uid).get();
    if (!snap.exists || snap.data() == null) return null;
    return UserProfile.fromMap(uid, snap.data()!);
  }

  Future<void> updateProfile(String uid, UserProfile profile) async {
    await _userDoc(uid).set({
      ...profile.toMap(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> updateAvatar(String uid, String avatarUrl) async {
    await _userDoc(uid).set({
      'avatarUrl': avatarUrl,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<List<DeliveryAddress>> getAddresses(String uid) async {
    final snap = await _addresses(uid).get();
    return snap.docs
        .map((d) => DeliveryAddress.fromMap(d.id, d.data()))
        .toList();
  }

  Stream<List<DeliveryAddress>> watchAddresses(String uid) {
    return _addresses(uid).snapshots().map(
          (s) => s.docs
              .map((d) => DeliveryAddress.fromMap(d.id, d.data()))
              .toList(),
        );
  }

  Future<String> addAddress(String uid, DeliveryAddress address) async {
    if (address.isDefault) await _clearDefaults(uid);
    final ref = await _addresses(uid).add(address.toMap());
    return ref.id;
  }

  Future<void> updateAddress(String uid, DeliveryAddress address) async {
    if (address.isDefault) await _clearDefaults(uid, exceptId: address.id);
    await _addresses(uid).doc(address.id).set(address.toMap());
  }

  Future<void> deleteAddress(String uid, String id) async {
    await _addresses(uid).doc(id).delete();
  }

  Future<void> _clearDefaults(String uid, {String? exceptId}) async {
    final snap = await _addresses(uid).where('isDefault', isEqualTo: true).get();
    final batch = _firestore.batch();
    for (final d in snap.docs) {
      if (d.id == exceptId) continue;
      batch.update(d.reference, {'isDefault': false});
    }
    await batch.commit();
  }
}
