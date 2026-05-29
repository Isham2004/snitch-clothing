class Product {
  final String id;
  final String name;
  final String brand;
  final double price;
  final double? originalPrice;
  final String imageUrl;
  final List<String> additionalImages;
  final String category;
  final String description;
  final List<String> sizes;
  final List<String> colors;
  final double rating;
  final int reviewCount;
  final bool isNew;
  final bool isFeatured;
  final int stock;
  final String? tag;

  const Product({
    required this.id,
    required this.name,
    required this.brand,
    required this.price,
    this.originalPrice,
    required this.imageUrl,
    this.additionalImages = const [],
    required this.category,
    required this.description,
    required this.sizes,
    required this.colors,
    this.rating = 4.0,
    this.reviewCount = 0,
    this.isNew = false,
    this.isFeatured = false,
    this.stock = 10,
    this.tag,
  });

  bool get isOnSale => originalPrice != null && originalPrice! > price;

  double get discountPercent =>
      isOnSale ? ((originalPrice! - price) / originalPrice! * 100).roundToDouble() : 0;

  factory Product.fromMap(String id, Map<String, dynamic> data) {
    return Product(
      id: id,
      name: (data['name'] ?? '') as String,
      brand: (data['brand'] ?? 'Snitch') as String,
      price: ((data['price'] ?? 0) as num).toDouble(),
      originalPrice: data['originalPrice'] == null
          ? null
          : (data['originalPrice'] as num).toDouble(),
      imageUrl: (data['imageUrl'] ?? '') as String,
      additionalImages: (data['additionalImages'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      category: (data['category'] ?? '') as String,
      description: (data['description'] ?? '') as String,
      sizes: (data['sizes'] as List?)?.map((e) => e.toString()).toList() ??
          const [],
      colors: (data['colors'] as List?)?.map((e) => e.toString()).toList() ??
          const [],
      rating: ((data['rating'] ?? 4.0) as num).toDouble(),
      reviewCount: ((data['reviewCount'] ?? 0) as num).toInt(),
      isNew: (data['isNew'] ?? false) as bool,
      isFeatured: (data['isFeatured'] ?? false) as bool,
      stock: ((data['stock'] ?? 10) as num).toInt(),
      tag: data['tag'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'brand': brand,
      'price': price,
      'originalPrice': originalPrice,
      'imageUrl': imageUrl,
      'additionalImages': additionalImages,
      'category': category,
      'description': description,
      'sizes': sizes,
      'colors': colors,
      'rating': rating,
      'reviewCount': reviewCount,
      'isNew': isNew,
      'isFeatured': isFeatured,
      'stock': stock,
      'tag': tag,
      'searchKeywords': _buildSearchKeywords(),
    };
  }

  List<String> _buildSearchKeywords() {
    final keywords = <String>{};
    void add(String? text) {
      if (text == null) return;
      final lower = text.toLowerCase();
      keywords.add(lower);
      for (final part in lower.split(RegExp(r'\s+'))) {
        if (part.isNotEmpty) keywords.add(part);
      }
    }

    add(name);
    add(brand);
    add(category);
    if (tag != null) add(tag);
    return keywords.toList();
  }
}
