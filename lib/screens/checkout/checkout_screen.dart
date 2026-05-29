import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../providers/cart_provider.dart';
import '../../providers/user_provider.dart';
import '../auth/login_screen.dart';
import '../orders/orders_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  int _step = 0;
  String _paymentMethod = 'Credit Card';
  bool _loading = false;

  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _zipCtrl = TextEditingController();
  final _cardCtrl = TextEditingController(text: '•••• •••• •••• 4242');

  @override
  void initState() {
    super.initState();
    final user = context.read<UserProvider>();
    if (user.isLoggedIn) {
      final p = user.profile;
      _nameCtrl.text = p.name;
      _phoneCtrl.text = p.phone;
      if (p.address.isNotEmpty) {
        final parts = p.address.split(',').map((e) => e.trim()).toList();
        if (parts.isNotEmpty) _addressCtrl.text = parts[0];
        if (parts.length >= 2) _cityCtrl.text = parts[1];
        if (parts.length >= 3) _zipCtrl.text = parts.last;
      }
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    _cityCtrl.dispose();
    _zipCtrl.dispose();
    _cardCtrl.dispose();
    super.dispose();
  }

  void _placeOrder() async {
    if (!_formKey.currentState!.validate()) return;

    final cart = context.read<CartProvider>();
    final user = context.read<UserProvider>();

    if (cart.items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Your cart is empty.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (!user.isLoggedIn) {
      final goLogin = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Sign In Required',
              style: AppTextStyles.headingSmall),
          content: const Text('Please sign in to place an order.',
              style: AppTextStyles.bodyMedium),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel',
                  style: TextStyle(color: AppColors.textMedium)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
              child: const Text('Sign In'),
            ),
          ],
        ),
      );
      if (goLogin == true && mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
      return;
    }

    setState(() => _loading = true);
    try {
      final order = await user.placeOrder(
        items: cart.items,
        subtotal: cart.subtotal,
        shipping: cart.shipping,
        total: cart.total,
        address:
            '${_addressCtrl.text.trim()}, ${_cityCtrl.text.trim()}, ${_zipCtrl.text.trim()}',
        paymentMethod: _paymentMethod,
      );
      await cart.clearCart();
      if (!mounted) return;
      setState(() => _loading = false);
      _showSuccessDialog(order.id);
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to place order: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _showSuccessDialog(String orderId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  color: Color(0xFFE8F5E9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 48),
              ),
              const SizedBox(height: 16),
              const Text('Order Placed!', style: AppTextStyles.headingLarge),
              const SizedBox(height: 8),
              Text('Order $orderId has been confirmed.',
                  style: AppTextStyles.bodyMedium, textAlign: TextAlign.center),
              const SizedBox(height: 6),
              const Text('You will receive a confirmation email shortly.',
                  style: AppTextStyles.bodySmall, textAlign: TextAlign.center),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const OrdersScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('View My Orders'),
                ),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.popUntil(context, (r) => r.isFirst);
                },
                child: const Text('Continue Shopping',
                    style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textDark, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Checkout', style: AppTextStyles.headingLarge),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            _buildStepHeader(),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _step == 0
                      ? _buildDeliveryStep()
                      : _step == 1
                          ? _buildPaymentStep()
                          : _buildReviewStep(cart),
                ),
              ),
            ),

            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
              decoration: BoxDecoration(
                color: AppColors.white,
                boxShadow: [
                  BoxShadow(color: AppColors.shadow, blurRadius: 16, offset: const Offset(0, -4)),
                ],
              ),
              child: Row(
                children: [
                  if (_step > 0)
                    Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: SizedBox(
                        height: 54,
                        width: 54,
                        child: OutlinedButton(
                          onPressed: () => setState(() => _step--),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.divider),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          child: const Icon(Icons.arrow_back_ios_new,
                              color: AppColors.textDark, size: 16),
                        ),
                      ),
                    ),
                  Expanded(
                    child: SizedBox(
                      height: 54,
                      child: ElevatedButton(
                        onPressed: _loading
                            ? null
                            : () {
                                if (_step < 2) {
                                  setState(() => _step++);
                                } else {
                                  _placeOrder();
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          elevation: 0,
                        ),
                        child: _loading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    _step == 2 ? 'Place Order' : 'Continue',
                                    style: AppTextStyles.buttonText,
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(
                                    _step == 2 ? Icons.check_circle_outline : Icons.arrow_forward_rounded,
                                    size: 20,
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepHeader() {
    final steps = ['Delivery', 'Payment', 'Review'];
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: List.generate(steps.length * 2 - 1, (i) {
          if (i.isOdd) {
            final stepNum = i ~/ 2;
            return Expanded(
              child: Container(
                height: 2,
                color: stepNum < _step ? AppColors.primary : AppColors.divider,
              ),
            );
          }
          final stepNum = i ~/ 2;
          final isActive = stepNum == _step;
          final isDone = stepNum < _step;
          return Column(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: isDone || isActive ? AppColors.primary : AppColors.background,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isDone || isActive ? AppColors.primary : AppColors.divider,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: isDone
                      ? const Icon(Icons.check, color: AppColors.white, size: 16)
                      : Text(
                          '${stepNum + 1}',
                          style: TextStyle(
                            color: isActive ? AppColors.white : AppColors.textLight,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                steps[stepNum],
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
                  color: isActive ? AppColors.primary : AppColors.textLight,
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildDeliveryStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Delivery Details'),
        const SizedBox(height: 16),
        _field('Full Name', _nameCtrl, Icons.person_outline),
        const SizedBox(height: 14),
        _field('Phone Number', _phoneCtrl, Icons.phone_outlined,
            type: TextInputType.phone),
        const SizedBox(height: 14),
        _field('Street Address', _addressCtrl, Icons.location_on_outlined),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(child: _field('City', _cityCtrl, Icons.location_city_outlined)),
            const SizedBox(width: 12),
            Expanded(child: _field('ZIP', _zipCtrl, Icons.pin_drop_outlined,
                type: TextInputType.number)),
          ],
        ),
        const SizedBox(height: 20),
        _sectionTitle('Delivery Method'),
        const SizedBox(height: 12),
        _deliveryOption('Standard Delivery', '3-5 business days', '\$9.99', false),
        const SizedBox(height: 10),
        _deliveryOption('Express Delivery', '1-2 business days', '\$19.99', true),
      ],
    );
  }

  Widget _buildPaymentStep() {
    final methods = [
      {'name': 'Credit Card', 'icon': Icons.credit_card_rounded},
      {'name': 'Debit Card', 'icon': Icons.payment_rounded},
      {'name': 'PayPal', 'icon': Icons.account_balance_wallet_rounded},
      {'name': 'Cash on Delivery', 'icon': Icons.attach_money_rounded},
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Payment Method'),
        const SizedBox(height: 16),
        ...methods.map((m) {
          final isSelected = _paymentMethod == m['name'];
          return GestureDetector(
            onTap: () => setState(() => _paymentMethod = m['name'] as String),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.accentLight : AppColors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.divider,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(m['icon'] as IconData,
                      color: isSelected ? AppColors.primary : AppColors.textMedium, size: 24),
                  const SizedBox(width: 14),
                  Text(m['name'] as String,
                      style: TextStyle(
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected ? AppColors.primary : AppColors.textDark,
                          fontSize: 14)),
                  const Spacer(),
                  if (isSelected)
                    const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 20),
                ],
              ),
            ),
          );
        }),
        if (_paymentMethod == 'Credit Card' || _paymentMethod == 'Debit Card') ...[
          const SizedBox(height: 16),
          _sectionTitle('Card Details'),
          const SizedBox(height: 12),
          _field('Card Number', _cardCtrl, Icons.credit_card, type: TextInputType.number),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                  child: _field('Expiry (MM/YY)',
                      TextEditingController(text: '12/28'), Icons.calendar_today_outlined)),
              const SizedBox(width: 12),
              Expanded(
                  child: _field('CVV', TextEditingController(text: '•••'),
                      Icons.lock_outline, type: TextInputType.number)),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildReviewStep(CartProvider cart) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Order Summary'),
        const SizedBox(height: 16),
        ...cart.items.map((item) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.divider),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: SizedBox(
                      width: 56,
                      height: 56,
                      child: Image.network(item.product.imageUrl, fit: BoxFit.cover),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.product.name,
                            style: const TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.textDark)),
                        Text('${item.selectedSize} | ${item.selectedColor} | Qty: ${item.quantity}',
                            style: AppTextStyles.bodySmall),
                      ],
                    ),
                  ),
                  Text('\$${item.totalPrice.toStringAsFixed(2)}', style: AppTextStyles.priceSmall),
                ],
              ),
            )),
        const SizedBox(height: 16),
        _sectionTitle('Delivery To'),
        const SizedBox(height: 8),
        _infoBox(Icons.location_on_outlined,
            '${_addressCtrl.text}, ${_cityCtrl.text}, ${_zipCtrl.text}'),
        const SizedBox(height: 16),
        _sectionTitle('Payment'),
        const SizedBox(height: 8),
        _infoBox(Icons.payment_rounded, _paymentMethod),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.divider),
          ),
          child: Column(
            children: [
              _totalRow('Subtotal', '\$${cart.subtotal.toStringAsFixed(2)}'),
              const SizedBox(height: 6),
              _totalRow('Shipping', cart.shipping == 0 ? 'FREE' : '\$${cart.shipping.toStringAsFixed(2)}'),
              const Divider(color: AppColors.divider, height: 20),
              _totalRow('Total', '\$${cart.total.toStringAsFixed(2)}', bold: true),
            ],
          ),
        ),
      ],
    );
  }

  Widget _sectionTitle(String title) {
    return Text(title, style: AppTextStyles.headingSmall);
  }

  Widget _field(String label, TextEditingController ctrl, IconData icon,
      {TextInputType type = TextInputType.text}) {
    return TextFormField(
      controller: ctrl,
      keyboardType: type,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppTextStyles.bodySmall,
        prefixIcon: Icon(icon, color: AppColors.primaryLight, size: 20),
        filled: true,
        fillColor: AppColors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.divider)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primary, width: 2)),
        errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.error)),
        focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.error, width: 2)),
      ),
      validator: (v) => (v == null || v.isEmpty) ? 'This field is required' : null,
    );
  }

  Widget _deliveryOption(String title, String subtitle, String price, bool isExpress) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isExpress ? AppColors.accentLight : AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isExpress ? AppColors.primary : AppColors.divider),
      ),
      child: Row(
        children: [
          Icon(
            isExpress ? Icons.rocket_launch_rounded : Icons.local_shipping_outlined,
            color: AppColors.primary,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.textDark)),
                Text(subtitle, style: AppTextStyles.bodySmall),
              ],
            ),
          ),
          Text(price,
              style: const TextStyle(
                  fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.primary)),
        ],
      ),
    );
  }

  Widget _infoBox(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: AppTextStyles.bodyMedium)),
        ],
      ),
    );
  }

  Widget _totalRow(String label, String value, {bool bold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(
                fontSize: bold ? 15 : 13,
                fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
                color: bold ? AppColors.textDark : AppColors.textMedium)),
        Text(value,
            style: TextStyle(
                fontSize: bold ? 16 : 13,
                fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
                color: bold ? AppColors.primary : AppColors.textDark)),
      ],
    );
  }
}
