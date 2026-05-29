import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/product.dart';
import '../services/product_service.dart';

class ProductsProvider extends ChangeNotifier {
  final ProductService _service = ProductService.instance;
  StreamSubscription? _sub;

  List<Product> _all = [];
  bool _loading = false;
  String? _error;
  bool _loaded = false;

  List<Product> get all => List.unmodifiable(_all);
  bool get isLoading => _loading;
  bool get hasLoaded => _loaded;
  String? get error => _error;

  List<Product> get featured =>
      _all.where((p) => p.isFeatured).toList();

  List<Product> get newArrivals =>
      _all.where((p) => p.isNew).toList();

  List<String> get categories {
    final s = <String>{};
    for (final p in _all) {
      s.add(p.category);
    }
    final list = s.toList()..sort();
    return ['All', ...list];
  }

  List<Product> byCategory(String category) {
    if (category == 'All') return all;
    return _all.where((p) => p.category == category).toList();
  }

  Product? byId(String id) {
    try {
      return _all.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  List<Product> search(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return all;
    return _all.where((p) {
      return p.name.toLowerCase().contains(q) ||
          p.brand.toLowerCase().contains(q) ||
          p.category.toLowerCase().contains(q) ||
          p.description.toLowerCase().contains(q);
    }).toList();
  }

  Future<void> load({bool force = false}) async {
    if (_loading) return;
    if (_loaded && !force) return;
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final list = await _service.getAll();
      _all = list;
      _loaded = true;
      if (list.isNotEmpty) {
        _attachStream();
      }
    } catch (e) {
      debugPrint('[ProductsProvider] load failed: $e');
      _error = e.toString();
      _loaded = true;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() => load(force: true);

  void _attachStream() {
    _sub?.cancel();
    _sub = _service.watchAll().listen((list) {
      _all = list;
      notifyListeners();
    }, onError: (e) {
      debugPrint('[ProductsProvider] watchAll error: $e');
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
