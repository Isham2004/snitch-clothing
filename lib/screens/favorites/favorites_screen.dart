import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../providers/cart_provider.dart';
import '../../providers/favorites_provider.dart';
import '../main_scaffold.dart';
import '../products/product_detail_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final favorites = context.watch<FavoritesProvider>();
    final items = favorites.items;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu_rounded, color: AppColors.textDark),
          onPressed: MainScaffold.openDrawer,
        ),
        title: Column(
          children: [
            const Text('Favorites', style: AppTextStyles.headingLarge),
            if (items.isNotEmpty)
              Text('${items.length} item${items.length > 1 ? 's' : ''}', style: AppTextStyles.caption),
          ],
        ),
        centerTitle: true,
        actions: [
          if (items.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_rounded, color: AppColors.error),
              onPressed: () => _showClearDialog(context, favorites),
            ),
        ],
      ),
      body: items.isEmpty
          ? _buildEmpty()
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: screenWidth > 600 ? 3 : 2,
                childAspectRatio: 0.65,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: items.length,
              itemBuilder: (_, i) {
                final product = items[i];
                return GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => ProductDetailScreen(product: product)),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(color: AppColors.shadow, blurRadius: 10, offset: const Offset(0, 3)),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 3,
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                                child: SizedBox.expand(
                                  child: Image.network(
                                    product.imageUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, _, _) => Container(
                                      color: AppColors.accentLight,
                                      child: const Icon(Icons.image, color: AppColors.primaryLight, size: 36),
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: GestureDetector(
                                  onTap: () => favorites.remove(product.id),
                                  child: Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: AppColors.error.withOpacity(0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.favorite, size: 17, color: AppColors.error),
                                  ),
                                ),
                              ),
                              if (product.tag != null)
                                Positioned(
                                  top: 8,
                                  left: 8,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: product.tag == 'SALE' ? AppColors.error : AppColors.primary,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      product.tag!,
                                      style: const TextStyle(
                                          color: AppColors.white, fontSize: 8, fontWeight: FontWeight.w700),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(product.name,
                                    style: const TextStyle(
                                        fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textDark),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.star_rounded, size: 12, color: Color(0xFFFFC107)),
                                    const SizedBox(width: 2),
                                    Text('${product.rating}',
                                        style: const TextStyle(fontSize: 10, color: AppColors.textLight)),
                                  ],
                                ),
                                const Spacer(),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('\$${product.price.toStringAsFixed(2)}',
                                        style: AppTextStyles.priceSmall),
                                    GestureDetector(
                                      onTap: () {
                                        if (product.sizes.isEmpty ||
                                            product.colors.isEmpty) {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  ProductDetailScreen(
                                                      product: product),
                                            ),
                                          );
                                          return;
                                        }
                                        context.read<CartProvider>().addItem(
                                              product,
                                              product.sizes.first,
                                              product.colors.first,
                                            );
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                                'Added "${product.name}" to cart'),
                                            backgroundColor: AppColors.success,
                                            behavior: SnackBarBehavior.floating,
                                            duration:
                                                const Duration(seconds: 2),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        height: 28,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10),
                                        decoration: BoxDecoration(
                                          color: AppColors.accentLight,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Center(
                                          child: Text('Add',
                                              style: const TextStyle(
                                                  fontSize: 11,
                                                  color: AppColors.primary,
                                                  fontWeight: FontWeight.w700)),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildEmpty() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.favorite_border_rounded, size: 80, color: AppColors.divider),
          SizedBox(height: 16),
          Text('No favorites yet', style: AppTextStyles.headingMedium),
          SizedBox(height: 8),
          Text('Tap the heart icon on any product to save it here',
              style: AppTextStyles.bodyMedium, textAlign: TextAlign.center),
        ],
      ),
    );
  }

  void _showClearDialog(BuildContext context, FavoritesProvider favorites) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Clear Favorites', style: AppTextStyles.headingSmall),
        content: const Text('Remove all saved items?', style: AppTextStyles.bodyMedium),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textMedium)),
          ),
          ElevatedButton(
            onPressed: () {
              for (final p in favorites.items.toList()) {
                favorites.remove(p.id);
              }
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}
