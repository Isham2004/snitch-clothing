import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class CategoriesProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  StreamSubscription? _sub;

  List<String> _names = [];
  bool _loaded = false;

  List<String> get all => ['All', ..._names];
  List<String> get names => List.unmodifiable(_names);
  bool get hasLoaded => _loaded;

  void start() {
    _sub ??= _firestore
        .collection('categories')
        .orderBy('order')
        .snapshots()
        .listen((snap) {
      _names = snap.docs
          .map((d) => (d.data()['name'] ?? '') as String)
          .where((s) => s.isNotEmpty)
          .toList();
      _loaded = true;
      notifyListeners();
    }, onError: (e) {
      debugPrint('[CategoriesProvider] stream error: $e');
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
