import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../providers/cart_provider.dart';
import '../providers/favorites_provider.dart';
import '../providers/user_provider.dart';
import 'auth/login_screen.dart';
import 'home/home_screen.dart';
import 'cart/cart_screen.dart';
import 'favorites/favorites_screen.dart';
import 'profile/profile_screen.dart';
import 'products/product_list_screen.dart';
import 'orders/orders_screen.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  static final GlobalKey<ScaffoldState> scaffoldKey =
      GlobalKey<ScaffoldState>();

  static void openDrawer() {
    scaffoldKey.currentState?.openDrawer();
  }

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    HomeScreen(),
    ProductListScreen(),
    FavoritesScreen(),
    CartScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final cartCount = context.watch<CartProvider>().itemCount;
    final favCount = context.watch<FavoritesProvider>().count;
    final user = context.watch<UserProvider>();

    return Scaffold(
      key: MainScaffold.scaffoldKey,
      drawer: _buildDrawer(context, user),
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: _buildBottomNav(cartCount, favCount),
    );
  }

  Widget _buildBottomNav(int cartCount, int favCount) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _navItem(0, Icons.home_rounded, Icons.home_outlined, 'Home', 0),
              _navItem(1, Icons.grid_view_rounded, Icons.grid_view_outlined, 'Shop', 0),
              _navItem(2, Icons.favorite_rounded, Icons.favorite_border_rounded, 'Saved', favCount),
              _navItem(3, Icons.shopping_bag_rounded, Icons.shopping_bag_outlined, 'Cart', cartCount),
              _navItem(4, Icons.person_rounded, Icons.person_outline_rounded, 'Profile', 0),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(int index, IconData activeIcon, IconData inactiveIcon, String label, int badge) {
    final isActive = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppColors.accentLight : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  isActive ? activeIcon : inactiveIcon,
                  color: isActive ? AppColors.primary : AppColors.textLight,
                  size: 24,
                ),
                if (badge > 0)
                  Positioned(
                    right: -8,
                    top: -4,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: AppColors.error,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                      child: Text(
                        badge > 9 ? '9+' : '$badge',
                        style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
                color: isActive ? AppColors.primary : AppColors.textLight,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context, UserProvider user) {
    return Drawer(
      backgroundColor: AppColors.white,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            height: 220,
            decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    Builder(builder: (_) {
                      final hasAvatar = user.isLoggedIn &&
                          user.profile.avatarUrl.isNotEmpty;
                      return CircleAvatar(
                        radius: 38,
                        backgroundColor: AppColors.white.withOpacity(0.2),
                        backgroundImage:
                            hasAvatar ? NetworkImage(user.profile.avatarUrl) : null,
                        onBackgroundImageError: hasAvatar ? (_, _) {} : null,
                        child: hasAvatar
                            ? null
                            : const Icon(Icons.person,
                                color: AppColors.white, size: 38),
                      );
                    }),
                    const SizedBox(height: 12),
                    Text(
                      user.isLoggedIn ? user.profile.name : 'Guest',
                      style: const TextStyle(
                          color: AppColors.white, fontSize: 18, fontWeight: FontWeight.w700),
                    ),
                    Text(
                      user.isLoggedIn ? user.profile.email : 'Sign in to access your account',
                      style: TextStyle(color: AppColors.white.withOpacity(0.8), fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 8),

          _drawerItem(Icons.home_rounded, 'Home', () => _navigate(0)),
          _drawerItem(Icons.grid_view_rounded, 'Shop All', () => _navigate(1)),
          _drawerItem(Icons.favorite_rounded, 'Favorites', () => _navigate(2)),
          _drawerItem(Icons.shopping_bag_rounded, 'Cart', () => _navigate(3)),

          const Divider(color: AppColors.divider, indent: 16, endIndent: 16),

          _drawerItem(Icons.receipt_long_rounded, 'My Orders', () {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (_) => const OrdersScreen()));
          }),
          _drawerItem(Icons.person_rounded, 'Profile', () => _navigate(4)),

          const Divider(color: AppColors.divider, indent: 16, endIndent: 16),

          _drawerItem(Icons.info_outline_rounded, 'About Snitch', () {
            Navigator.pop(context);
            _showAboutSheet(context);
          }),
          _drawerItem(Icons.help_outline_rounded, 'Help & Support', () {
            Navigator.pop(context);
            _showHelpSheet(context);
          }),

          const SizedBox(height: 16),

          if (user.isLoggedIn)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ElevatedButton.icon(
                onPressed: () async {
                  Navigator.pop(context);
                  await user.logout();
                  if (!context.mounted) return;
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                },
                icon: const Icon(Icons.logout_rounded, size: 18),
                label: const Text('Logout'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  foregroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                  minimumSize: const Size(double.infinity, 46),
                ),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
                },
                icon: const Icon(Icons.login_rounded, size: 18),
                label: const Text('Sign In'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                  minimumSize: const Size(double.infinity, 46),
                ),
              ),
            ),

          const SizedBox(height: 20),
          Center(
            child: Text('Snitch Clothing © 2026', style: AppTextStyles.caption),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  void _navigate(int index) {
    Navigator.pop(context);
    Navigator.of(context).popUntil((route) => route.isFirst);
    setState(() => _currentIndex = index);
  }

  void _showAboutSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.storefront_rounded,
                      color: AppColors.white, size: 26),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text('About Snitch', style: AppTextStyles.headingLarge),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Snitch Clothing is your destination for premium streetwear and '
              'everyday essentials. Built for those who want to wear their story.',
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(height: 12),
            const Text('Version 1.0.0', style: AppTextStyles.caption),
            const SizedBox(height: 4),
            const Text('© 2026 Snitch Clothing', style: AppTextStyles.caption),
          ],
        ),
      ),
    );
  }

  void _showHelpSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Help & Support', style: AppTextStyles.headingLarge),
            const SizedBox(height: 14),
            _helpRow(Icons.email_outlined, 'Email',
                'support@snitchclothing.com'),
            const Divider(color: AppColors.divider, height: 24),
            _helpRow(Icons.phone_outlined, 'Phone', '+1 (800) 555-1234'),
            const Divider(color: AppColors.divider, height: 24),
            _helpRow(Icons.access_time_rounded, 'Hours',
                'Mon–Fri, 9am – 6pm (EST)'),
            const SizedBox(height: 16),
            const Text(
              'Have a question or an issue with your order? Get in touch and '
              'our team will be glad to help.',
              style: AppTextStyles.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _helpRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: AppColors.accentLight,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textLight,
                      fontWeight: FontWeight.w500)),
              Text(value,
                  style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textDark,
                      fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _drawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: AppColors.accentLight,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppColors.primary, size: 20),
      ),
      title: Text(title,
          style: const TextStyle(
              fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textDark)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 13, color: AppColors.textLight),
      onTap: onTap,
      horizontalTitleGap: 10,
    );
  }
}
