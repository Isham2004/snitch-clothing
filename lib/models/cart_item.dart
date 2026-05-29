import 'product.dart';

class CartItem {
  final Product product;
  int quantity;
  String selectedSize;
  String selectedColor;

  CartItem({
    required this.product,
    this.quantity = 1,
    required this.selectedSize,
    required this.selectedColor,
  });

  double get totalPrice => product.price * quantity;

  String get key => '${product.id}__${selectedSize}__$selectedColor';

  Map<String, dynamic> toMap() {
    return {
      'productId': product.id,
      'productName': product.name,
      'productImage': product.imageUrl,
      'productBrand': product.brand,
      'productCategory': product.category,
      'price': product.price,
      'originalPrice': product.originalPrice,
      'quantity': quantity,
      'selectedSize': selectedSize,
      'selectedColor': selectedColor,
    };
  }

  factory CartItem.fromMap(Map<String, dynamic> data) {
    final product = Product(
      id: (data['productId'] ?? '') as String,
      name: (data['productName'] ?? '') as String,
      brand: (data['productBrand'] ?? 'Snitch') as String,
      price: ((data['price'] ?? 0) as num).toDouble(),
      originalPrice: data['originalPrice'] == null
          ? null
          : (data['originalPrice'] as num).toDouble(),
      imageUrl: (data['productImage'] ?? '') as String,
      category: (data['productCategory'] ?? '') as String,
      description: '',
      sizes: const [],
      colors: const [],
    );
    return CartItem(
      product: product,
      quantity: ((data['quantity'] ?? 1) as num).toInt(),
      selectedSize: (data['selectedSize'] ?? '') as String,
      selectedColor: (data['selectedColor'] ?? '') as String,
    );
  }
}
