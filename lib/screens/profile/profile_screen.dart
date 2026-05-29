import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../models/user_profile.dart';
import '../../providers/user_provider.dart';
import '../auth/login_screen.dart';
import '../favorites/favorites_screen.dart';
import '../main_scaffold.dart';
import '../orders/orders_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu_rounded, color: AppColors.textDark),
          onPressed: MainScaffold.openDrawer,
        ),
        title: const Text('Profile', style: AppTextStyles.headingLarge),
        centerTitle: true,
        actions: [
          if (user.isLoggedIn)
            IconButton(
              icon: const Icon(Icons.edit_outlined, color: AppColors.primary),
              onPressed: () => _showEditDialog(context, user),
            ),
        ],
      ),
      body: user.isLoggedIn ? _buildLoggedIn(context, user) : _buildGuest(context),
    );
  }

  Widget _buildLoggedIn(BuildContext context, UserProvider user) {
    final profile = user.profile;
    return SingleChildScrollView(
      child: Column(
        children: [
          if (user.firestoreWarning != null)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.warning),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded,
                      color: AppColors.warning, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      user.firestoreWarning!,
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textDark),
                    ),
                  ),
                ],
              ),
            ),
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
            ),
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
            child: Column(
              children: [
                Stack(
                  children: [
                    Builder(builder: (_) {
                      final hasAvatar = profile.avatarUrl.isNotEmpty;
                      return CircleAvatar(
                        radius: 50,
                        backgroundColor: AppColors.accentLight,
                        backgroundImage:
                            hasAvatar ? NetworkImage(profile.avatarUrl) : null,
                        onBackgroundImageError: hasAvatar ? (_, _) {} : null,
                        child: hasAvatar
                            ? null
                            : const Icon(Icons.person,
                                color: AppColors.primary, size: 44),
                      );
                    }),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: () => _uploadAvatar(context, user),
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.camera_alt_rounded, color: AppColors.white, size: 16),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(profile.name, style: AppTextStyles.headingLarge),
                const SizedBox(height: 4),
                Text(profile.email, style: AppTextStyles.bodyMedium),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _stat('${user.orders.length}', 'Orders'),
                    Container(width: 1, height: 32, color: AppColors.divider),
                    _stat('0', 'Reviews'),
                    Container(width: 1, height: 32, color: AppColors.divider),
                    _stat('0', 'Points'),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          _sectionCard([
            _infoRow(Icons.person_outline, 'Name', profile.name),
            const Divider(color: AppColors.divider, height: 1),
            _infoRow(Icons.email_outlined, 'Email', profile.email),
            const Divider(color: AppColors.divider, height: 1),
            _infoRow(Icons.phone_outlined, 'Phone',
                profile.phone.isEmpty ? 'Not set' : profile.phone),
            const Divider(color: AppColors.divider, height: 1),
            _infoRow(Icons.location_on_outlined, 'Address',
                profile.address.isEmpty ? 'Not set' : profile.address),
          ]),

          const SizedBox(height: 12),

          _menuCard([
            _menuItem(
              icon: Icons.receipt_long_rounded,
              label: 'My Orders',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const OrdersScreen()),
              ),
            ),
            _menuItem(
              icon: Icons.favorite_outline_rounded,
              label: 'Wishlist',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FavoritesScreen()),
              ),
            ),
            _menuItem(
              icon: Icons.location_on_outlined,
              label: 'Saved Addresses',
              onTap: () => _openAddresses(context, user),
            ),
            _menuItem(
              icon: Icons.lock_outline,
              label: 'Change Password',
              onTap: () => _openChangePassword(context, user),
            ),
          ]),

          const SizedBox(height: 12),

          _menuCard([
            _menuItem(
              icon: Icons.notifications_outlined,
              label: 'Notifications',
              onTap: () {},
              trailing: Switch(
                value: true,
                onChanged: (_) {},
                activeThumbColor: AppColors.primary,
              ),
            ),
            _menuItem(
              icon: Icons.language_rounded,
              label: 'Language',
              onTap: () {},
              value: 'English',
            ),
            _menuItem(
              icon: Icons.help_outline_rounded,
              label: 'Help & Support',
              onTap: () {},
            ),
            _menuItem(
              icon: Icons.info_outline_rounded,
              label: 'About Snitch',
              onTap: () {},
            ),
          ]),

          const SizedBox(height: 16),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () async {
                  await user.logout();
                  if (!context.mounted) return;
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                },
                icon: const Icon(Icons.logout_rounded, size: 18),
                label: const Text('Logout', style: AppTextStyles.buttonText),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  foregroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
              ),
            ),
          ),

          const SizedBox(height: 32),
          const Text('Snitch Clothing v1.0.0', style: AppTextStyles.caption),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildGuest(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: const BoxDecoration(
                color: AppColors.accentLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person_outline, size: 54, color: AppColors.primary),
            ),
            const SizedBox(height: 24),
            const Text('You\'re not signed in', style: AppTextStyles.headingMedium),
            const SizedBox(height: 10),
            const Text(
              'Sign in to access your profile, orders, and more.',
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: const Text('Sign In', style: AppTextStyles.buttonText),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _stat(String value, String label) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(
                fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.primary)),
        const SizedBox(height: 2),
        Text(label, style: AppTextStyles.bodySmall),
      ],
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: 14),
          Text(label,
              style: const TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textLight)),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textDark),
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _menuItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    String? value,
    Widget? trailing,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: AppColors.accentLight,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppColors.primary, size: 20),
      ),
      title: Text(label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textDark)),
      trailing: trailing ??
          (value != null
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(value, style: AppTextStyles.bodySmall),
                    const SizedBox(width: 4),
                    const Icon(Icons.arrow_forward_ios, size: 13, color: AppColors.textLight),
                  ],
                )
              : const Icon(Icons.arrow_forward_ios, size: 13, color: AppColors.textLight)),
      horizontalTitleGap: 10,
    );
  }

  Widget _sectionCard(List<Widget> children) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: AppColors.shadow, blurRadius: 8, offset: const Offset(0, 2)),
          ],
        ),
        child: Column(children: children),
      ),
    );
  }

  Widget _menuCard(List<Widget> children) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: AppColors.shadow, blurRadius: 8, offset: const Offset(0, 2)),
          ],
        ),
        child: Column(
          children: children
              .expand((w) => [w, const Divider(color: AppColors.divider, height: 1)])
              .take(children.length * 2 - 1)
              .toList(),
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context, UserProvider user) {
    final nameCtrl = TextEditingController(text: user.profile.name);
    final phoneCtrl = TextEditingController(text: user.profile.phone);
    final addressCtrl = TextEditingController(text: user.profile.address);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Edit Profile', style: AppTextStyles.headingMedium),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
              ],
            ),
            const SizedBox(height: 16),
            _editField('Name', nameCtrl, Icons.person_outline),
            const SizedBox(height: 12),
            _editField('Phone', phoneCtrl, Icons.phone_outlined, type: TextInputType.phone),
            const SizedBox(height: 12),
            _editField('Address', addressCtrl, Icons.location_on_outlined),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  user.updateProfile(
                    name: nameCtrl.text.trim(),
                    phone: phoneCtrl.text.trim(),
                    address: addressCtrl.text.trim(),
                  );
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: const Text('Save Changes'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _editField(String label, TextEditingController ctrl, IconData icon,
      {TextInputType type = TextInputType.text, bool obscure = false}) {
    return TextField(
      controller: ctrl,
      keyboardType: type,
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppTextStyles.bodySmall,
        prefixIcon: Icon(icon, color: AppColors.primaryLight, size: 20),
        filled: true,
        fillColor: AppColors.background,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.divider)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primary, width: 2)),
      ),
    );
  }

  Future<void> _uploadAvatar(BuildContext context, UserProvider user) async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 75,
        maxWidth: 800,
      );
      if (picked == null) return;
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Uploading photo…')),
      );
      await user.updateAvatar(File(picked.path));
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile photo updated'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Photo upload failed: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _openChangePassword(BuildContext context, UserProvider user) {
    final currentCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool busy = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx, setBs) {
          return Container(
            decoration: const BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: EdgeInsets.only(
              left: 24,
              right: 24,
              top: 24,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
            ),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Change Password',
                          style: AppTextStyles.headingMedium),
                      IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(ctx)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: currentCtrl,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Current Password',
                      labelStyle: AppTextStyles.bodySmall,
                      prefixIcon: const Icon(Icons.lock_outline,
                          color: AppColors.primaryLight, size: 20),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.divider)),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                              color: AppColors.primary, width: 2)),
                    ),
                    validator: (v) => (v == null || v.isEmpty)
                        ? 'Enter your current password'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: newCtrl,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'New Password',
                      labelStyle: AppTextStyles.bodySmall,
                      prefixIcon: const Icon(Icons.lock_reset_outlined,
                          color: AppColors.primaryLight, size: 20),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.divider)),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                              color: AppColors.primary, width: 2)),
                    ),
                    validator: (v) => (v == null || v.length < 6)
                        ? 'Password must be at least 6 characters'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: confirmCtrl,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Confirm New Password',
                      labelStyle: AppTextStyles.bodySmall,
                      prefixIcon: const Icon(Icons.lock_outline,
                          color: AppColors.primaryLight, size: 20),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.divider)),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                              color: AppColors.primary, width: 2)),
                    ),
                    validator: (v) => v != newCtrl.text
                        ? 'Passwords do not match'
                        : null,
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: busy
                          ? null
                          : () async {
                              if (!formKey.currentState!.validate()) return;
                              setBs(() => busy = true);
                              try {
                                await user.changePassword(
                                  currentPassword: currentCtrl.text,
                                  newPassword: newCtrl.text,
                                );
                                if (!ctx.mounted) return;
                                Navigator.pop(ctx);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Password updated'),
                                    backgroundColor: AppColors.success,
                                  ),
                                );
                              } catch (e) {
                                if (!ctx.mounted) return;
                                setBs(() => busy = false);
                                ScaffoldMessenger.of(ctx).showSnackBar(
                                  SnackBar(
                                    content: Text(e.toString()),
                                    backgroundColor: AppColors.error,
                                  ),
                                );
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: busy
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2.5))
                          : const Text('Update Password'),
                    ),
                  ),
                ],
              ),
            ),
          );
        });
      },
    );
  }

  void _openAddresses(BuildContext context, UserProvider user) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const _AddressesScreen()),
    );
  }
}

class _AddressesScreen extends StatelessWidget {
  const _AddressesScreen();

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>();
    final list = user.addresses;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: const Text('Saved Addresses', style: AppTextStyles.headingLarge),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: AppColors.textDark, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: list.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.location_off_outlined,
                      size: 70, color: AppColors.divider),
                  SizedBox(height: 12),
                  Text('No saved addresses',
                      style: AppTextStyles.headingMedium),
                  SizedBox(height: 6),
                  Text('Add an address for faster checkout',
                      style: AppTextStyles.bodyMedium),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: list.length,
              itemBuilder: (_, i) {
                final addr = list[i];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: addr.isDefault
                          ? AppColors.primary
                          : AppColors.divider,
                      width: addr.isDefault ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.accentLight,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.location_on_outlined,
                            color: AppColors.primary, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(addr.label,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textDark,
                                        fontSize: 14)),
                                if (addr.isDefault) ...[
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Text('DEFAULT',
                                        style: TextStyle(
                                            color: AppColors.white,
                                            fontSize: 9,
                                            fontWeight: FontWeight.w800)),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(addr.fullName, style: AppTextStyles.bodySmall),
                            Text(addr.phone, style: AppTextStyles.bodySmall),
                            Text(addr.formatted,
                                style: AppTextStyles.bodyMedium),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit_outlined,
                            color: AppColors.primary, size: 20),
                        onPressed: () => _showAddressSheet(context, user,
                            existing: addr),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline,
                            color: AppColors.error, size: 20),
                        onPressed: () async {
                          await user.deleteAddress(addr.id);
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add Address'),
        onPressed: () => _showAddressSheet(context, user),
      ),
    );
  }

  void _showAddressSheet(BuildContext context, UserProvider user,
      {DeliveryAddress? existing}) {
    final labelCtrl = TextEditingController(text: existing?.label ?? 'Home');
    final nameCtrl =
        TextEditingController(text: existing?.fullName ?? user.profile.name);
    final phoneCtrl =
        TextEditingController(text: existing?.phone ?? user.profile.phone);
    final streetCtrl = TextEditingController(text: existing?.street ?? '');
    final cityCtrl = TextEditingController(text: existing?.city ?? '');
    final zipCtrl = TextEditingController(text: existing?.zip ?? '');
    bool isDefault = existing?.isDefault ?? user.addresses.isEmpty;
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx, setBs) {
          return Container(
            decoration: const BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
            ),
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(existing == null ? 'Add Address' : 'Edit Address',
                            style: AppTextStyles.headingMedium),
                        IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.pop(ctx)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _addrField('Label', labelCtrl, Icons.label_outline),
                    const SizedBox(height: 10),
                    _addrField('Full Name', nameCtrl, Icons.person_outline,
                        required: true),
                    const SizedBox(height: 10),
                    _addrField('Phone', phoneCtrl, Icons.phone_outlined,
                        type: TextInputType.phone, required: true),
                    const SizedBox(height: 10),
                    _addrField('Street', streetCtrl,
                        Icons.location_on_outlined,
                        required: true),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                            child: _addrField(
                                'City', cityCtrl, Icons.location_city_outlined,
                                required: true)),
                        const SizedBox(width: 10),
                        Expanded(
                            child: _addrField(
                                'ZIP', zipCtrl, Icons.pin_drop_outlined,
                                type: TextInputType.number, required: true)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Checkbox(
                          value: isDefault,
                          activeColor: AppColors.primary,
                          onChanged: (v) =>
                              setBs(() => isDefault = v ?? false),
                        ),
                        const Text('Set as default address',
                            style: AppTextStyles.bodyMedium),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (!formKey.currentState!.validate()) return;
                          final addr = DeliveryAddress(
                            id: existing?.id ?? '',
                            label: labelCtrl.text.trim(),
                            fullName: nameCtrl.text.trim(),
                            phone: phoneCtrl.text.trim(),
                            street: streetCtrl.text.trim(),
                            city: cityCtrl.text.trim(),
                            zip: zipCtrl.text.trim(),
                            isDefault: isDefault,
                          );
                          try {
                            if (existing == null) {
                              await user.addAddress(addr);
                            } else {
                              await user.updateAddress(addr);
                            }
                            if (!ctx.mounted) return;
                            Navigator.pop(ctx);
                          } catch (e) {
                            if (!ctx.mounted) return;
                            ScaffoldMessenger.of(ctx).showSnackBar(
                              SnackBar(
                                content: Text('Failed to save: $e'),
                                backgroundColor: AppColors.error,
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        child: Text(existing == null ? 'Save Address' : 'Update'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
      },
    );
  }

  Widget _addrField(String label, TextEditingController ctrl, IconData icon,
      {TextInputType type = TextInputType.text, bool required = false}) {
    return TextFormField(
      controller: ctrl,
      keyboardType: type,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppTextStyles.bodySmall,
        prefixIcon: Icon(icon, color: AppColors.primaryLight, size: 20),
        filled: true,
        fillColor: AppColors.background,
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.divider)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primary, width: 2)),
      ),
      validator: required
          ? (v) => (v == null || v.trim().isEmpty)
              ? 'This field is required'
              : null
          : null,
    );
  }
}
