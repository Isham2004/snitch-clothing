import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/cart_item.dart';

class CartService {
  CartService._();
  static final CartService instance = CartService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  DocumentReference<Map<String, dynamic>> _cartDoc(String uid) =>
      _firestore.collection('carts').doc(uid);

  CollectionReference<Map<String, dynamic>> _itemsCol(String uid) =>
      _cartDoc(uid).collection('items');

  Future<List<CartItem>> getItems(String uid) async {
    final snap = await _itemsCol(uid).get();
    return snap.docs.map((d) => CartItem.fromMap(d.data())).toList();
  }

  Stream<List<CartItem>> watchItems(String uid) {
    return _itemsCol(uid).snapshots().map(
          (s) => s.docs.map((d) => CartItem.fromMap(d.data())).toList(),
        );
  }

  Future<void> setItem(String uid, CartItem item) async {
    await _itemsCol(uid).doc(item.key).set(item.toMap());
    await _touchCart(uid);
  }

  Future<void> removeItem(String uid, String key) async {
    await _itemsCol(uid).doc(key).delete();
    await _touchCart(uid);
  }

  Future<void> clear(String uid) async {
    final batch = _firestore.batch();
    final snap = await _itemsCol(uid).get();
    for (final d in snap.docs) {
      batch.delete(d.reference);
    }
    await batch.commit();
    await _touchCart(uid);
  }

  Future<void> replaceAll(String uid, List<CartItem> items) async {
    final batch = _firestore.batch();
    final existing = await _itemsCol(uid).get();
    for (final d in existing.docs) {
      batch.delete(d.reference);
    }
    for (final item in items) {
      batch.set(_itemsCol(uid).doc(item.key), item.toMap());
    }
    batch.set(_cartDoc(uid), {
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    await batch.commit();
  }

  Future<void> _touchCart(String uid) async {
    await _cartDoc(uid).set({
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
