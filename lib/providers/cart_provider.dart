import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/cart_item.dart';
import '../models/product.dart';
import '../services/cart_service.dart';

class CartProvider extends ChangeNotifier {
  final CartService _service = CartService.instance;
  final List<CartItem> _items = [];
  String? _uid;
  StreamSubscription? _sub;
  bool _loading = false;

  List<CartItem> get items => List.unmodifiable(_items);
  bool get isLoading => _loading;

  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);
  double get subtotal => _items.fold(0, (sum, item) => sum + item.totalPrice);
  double get shipping => subtotal > 100 || subtotal == 0 ? 0 : 9.99;
  double get total => subtotal + shipping;

  bool isInCart(String productId) =>
      _items.any((item) => item.product.id == productId);

  CartItem? getItem(String productId) {
    try {
      return _items.firstWhere((item) => item.product.id == productId);
    } catch (_) {
      return null;
    }
  }

  Future<void> bindUser(String? uid) async {
    if (_uid == uid) return;
    _sub?.cancel();
    _sub = null;

    if (uid == null) {
      _uid = null;
      _items.clear();
      notifyListeners();
      return;
    }

    final List<CartItem> guestItems = List.from(_items);
    _uid = uid;
    _loading = true;
    notifyListeners();

    try {
      final cloudItems = await _service.getItems(uid);
      _items
        ..clear()
        ..addAll(cloudItems);

      if (guestItems.isNotEmpty) {
        for (final g in guestItems) {
          final idx = _items.indexWhere((c) => c.key == g.key);
          if (idx >= 0) {
            _items[idx].quantity += g.quantity;
            await _service.setItem(uid, _items[idx]);
          } else {
            _items.add(g);
            await _service.setItem(uid, g);
          }
        }
      }
    } catch (e) {
      debugPrint('[CartProvider] bindUser failed (keeping local cart): $e');
    } finally {
      _loading = false;
      notifyListeners();
    }

    _sub = _service.watchItems(uid).listen((cloud) {
      _items
        ..clear()
        ..addAll(cloud);
      notifyListeners();
    }, onError: (e) {
      debugPrint('[CartProvider] cart stream error: $e');
    });
  }

  Future<void> addItem(Product product, String size, String color) async {
    final key = '${product.id}__${size}__$color';
    final idx = _items.indexWhere((i) => i.key == key);
    CartItem updated;
    if (idx >= 0) {
      _items[idx].quantity += 1;
      updated = _items[idx];
    } else {
      updated = CartItem(
        product: product,
        selectedSize: size,
        selectedColor: color,
      );
      _items.add(updated);
    }
    notifyListeners();
    if (_uid != null) {
      try {
        await _service.setItem(_uid!, updated);
      } catch (_) {}
    }
  }

  Future<void> removeItem(String productId) async {
    final removed = _items.where((i) => i.product.id == productId).toList();
    _items.removeWhere((i) => i.product.id == productId);
    notifyListeners();
    if (_uid != null) {
      for (final r in removed) {
        try {
          await _service.removeItem(_uid!, r.key);
        } catch (_) {}
      }
    }
  }

  Future<void> removeByKey(String key) async {
    final removed = _items.where((i) => i.key == key).toList();
    _items.removeWhere((i) => i.key == key);
    notifyListeners();
    if (_uid != null) {
      for (final r in removed) {
        try {
          await _service.removeItem(_uid!, r.key);
        } catch (_) {}
      }
    }
  }

  Future<void> updateQuantity(String productId, int quantity) async {
    final index = _items.indexWhere((item) => item.product.id == productId);
    if (index < 0) return;
    if (quantity <= 0) {
      await removeByKey(_items[index].key);
      return;
    }
    _items[index].quantity = quantity;
    notifyListeners();
    if (_uid != null) {
      try {
        await _service.setItem(_uid!, _items[index]);
      } catch (_) {}
    }
  }

  Future<void> updateQuantityByKey(String key, int quantity) async {
    final index = _items.indexWhere((item) => item.key == key);
    if (index < 0) return;
    if (quantity <= 0) {
      await removeByKey(key);
      return;
    }
    _items[index].quantity = quantity;
    notifyListeners();
    if (_uid != null) {
      try {
        await _service.setItem(_uid!, _items[index]);
      } catch (_) {}
    }
  }

  Future<void> clearCart() async {
    _items.clear();
    notifyListeners();
    if (_uid != null) {
      try {
        await _service.clear(_uid!);
      } catch (_) {}
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
