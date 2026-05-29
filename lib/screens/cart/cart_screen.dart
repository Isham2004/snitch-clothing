import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../providers/cart_provider.dart';
import '../checkout/checkout_screen.dart';
import '../main_scaffold.dart';
import '../products/product_list_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

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
            const Text('My Cart', style: AppTextStyles.headingLarge),
            if (cart.itemCount > 0)
              Text('${cart.itemCount} item${cart.itemCount > 1 ? 's' : ''}',
                  style: AppTextStyles.caption),
          ],
        ),
        centerTitle: true,
        actions: [
          if (cart.items.isNotEmpty)
            TextButton(
              onPressed: () => _showClearDialog(context, cart),
              child: const Text('Clear', style: TextStyle(color: AppColors.error, fontSize: 13)),
            ),
        ],
      ),
      body: cart.items.isEmpty
          ? _buildEmpty(context)
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: cart.items.length,
                    itemBuilder: (_, i) {
                      final item = cart.items[i];
                      return Dismissible(
                        key: Key(item.product.id + item.selectedSize + item.selectedColor),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: AppColors.error,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(Icons.delete_outline, color: AppColors.white, size: 26),
                        ),
                        onDismissed: (_) => cart.removeByKey(item.key),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(color: AppColors.shadow, blurRadius: 8, offset: const Offset(0, 2)),
                            ],
                          ),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
                                child: SizedBox(
                                  width: 90,
                                  height: 100,
                                  child: Image.network(
                                    item.product.imageUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, _, _) => Container(
                                      color: AppColors.accentLight,
                                      child: const Icon(Icons.image, color: AppColors.primaryLight),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(item.product.name,
                                          style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.textDark),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          _tag(item.selectedSize),
                                          const SizedBox(width: 6),
                                          _tag(item.selectedColor),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            '\$${item.totalPrice.toStringAsFixed(2)}',
                                            style: AppTextStyles.priceSmall,
                                          ),
                                          _QtyControl(
                                            qty: item.quantity,
                                            onDecrease: () => cart.updateQuantityByKey(
                                                item.key, item.quantity - 1),
                                            onIncrease: () => cart.updateQuantityByKey(
                                                item.key, item.quantity + 1),
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
                ),

                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                    boxShadow: [
                      BoxShadow(color: AppColors.shadow, blurRadius: 16, offset: const Offset(0, -4)),
                    ],
                  ),
                  child: Column(
                    children: [
                      _summaryRow('Subtotal', '\$${cart.subtotal.toStringAsFixed(2)}'),
                      const SizedBox(height: 6),
                      _summaryRow(
                        'Shipping',
                        cart.shipping == 0 ? 'FREE' : '\$${cart.shipping.toStringAsFixed(2)}',
                        valueColor: cart.shipping == 0 ? AppColors.success : null,
                      ),
                      if (cart.shipping > 0) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Add \$${(100 - cart.subtotal).toStringAsFixed(2)} more for free shipping',
                          style: const TextStyle(fontSize: 11, color: AppColors.textLight),
                        ),
                      ],
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Divider(color: AppColors.divider),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textDark)),
                          Text('\$${cart.total.toStringAsFixed(2)}',
                              style: AppTextStyles.priceLarge),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const CheckoutScreen()),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            elevation: 0,
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Proceed to Checkout', style: AppTextStyles.buttonText),
                              SizedBox(width: 8),
                              Icon(Icons.arrow_forward_rounded, size: 20),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _tag(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.divider),
      ),
      child: Text(label,
          style: const TextStyle(fontSize: 10, color: AppColors.textMedium, fontWeight: FontWeight.w500)),
    );
  }

  Widget _summaryRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.bodyMedium),
        Text(value,
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: valueColor ?? AppColors.textDark)),
      ],
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.accentLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.shopping_bag_outlined, size: 48, color: AppColors.primary),
          ),
          const SizedBox(height: 20),
          const Text('Your cart is empty', style: AppTextStyles.headingMedium),
          const SizedBox(height: 8),
          const Text('Start shopping to add items to your cart',
              style: AppTextStyles.bodyMedium, textAlign: TextAlign.center),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProductListScreen()),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
            ),
            child: const Text('Shop Now'),
          ),
        ],
      ),
    );
  }

  void _showClearDialog(BuildContext context, CartProvider cart) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Clear Cart', style: AppTextStyles.headingSmall),
        content: const Text('Remove all items from your cart?', style: AppTextStyles.bodyMedium),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textMedium)),
          ),
          ElevatedButton(
            onPressed: () {
              cart.clearCart();
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

class _QtyControl extends StatelessWidget {
  final int qty;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;

  const _QtyControl({
    required this.qty,
    required this.onDecrease,
    required this.onIncrease,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 32,
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.divider),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _btn(Icons.remove, onDecrease, qty <= 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text('$qty',
                style: const TextStyle(
                    fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.textDark)),
          ),
          _btn(Icons.add, onIncrease, false),
        ],
      ),
    );
  }

  Widget _btn(IconData icon, VoidCallback onTap, bool disabled) {
    return GestureDetector(
      onTap: disabled ? null : onTap,
      child: Container(
        width: 30,
        height: 32,
        color: Colors.transparent,
        child: Icon(icon, size: 16, color: disabled ? AppColors.textLight : AppColors.primary),
      ),
    );
  }
}
