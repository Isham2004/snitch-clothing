import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../models/order_model.dart';
import '../../providers/user_provider.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final orders = context.watch<UserProvider>().orders;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textDark, size: 20),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        title: const Text('My Orders', style: AppTextStyles.headingLarge),
        centerTitle: true,
      ),
      body: orders.isEmpty
          ? _buildEmpty()
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: orders.length,
              itemBuilder: (_, i) => _OrderCard(order: orders[i]),
            ),
    );
  }

  Widget _buildEmpty() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_outlined, size: 80, color: AppColors.divider),
          SizedBox(height: 16),
          Text('No orders yet', style: AppTextStyles.headingMedium),
          SizedBox(height: 8),
          Text('Your order history will appear here',
              style: AppTextStyles.bodyMedium, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _OrderCard extends StatefulWidget {
  final OrderModel order;
  const _OrderCard({required this.order});

  @override
  State<_OrderCard> createState() => _OrderCardState();
}

class _OrderCardState extends State<_OrderCard> {
  bool _expanded = false;

  Color _statusColor(String status) {
    switch (status) {
      case 'Confirmed':
        return AppColors.success;
      case 'Processing':
        return AppColors.warning;
      case 'Shipped':
        return AppColors.primaryLight;
      case 'Delivered':
        return AppColors.success;
      case 'Cancelled':
        return AppColors.error;
      default:
        return AppColors.textLight;
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'Confirmed':
        return Icons.check_circle_outline;
      case 'Processing':
        return Icons.hourglass_top_rounded;
      case 'Shipped':
        return Icons.local_shipping_outlined;
      case 'Delivered':
        return Icons.done_all_rounded;
      case 'Cancelled':
        return Icons.cancel_outlined;
      default:
        return Icons.info_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: AppColors.shadow, blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: _statusColor(order.status).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(_statusIcon(order.status),
                          color: _statusColor(order.status), size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(order.id,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                      color: AppColors.textDark)),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _statusColor(order.status).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  order.status,
                                  style: TextStyle(
                                      color: _statusColor(order.status),
                                      fontWeight: FontWeight.w700,
                                      fontSize: 11),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _formatDate(order.date),
                            style: AppTextStyles.bodySmall,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${order.items.length} item${order.items.length > 1 ? 's' : ''} · \$${order.total.toStringAsFixed(2)}',
                            style: const TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textMedium),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (order.items.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      ...order.items.take(3).map((item) => Container(
                            margin: const EdgeInsets.only(right: 8),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: SizedBox(
                                width: 44,
                                height: 44,
                                child: Image.network(item.product.imageUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, _, _) => Container(
                                        color: AppColors.accentLight,
                                        child: const Icon(Icons.image,
                                            color: AppColors.primaryLight, size: 20))),
                              ),
                            ),
                          )),
                      if (order.items.length > 3)
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.accentLight,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text('+${order.items.length - 3}',
                                style: const TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13)),
                          ),
                        ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => setState(() => _expanded = !_expanded),
                        child: Row(
                          children: [
                            Text(
                              _expanded ? 'Less' : 'Details',
                              style: const TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12),
                            ),
                            Icon(
                              _expanded ? Icons.expand_less : Icons.expand_more,
                              color: AppColors.primary,
                              size: 18,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          if (_expanded) ...[
            const Divider(color: AppColors.divider, height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Items', style: AppTextStyles.headingSmall),
                  const SizedBox(height: 10),
                  ...order.items.map((item) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: SizedBox(
                                width: 40,
                                height: 40,
                                child: Image.network(item.product.imageUrl, fit: BoxFit.cover),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item.product.name,
                                      style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textDark)),
                                  Text('${item.selectedSize} | ${item.selectedColor} × ${item.quantity}',
                                      style: AppTextStyles.caption),
                                ],
                              ),
                            ),
                            Text('\$${item.totalPrice.toStringAsFixed(2)}',
                                style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textDark)),
                          ],
                        ),
                      )),
                  const Divider(color: AppColors.divider, height: 20),
                  _row('Subtotal', '\$${order.subtotal.toStringAsFixed(2)}'),
                  const SizedBox(height: 4),
                  _row('Shipping', order.shipping == 0 ? 'FREE' : '\$${order.shipping.toStringAsFixed(2)}'),
                  const SizedBox(height: 4),
                  _row('Payment', order.paymentMethod),
                  const SizedBox(height: 4),
                  _row('Delivery', order.address),
                  const Divider(color: AppColors.divider, height: 20),
                  _row('Total', '\$${order.total.toStringAsFixed(2)}', bold: true),
                  const SizedBox(height: 12),
                  _buildTrackingBar(order.status),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTrackingBar(String status) {
    final steps = ['Confirmed', 'Processing', 'Shipped', 'Delivered'];
    final idx = steps.indexOf(status);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Tracking', style: AppTextStyles.headingSmall),
        const SizedBox(height: 12),
        Row(
          children: List.generate(steps.length * 2 - 1, (i) {
            if (i.isOdd) {
              final stepNum = i ~/ 2;
              return Expanded(
                child: Container(
                  height: 2,
                  color: stepNum < idx ? AppColors.primary : AppColors.divider,
                ),
              );
            }
            final stepNum = i ~/ 2;
            final isDone = stepNum <= idx;
            return Column(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: isDone ? AppColors.primary : AppColors.divider,
                    shape: BoxShape.circle,
                  ),
                  child: isDone
                      ? const Icon(Icons.check, color: AppColors.white, size: 12)
                      : null,
                ),
                const SizedBox(height: 4),
                Text(
                  steps[stepNum],
                  style: TextStyle(
                    fontSize: 9,
                    color: isDone ? AppColors.primary : AppColors.textLight,
                    fontWeight: isDone ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ],
            );
          }),
        ),
      ],
    );
  }

  Widget _row(String label, String value, {bool bold = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(label,
              style: const TextStyle(fontSize: 12, color: AppColors.textLight)),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
              color: bold ? AppColors.primary : AppColors.textDark,
            ),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month]} ${date.day}, ${date.year}';
  }
}
