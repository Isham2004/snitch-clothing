import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../models/product.dart';
import '../../providers/categories_provider.dart';
import '../../providers/favorites_provider.dart';
import '../../providers/products_provider.dart';
import '../main_scaffold.dart';
import 'product_detail_screen.dart';

class ProductListScreen extends StatefulWidget {
  final String? initialCategory;

  const ProductListScreen({super.key, this.initialCategory});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  late String _selectedCategory;
  bool _isGrid = true;
  String _sortBy = 'Default';
  RangeValues _priceRange = const RangeValues(0, 200);

  final List<String> _sortOptions = ['Default', 'Price: Low-High', 'Price: High-Low', 'Top Rated'];

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory ?? 'All';
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<ProductsProvider>().load();
    });
  }

  List<Product> _filterProducts(List<Product> source) {
    var list = _selectedCategory == 'All'
        ? List<Product>.from(source)
        : source.where((p) => p.category == _selectedCategory).toList();
    list = list
        .where((p) =>
            p.price >= _priceRange.start && p.price <= _priceRange.end)
        .toList();
    switch (_sortBy) {
      case 'Price: Low-High':
        list.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'Price: High-Low':
        list.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'Top Rated':
        list.sort((a, b) => b.rating.compareTo(a.rating));
        break;
    }
    return list;
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _FilterSheet(
        priceRange: _priceRange,
        sortBy: _sortBy,
        onApply: (range, sort) {
          setState(() {
            _priceRange = range;
            _sortBy = sort;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final productsProvider = context.watch<ProductsProvider>();
    final categoriesProvider = context.watch<CategoriesProvider>();
    final products = _filterProducts(productsProvider.all);
    final isLoading = productsProvider.isLoading && productsProvider.all.isEmpty;
    final chipCategories = categoriesProvider.all;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: widget.initialCategory != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textDark, size: 20),
                onPressed: () => Navigator.pop(context),
              )
            : IconButton(
                icon: const Icon(Icons.menu_rounded, color: AppColors.textDark),
                onPressed: MainScaffold.openDrawer,
              ),
        title: const Text('Shop', style: AppTextStyles.headingLarge),
        actions: [
          IconButton(
            icon: Icon(
              _isGrid ? Icons.view_list_rounded : Icons.grid_view_rounded,
              color: AppColors.textDark,
            ),
            onPressed: () => setState(() => _isGrid = !_isGrid),
          ),
          IconButton(
            icon: const Icon(Icons.tune_rounded, color: AppColors.primary),
            onPressed: _showFilterSheet,
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: AppColors.white,
            height: 52,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: chipCategories.length,
              itemBuilder: (_, i) {
                final cat = chipCategories[i];
                final isSelected = _selectedCategory == cat;
                return GestureDetector(
                  onTap: () => setState(() => _selectedCategory = cat),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : AppColors.background,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? AppColors.primary : AppColors.divider,
                      ),
                    ),
                    child: Text(
                      cat,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected ? AppColors.white : AppColors.textMedium,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          Container(
            color: AppColors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Text('${products.length} items', style: AppTextStyles.bodySmall),
                const Spacer(),
                const Icon(Icons.sort_rounded, size: 16, color: AppColors.textLight),
                const SizedBox(width: 4),
                DropdownButton<String>(
                  value: _sortBy,
                  underline: const SizedBox(),
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textMedium, fontWeight: FontWeight.w500),
                  icon: const Icon(Icons.arrow_drop_down, color: AppColors.primary, size: 18),
                  items: _sortOptions
                      .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                      .toList(),
                  onChanged: (v) => setState(() => _sortBy = v ?? 'Default'),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          Expanded(
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                        color: AppColors.primary, strokeWidth: 2.5))
                : products.isEmpty
                    ? _buildEmpty()
                    : _isGrid
                        ? _buildGrid(products, screenWidth)
                        : _buildList(products),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 70, color: AppColors.divider),
          SizedBox(height: 14),
          Text('No products found', style: AppTextStyles.headingSmall),
          SizedBox(height: 8),
          Text('Try adjusting your filters', style: AppTextStyles.bodySmall),
        ],
      ),
    );
  }

  Widget _buildGrid(List<Product> products, double screenWidth) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: screenWidth > 600 ? 3 : 2,
        childAspectRatio: 0.65,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: products.length,
      itemBuilder: (_, i) => _ProductGridCard(product: products[i]),
    );
  }

  Widget _buildList(List<Product> products) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: products.length,
      itemBuilder: (_, i) => _ProductListCard(product: products[i]),
    );
  }
}

class _ProductGridCard extends StatelessWidget {
  final Product product;
  const _ProductGridCard({required this.product});

  @override
  Widget build(BuildContext context) {
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
                      children: [
                        Text('\$${product.price.toStringAsFixed(2)}',
                            style: AppTextStyles.priceSmall),
                        if (product.isOnSale) ...[
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              '\$${product.originalPrice!.toStringAsFixed(2)}',
                              style: const TextStyle(
                                  fontSize: 10,
                                  color: AppColors.textLight,
                                  decoration: TextDecoration.lineThrough),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
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
  }
}

class _ProductListCard extends StatelessWidget {
  final Product product;
  const _ProductListCard({required this.product});

  @override
  Widget build(BuildContext context) {
    final isFav = context.watch<FavoritesProvider>().isFavorite(product.id);
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ProductDetailScreen(product: product)),
      ),
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
                width: 110,
                height: 110,
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
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
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
                        style: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textDark),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded, size: 12, color: Color(0xFFFFC107)),
                        const SizedBox(width: 2),
                        Text('${product.rating} (${product.reviewCount})',
                            style: const TextStyle(fontSize: 10, color: AppColors.textLight)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('\$${product.price.toStringAsFixed(2)}',
                                style: AppTextStyles.priceSmall),
                            if (product.isOnSale)
                              Text(
                                '\$${product.originalPrice!.toStringAsFixed(2)}',
                                style: const TextStyle(
                                    fontSize: 10,
                                    color: AppColors.textLight,
                                    decoration: TextDecoration.lineThrough),
                              ),
                          ],
                        ),
                        GestureDetector(
                          onTap: () => context.read<FavoritesProvider>().toggle(product),
                          child: Icon(
                            isFav ? Icons.favorite : Icons.favorite_border,
                            size: 20,
                            color: isFav ? AppColors.error : AppColors.textLight,
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
  }
}

class _FilterSheet extends StatefulWidget {
  final RangeValues priceRange;
  final String sortBy;
  final Function(RangeValues, String) onApply;

  const _FilterSheet({
    required this.priceRange,
    required this.sortBy,
    required this.onApply,
  });

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late RangeValues _priceRange;
  late String _sortBy;

  @override
  void initState() {
    super.initState();
    _priceRange = widget.priceRange;
    _sortBy = widget.sortBy;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Filter & Sort', style: AppTextStyles.headingMedium),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const Divider(),
          const SizedBox(height: 8),
          const Text('Price Range', style: AppTextStyles.headingSmall),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('\$${_priceRange.start.toInt()}', style: AppTextStyles.priceSmall),
              Text('\$${_priceRange.end.toInt()}', style: AppTextStyles.priceSmall),
            ],
          ),
          RangeSlider(
            values: _priceRange,
            min: 0,
            max: 200,
            divisions: 20,
            activeColor: AppColors.primary,
            inactiveColor: AppColors.accentLight,
            onChanged: (v) => setState(() => _priceRange = v),
          ),
          const SizedBox(height: 16),
          const Text('Sort By', style: AppTextStyles.headingSmall),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: ['Default', 'Price: Low-High', 'Price: High-Low', 'Top Rated']
                .map((s) => ChoiceChip(
                      label: Text(s),
                      selected: _sortBy == s,
                      selectedColor: AppColors.accentLight,
                      labelStyle: TextStyle(
                        color: _sortBy == s ? AppColors.primary : AppColors.textMedium,
                        fontWeight: _sortBy == s ? FontWeight.w600 : FontWeight.w400,
                        fontSize: 12,
                      ),
                      onSelected: (_) => setState(() => _sortBy = s),
                    ))
                .toList(),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _priceRange = const RangeValues(0, 200);
                      _sortBy = 'Default';
                    });
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.divider),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Reset', style: TextStyle(color: AppColors.textMedium)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: () {
                    widget.onApply(_priceRange, _sortBy);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: const Text('Apply Filters'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
