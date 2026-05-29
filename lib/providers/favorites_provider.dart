import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/product.dart';

class FavoritesProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final List<Product> _items = [];
  String? _uid;
  StreamSubscription? _sub;

  List<Product> get items => List.unmodifiable(_items);
  int get count => _items.length;

  bool isFavorite(String productId) =>
      _items.any((p) => p.id == productId);

  CollectionReference<Map<String, dynamic>> _col(String uid) =>
      _firestore.collection('users').doc(uid).collection('favorites');

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

    final guest = List<Product>.from(_items);
    _uid = uid;
    _items.clear();

    try {
      final snap = await _col(uid).get();
      _items.addAll(snap.docs.map((d) => Product.fromMap(d.id, d.data())));

      for (final g in guest) {
        if (!_items.any((p) => p.id == g.id)) {
          _items.add(g);
          await _col(uid).doc(g.id).set(g.toMap());
        }
      }
    } catch (_) {}

    notifyListeners();

    _sub = _col(uid).snapshots().listen((snap) {
      _items
        ..clear()
        ..addAll(snap.docs.map((d) => Product.fromMap(d.id, d.data())));
      notifyListeners();
    }, onError: (_) {});
  }

  Future<void> toggle(Product product) async {
    if (isFavorite(product.id)) {
      _items.removeWhere((p) => p.id == product.id);
      notifyListeners();
      if (_uid != null) {
        try {
          await _col(_uid!).doc(product.id).delete();
        } catch (_) {}
      }
    } else {
      _items.add(product);
      notifyListeners();
      if (_uid != null) {
        try {
          await _col(_uid!).doc(product.id).set(product.toMap());
        } catch (_) {}
      }
    }
  }

  Future<void> remove(String productId) async {
    _items.removeWhere((p) => p.id == productId);
    notifyListeners();
    if (_uid != null) {
      try {
        await _col(_uid!).doc(productId).delete();
      } catch (_) {}
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
