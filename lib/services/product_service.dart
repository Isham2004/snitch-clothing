import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';

class ProductService {
  ProductService._();
  static final ProductService instance = ProductService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _col =>
      _firestore.collection('products');

  Future<List<Product>> getAll() async {
    final snap = await _col.orderBy('name').get();
    return snap.docs.map((d) => Product.fromMap(d.id, d.data())).toList();
  }

  Stream<List<Product>> watchAll() {
    return _col.orderBy('name').snapshots().map(
          (s) => s.docs.map((d) => Product.fromMap(d.id, d.data())).toList(),
        );
  }

  Future<List<Product>> getByCategory(String category) async {
    if (category == 'All') return getAll();
    final snap = await _col.where('category', isEqualTo: category).get();
    return snap.docs.map((d) => Product.fromMap(d.id, d.data())).toList();
  }

  Future<List<Product>> getFeatured() async {
    final snap = await _col.where('isFeatured', isEqualTo: true).get();
    return snap.docs.map((d) => Product.fromMap(d.id, d.data())).toList();
  }

  Future<List<Product>> getNew() async {
    final snap = await _col.where('isNew', isEqualTo: true).get();
    return snap.docs.map((d) => Product.fromMap(d.id, d.data())).toList();
  }

  Future<Product?> getById(String id) async {
    final doc = await _col.doc(id).get();
    if (!doc.exists || doc.data() == null) return null;
    return Product.fromMap(doc.id, doc.data()!);
  }

  Future<List<Product>> search(String query) async {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return getAll();

    final all = await getAll();
    return all.where((p) {
      return p.name.toLowerCase().contains(q) ||
          p.category.toLowerCase().contains(q) ||
          p.description.toLowerCase().contains(q) ||
          p.brand.toLowerCase().contains(q);
    }).toList();
  }

  Future<List<String>> getCategories() async {
    final all = await getAll();
    final set = <String>{};
    for (final p in all) {
      set.add(p.category);
    }
    final list = set.toList()..sort();
    return ['All', ...list];
  }

  Future<void> upsertProduct(Product product) async {
    await _col.doc(product.id).set(product.toMap());
  }

  Future<int> countProducts() async {
    final snap = await _col.limit(1).get();
    if (snap.docs.isEmpty) return 0;
    final agg = await _col.count().get();
    return agg.count ?? snap.docs.length;
  }
}
