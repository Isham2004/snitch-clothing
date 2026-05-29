import 'dart:async';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/order_model.dart';
import '../models/user_profile.dart';
import '../services/auth_service.dart';
import '../services/order_service.dart';
import '../services/profile_service.dart';
import '../services/storage_service.dart';

class UserProvider extends ChangeNotifier {
  final AuthService _auth = AuthService.instance;
  final ProfileService _profileService = ProfileService.instance;
  final OrderService _orderService = OrderService.instance;
  final StorageService _storage = StorageService.instance;

  UserProfile? _profile;
  final List<OrderModel> _orders = [];
  final List<DeliveryAddress> _addresses = [];

  bool _initialized = false;
  bool _busy = false;
  String? _firestoreWarning;

  StreamSubscription<User?>? _authSub;
  StreamSubscription? _ordersSub;
  StreamSubscription? _addressSub;

  UserProvider() {
    _authSub = _auth.authStateChanges().listen(_onAuthState);
  }

  bool get isLoggedIn => _profile != null;
  bool get initialized => _initialized;
  bool get isBusy => _busy;
  String? get firestoreWarning => _firestoreWarning;
  UserProfile get profile =>
      _profile ??
      UserProfile(
        id: 'guest',
        name: 'Guest',
        email: '',
        phone: '',
        address: '',
        avatarUrl: '',
      );
  List<OrderModel> get orders => List.unmodifiable(_orders);
  List<DeliveryAddress> get addresses => List.unmodifiable(_addresses);

  Future<void> _onAuthState(User? user) async {
    if (user == null) {
      _profile = null;
      _orders.clear();
      _addresses.clear();
      await _ordersSub?.cancel();
      _ordersSub = null;
      await _addressSub?.cancel();
      _addressSub = null;
    } else {
      _profile = UserProfile(
        id: user.uid,
        name: user.displayName?.isNotEmpty == true
            ? user.displayName!
            : (user.email?.split('@').first ?? 'User'),
        email: user.email ?? '',
        phone: user.phoneNumber ?? '',
        address: '',
        avatarUrl: user.photoURL ?? '',
      );
      _initialized = true;
      notifyListeners();

      try {
        final fromFirestore = await _profileService.getProfile(user.uid);
        if (fromFirestore != null) {
          _profile = fromFirestore;
          _firestoreWarning = null;
        } else {
          try {
            await _profileService.updateProfile(user.uid, _profile!);
          } catch (e) {
            debugPrint('[UserProvider] Could not write profile: $e');
          }
        }
      } catch (e) {
        debugPrint('[UserProvider] getProfile failed: $e');
        _firestoreWarning =
            'Firestore connection issue — profile changes may not save.';
      }

      _attachStreams(user.uid);
    }
    _initialized = true;
    notifyListeners();
  }

  void _attachStreams(String uid) {
    _ordersSub?.cancel();
    _addressSub?.cancel();
    _ordersSub = _orderService.watchOrders(uid).listen((orders) {
      _orders
        ..clear()
        ..addAll(orders);
      notifyListeners();
    }, onError: (e) {
      debugPrint('[UserProvider] Orders stream error: $e');
    });
    _addressSub = _profileService.watchAddresses(uid).listen((items) {
      _addresses
        ..clear()
        ..addAll(items);
      notifyListeners();
    }, onError: (e) {
      debugPrint('[UserProvider] Addresses stream error: $e');
    });
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    _busy = true;
    notifyListeners();
    try {
      _profile = await _auth.signUp(
        name: name,
        email: email,
        password: password,
      );
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    _busy = true;
    notifyListeners();
    try {
      _profile = await _auth.signIn(email: email, password: password);
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  Future<void> sendPasswordReset(String email) async {
    await _auth.sendPasswordReset(email);
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await _auth.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
  }

  Future<void> updateProfile({
    String? name,
    String? phone,
    String? address,
  }) async {
    final current = _profile;
    if (current == null) return;
    final updated = current.copyWith(
      name: name?.trim(),
      phone: phone?.trim(),
      address: address?.trim(),
    );
    _profile = updated;
    notifyListeners();
    try {
      await _profileService.updateProfile(current.id, updated);
      _firestoreWarning = null;
    } catch (e) {
      debugPrint('[UserProvider] updateProfile failed: $e');
      _firestoreWarning =
          'Could not save changes to Firestore. Set up Firestore in Firebase Console.';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateAvatar(File file) async {
    final current = _profile;
    if (current == null) return;
    final url = await _storage.uploadAvatar(current.id, file);
    try {
      await _profileService.updateAvatar(current.id, url);
    } catch (e) {
      debugPrint('[UserProvider] updateAvatar firestore write failed: $e');
    }
    _profile = current.copyWith(avatarUrl: url);
    notifyListeners();
  }

  Future<OrderModel> placeOrder({
    required List items,
    required double subtotal,
    required double shipping,
    required double total,
    required String address,
    required String paymentMethod,
  }) async {
    final current = _profile;
    if (current == null) {
      throw Exception('You must be signed in to place an order.');
    }
    final order = await _orderService.placeOrder(
      uid: current.id,
      items: List.from(items),
      subtotal: subtotal,
      shipping: shipping,
      total: total,
      address: address,
      paymentMethod: paymentMethod,
    );
    return order;
  }

  Future<void> addAddress(DeliveryAddress address) async {
    final current = _profile;
    if (current == null) return;
    await _profileService.addAddress(current.id, address);
  }

  Future<void> updateAddress(DeliveryAddress address) async {
    final current = _profile;
    if (current == null) return;
    await _profileService.updateAddress(current.id, address);
  }

  Future<void> deleteAddress(String addressId) async {
    final current = _profile;
    if (current == null) return;
    await _profileService.deleteAddress(current.id, addressId);
  }

  @override
  void dispose() {
    _authSub?.cancel();
    _ordersSub?.cancel();
    _addressSub?.cancel();
    super.dispose();
  }
}
