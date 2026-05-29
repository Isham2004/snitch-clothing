import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../models/product.dart';
import '../../providers/cart_provider.dart';
import '../../providers/favorites_provider.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen>
    with SingleTickerProviderStateMixin {
  int _imageIndex = 0;
  String? _selectedSize;
  String? _selectedColor;
  late TabController _tabController;
  bool _addedToCart = false;

  List<String> get _allImages =>
      [widget.product.imageUrl, ...widget.product.additionalImages];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    if (widget.product.sizes.isNotEmpty) {
      _selectedSize = widget.product.sizes.first;
    }
    if (widget.product.colors.isNotEmpty) {
      _selectedColor = widget.product.colors.first;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _addToCart() {
    if (_selectedSize == null || _selectedColor == null) return;
    context.read<CartProvider>().addItem(
          widget.product,
          _selectedSize!,
          _selectedColor!,
        );
    setState(() => _addedToCart = true);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Added to cart!'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
        action: SnackBarAction(
          label: 'View Cart',
          textColor: AppColors.white,
          onPressed: () => Navigator.pop(context),
        ),
      ),
    );
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _addedToCart = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final isFav = context.watch<FavoritesProvider>().isFavorite(product.id);
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8),
              ],
            ),
            child: const Icon(Icons.arrow_back_ios_new, color: AppColors.textDark, size: 18),
          ),
        ),
        actions: [
          GestureDetector(
            onTap: () => context.read<FavoritesProvider>().toggle(product),
            child: Container(
              margin: const EdgeInsets.all(8),
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8),
                ],
              ),
              child: Icon(
                isFav ? Icons.favorite : Icons.favorite_border,
                color: isFav ? AppColors.error : AppColors.textMedium,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          SizedBox(
            height: screenHeight * 0.45,
            child: Stack(
              children: [
                PageView.builder(
                  onPageChanged: (i) => setState(() => _imageIndex = i),
                  itemCount: _allImages.length,
                  itemBuilder: (_, i) => Image.network(
                    _allImages[i],
                    fit: BoxFit.cover,
                    width: double.infinity,
                    errorBuilder: (_, _, _) => Container(
                      color: AppColors.accentLight,
                      child: const Icon(Icons.image, color: AppColors.primaryLight, size: 60),
                    ),
                  ),
                ),
                if (_allImages.length > 1)
                  Positioned(
                    bottom: 16,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(_allImages.length, (i) {
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          width: _imageIndex == i ? 20 : 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: _imageIndex == i ? AppColors.primary : AppColors.white.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        );
                      }),
                    ),
                  ),
                if (product.isOnSale)
                  Positioned(
                    top: 80,
                    left: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.error,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '-${product.discountPercent.toInt()}%',
                        style: const TextStyle(
                            color: AppColors.white, fontWeight: FontWeight.w800, fontSize: 13),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.accentLight,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(product.category,
                              style: const TextStyle(
                                  color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w600)),
                        ),
                        const Spacer(),
                        Row(
                          children: [
                            const Icon(Icons.star_rounded, size: 16, color: Color(0xFFFFC107)),
                            const SizedBox(width: 4),
                            Text('${product.rating}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textDark,
                                    fontSize: 14)),
                            Text(' (${product.reviewCount})',
                                style: const TextStyle(color: AppColors.textLight, fontSize: 12)),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    Text(product.name, style: AppTextStyles.headingLarge),
                    const SizedBox(height: 4),
                    Text(product.brand,
                        style: const TextStyle(
                            color: AppColors.primaryLight, fontWeight: FontWeight.w500, fontSize: 13)),
                    const SizedBox(height: 14),

                    Row(
                      children: [
                        Text('\$${product.price.toStringAsFixed(2)}', style: AppTextStyles.priceLarge),
                        if (product.isOnSale) ...[
                          const SizedBox(width: 12),
                          Text(
                            '\$${product.originalPrice!.toStringAsFixed(2)}',
                            style: const TextStyle(
                                fontSize: 16,
                                color: AppColors.textLight,
                                decoration: TextDecoration.lineThrough),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.error.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'Save \$${(product.originalPrice! - product.price).toStringAsFixed(2)}',
                              style: const TextStyle(
                                  color: AppColors.error, fontWeight: FontWeight.w700, fontSize: 11),
                            ),
                          ),
                        ],
                      ],
                    ),

                    const SizedBox(height: 20),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Select Size', style: AppTextStyles.headingSmall),
                        Text('Size Guide',
                            style: const TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w500,
                                fontSize: 12)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      runSpacing: 8,
                      children: product.sizes.map((size) {
                        final isSelected = _selectedSize == size;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedSize = size),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 50,
                            height: 40,
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.primary : AppColors.background,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isSelected ? AppColors.primary : AppColors.divider,
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                size,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: isSelected ? AppColors.white : AppColors.textMedium,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 20),

                    const Text('Select Color', style: AppTextStyles.headingSmall),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      runSpacing: 8,
                      children: product.colors.map((color) {
                        final isSelected = _selectedColor == color;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedColor = color),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.accentLight : AppColors.background,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected ? AppColors.primary : AppColors.divider,
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Text(
                              color,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                color: isSelected ? AppColors.primary : AppColors.textMedium,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 20),

                    TabBar(
                      controller: _tabController,
                      labelColor: AppColors.primary,
                      unselectedLabelColor: AppColors.textLight,
                      indicatorColor: AppColors.primary,
                      indicatorWeight: 3,
                      labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                      unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
                      tabs: const [Tab(text: 'Description'), Tab(text: 'Reviews')],
                    ),
                    SizedBox(
                      height: 160,
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 14),
                            child: Text(product.description, style: AppTextStyles.bodyMedium),
                          ),
                          _buildReviews(),
                        ],
                      ),
                    ),

                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        decoration: BoxDecoration(
          color: AppColors.white,
          boxShadow: [
            BoxShadow(color: AppColors.shadow, blurRadius: 20, offset: const Offset(0, -4)),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.divider),
              ),
              child: IconButton(
                icon: const Icon(Icons.share_outlined, color: AppColors.primary),
                onPressed: () {},
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SizedBox(
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: _addToCart,
                  icon: Icon(
                    _addedToCart ? Icons.check_circle_rounded : Icons.shopping_bag_outlined,
                    size: 20,
                  ),
                  label: Text(_addedToCart ? 'Added!' : 'Add to Cart',
                      style: AppTextStyles.buttonText),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _addedToCart ? AppColors.success : AppColors.primary,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviews() {
    final reviews = [
      {'user': 'Jordan T.', 'rating': '5', 'text': 'Amazing quality! Fits perfectly and looks great.'},
      {'user': 'Casey M.', 'rating': '4', 'text': 'Great product, fast shipping. Will order again.'},
      {'user': 'Riley S.', 'rating': '5', 'text': 'Exactly as described. Love the material.'},
    ];
    return ListView.builder(
      padding: const EdgeInsets.only(top: 12),
      itemCount: reviews.length,
      itemBuilder: (_, i) {
        final r = reviews[i];
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.accentLight,
                child: Text(r['user']![0],
                    style: const TextStyle(
                        color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 13)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(r['user']!,
                            style: const TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 12, color: AppColors.textDark)),
                        const Spacer(),
                        Row(
                          children: List.generate(
                            int.parse(r['rating']!),
                            (_) => const Icon(Icons.star_rounded, size: 12, color: Color(0xFFFFC107)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(r['text']!, style: AppTextStyles.bodySmall),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
