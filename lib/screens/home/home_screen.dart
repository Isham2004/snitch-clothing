import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../models/product.dart';

import '../../providers/banners_provider.dart';
import '../../providers/categories_provider.dart';
import '../../providers/favorites_provider.dart';
import '../../providers/products_provider.dart';
import '../main_scaffold.dart';
import '../products/product_list_screen.dart';
import '../products/product_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _bannerController = PageController();
  int _bannerIndex = 0;
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<ProductsProvider>().load();
    });
  }

  @override
  void dispose() {
    _bannerController.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final productsProvider = context.watch<ProductsProvider>();
    final bannersProvider = context.watch<BannersProvider>();
    final categoriesProvider = context.watch<CategoriesProvider>();
    final featured = productsProvider.hasLoaded
        ? productsProvider.featured
        : <Product>[];
    final newArrivals = productsProvider.hasLoaded
        ? productsProvider.newArrivals
        : <Product>[];
    final banners = bannersProvider.all;
    final categories = categoriesProvider.names;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 0,
            floating: true,
            snap: true,
            backgroundColor: AppColors.white,
            elevation: 0,
            leading: IconButton(
              icon: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.menu_rounded,
                    color: AppColors.textDark, size: 22),
              ),
              onPressed: MainScaffold.openDrawer,
            ),
            title: const Text('SNITCH', style: AppTextStyles.brandNameDark),
            centerTitle: true,
            actions: [
              Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_none_rounded, color: AppColors.textDark, size: 26),
                    onPressed: () {},
                  ),
                  Positioned(
                    right: 10,
                    top: 10,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.error,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 4),
            ],
          ),

          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GestureDetector(
                    onTap: () {
                      showSearch(
                        context: context,
                        delegate: _ProductSearchDelegate(
                          context.read<ProductsProvider>(),
                        ),
                      );
                    },
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.divider),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 14),
                          const Icon(Icons.search, color: AppColors.primaryLight, size: 22),
                          const SizedBox(width: 10),
                          Text('Search products, brands…', style: AppTextStyles.bodySmall),
                          const Spacer(),
                          Container(
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.accentLight,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.tune_rounded, color: AppColors.primary, size: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                SizedBox(
                  height: 180,
                  child: PageView.builder(
                    controller: _bannerController,
                    onPageChanged: (i) => setState(() => _bannerIndex = i),
                    itemCount: banners.length,
                    itemBuilder: (_, i) => _buildBanner(banners[i], screenWidth),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(banners.length, (i) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: _bannerIndex == i ? 20 : 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: _bannerIndex == i ? AppColors.primary : AppColors.divider,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    );
                  }),
                ),

                const SizedBox(height: 24),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Categories', style: AppTextStyles.headingMedium),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ProductListScreen(),
                            ),
                          );
                        },
                        child: const Text('See all',
                            style: TextStyle(
                                color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 13)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  height: 90,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: categories.length,
                    itemBuilder: (_, i) {
                      return _buildCategoryItem(categories[i]);
                    },
                  ),
                ),

                const SizedBox(height: 24),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Featured', style: AppTextStyles.headingMedium),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ProductListScreen(),
                            ),
                          );
                        },
                        child: const Text('See all',
                            style: TextStyle(
                                color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 13)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  height: 260,
                  child: productsProvider.isLoading && featured.isEmpty
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primary, strokeWidth: 2.5))
                      : ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          itemCount: featured.length,
                          itemBuilder: (_, i) => _buildProductCardH(featured[i]),
                        ),
                ),

                const SizedBox(height: 24),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    height: 100,
                    decoration: BoxDecoration(
                      gradient: AppColors.cardGradient,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('Free Shipping',
                                  style: TextStyle(
                                      color: AppColors.white,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 18)),
                              const SizedBox(height: 4),
                              Text('On orders over \$100',
                                  style: TextStyle(
                                      color: AppColors.white.withOpacity(0.85), fontSize: 12)),
                            ],
                          ),
                        ),
                        const Icon(Icons.local_shipping_rounded, color: AppColors.white, size: 48),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('New Arrivals', style: AppTextStyles.headingMedium),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ProductListScreen(),
                            ),
                          );
                        },
                        child: const Text('See all',
                            style: TextStyle(
                                color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 13)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                if (productsProvider.isLoading && newArrivals.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 30),
                    child: Center(
                      child: CircularProgressIndicator(
                          color: AppColors.primary, strokeWidth: 2.5),
                    ),
                  )
                else
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: screenWidth > 600 ? 3 : 2,
                      childAspectRatio: 0.68,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: newArrivals.length,
                    itemBuilder: (_, i) => _buildProductCardV(newArrivals[i]),
                  ),

                const SizedBox(height: 80),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBanner(BannerItem banner, double screenWidth) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const ProductListScreen(),
            ),
          );
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                banner.image,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(
                  decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerRight,
                    end: Alignment.centerLeft,
                    colors: [
                      AppColors.primaryDark.withOpacity(0.85),
                      AppColors.primaryDark.withOpacity(0.2),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 20,
                bottom: 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.accent,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        banner.tag,
                        style: const TextStyle(
                            color: AppColors.white, fontSize: 10, fontWeight: FontWeight.w700),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      banner.title,
                      style: const TextStyle(
                          color: AppColors.white, fontSize: 22, fontWeight: FontWeight.w800),
                    ),
                    Text(
                      banner.subtitle,
                      style: TextStyle(color: AppColors.white.withOpacity(0.85), fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryItem(String category) {
    final icons = {
      'T-Shirts': Icons.dry_cleaning_rounded,
      'Shirts': Icons.checkroom_rounded,
      'Jackets': Icons.add_rounded,
      'Hoodies': Icons.ac_unit_rounded,
      'Pants': Icons.straighten_rounded,
      'Shorts': Icons.reduce_capacity_rounded,
      'Accessories': Icons.watch_rounded,
    };
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductListScreen(initialCategory: category),
          ),
        );
      },
      child: Container(
        width: 72,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadow,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                icons[category] ?? Icons.category_rounded,
                color: AppColors.primary,
                size: 26,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              category,
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: AppColors.textMedium),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCardH(Product product) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ProductDetailScreen(product: product)),
      ),
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 12),
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
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: SizedBox(
                height: 160,
                width: double.infinity,
                child: Image.network(
                  product.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    color: AppColors.accentLight,
                    child: const Icon(Icons.image, color: AppColors.primaryLight, size: 40),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (product.tag != null)
                    Container(
                      margin: const EdgeInsets.only(bottom: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: product.tag == 'SALE' ? AppColors.error.withOpacity(0.1) : AppColors.accentLight,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        product.tag!,
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: product.tag == 'SALE' ? AppColors.error : AppColors.primary,
                        ),
                      ),
                    ),
                  Text(product.name,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textDark),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text('\$${product.price.toStringAsFixed(2)}', style: AppTextStyles.priceSmall),
                      if (product.isOnSale) ...[
                        const SizedBox(width: 4),
                        Text(
                          '\$${product.originalPrice!.toStringAsFixed(2)}',
                          style: const TextStyle(
                              fontSize: 10,
                              color: AppColors.textLight,
                              decoration: TextDecoration.lineThrough),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCardV(Product product) {
    final isFav = context.watch<FavoritesProvider>().isFavorite(product.id);
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
                      onTap: () => context.read<FavoritesProvider>().toggle(product),
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 6),
                          ],
                        ),
                        child: Icon(
                          isFav ? Icons.favorite : Icons.favorite_border,
                          size: 16,
                          color: isFav ? AppColors.error : AppColors.textLight,
                        ),
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
                          style: const TextStyle(color: AppColors.white, fontSize: 8, fontWeight: FontWeight.w700),
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
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textDark),
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
                    Text('\$${product.price.toStringAsFixed(2)}', style: AppTextStyles.priceSmall),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductSearchDelegate extends SearchDelegate<Product?> {
  final ProductsProvider productsProvider;
  _ProductSearchDelegate(this.productsProvider);

  @override
  String get searchFieldLabel => 'Search products…';

  @override
  ThemeData appBarTheme(BuildContext context) {
    return Theme.of(context).copyWith(
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.textDark,
        elevation: 0,
      ),
      inputDecorationTheme: const InputDecorationTheme(border: InputBorder.none),
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) => [
        IconButton(icon: const Icon(Icons.clear), onPressed: () => query = ''),
      ];

  @override
  Widget buildLeading(BuildContext context) => IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, size: 18),
        onPressed: () => close(context, null),
      );

  @override
  Widget buildResults(BuildContext context) => _buildSearchResults();

  @override
  Widget buildSuggestions(BuildContext context) => _buildSearchResults();

  Widget _buildSearchResults() {
    final results = productsProvider.search(query);
    if (results.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 60, color: AppColors.divider),
            SizedBox(height: 12),
            Text('No products found', style: AppTextStyles.bodyMedium),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: results.length,
      itemBuilder: (ctx, i) {
        final p = results[i];
        return ListTile(
          onTap: () {
            close(ctx, p);
            Navigator.push(ctx, MaterialPageRoute(builder: (_) => ProductDetailScreen(product: p)));
          },
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 48,
              height: 48,
              child: Image.network(p.imageUrl, fit: BoxFit.cover),
            ),
          ),
          title: Text(p.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          subtitle: Text(p.category, style: AppTextStyles.bodySmall),
          trailing: Text('\$${p.price.toStringAsFixed(2)}', style: AppTextStyles.priceSmall),
        );
      },
    );
  }
}
