import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobile_ai_erp/di/service_locator.dart';
import 'package:mobile_ai_erp/presentation/cart/store/cart_store.dart';
import 'package:mobile_ai_erp/presentation/product_detail/store/product_detail_store.dart';
import 'package:mobile_ai_erp/presentation/product_detail/widgets/attributes_table_widget.dart';
import 'package:mobile_ai_erp/presentation/product_detail/widgets/price_stock_widget.dart';
import 'package:mobile_ai_erp/presentation/product_detail/widgets/product_description_widget.dart';
import 'package:mobile_ai_erp/presentation/product_detail/widgets/product_image_gallery.dart';
import 'package:mobile_ai_erp/presentation/product_detail/widgets/reviews_section_widget.dart';
import 'package:mobile_ai_erp/presentation/product_detail/widgets/variant_selector_widget.dart';

const double _kWideBreakpoint = 720;

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({super.key});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final ProductDetailStore _store = getIt<ProductDetailStore>();
  final CartStore _cartStore = getIt<CartStore>();

  int _quantity = 1;
  bool _hasLoadedInitialProduct = false;

  @override
  void initState() {
    super.initState();
  }

  void _onShare() {
    final product = _store.product;
    if (product == null) return;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => _ShareSheet(productName: product.name),
    );
  }

  Future<void> _onAddToCart() async {
    final variant = _store.selectedVariant;
    if (variant == null || !variant.inStock) return;

    final maxQty = variant.stockQuantity;
    if (_quantity > maxQty) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Only $maxQty item(s) available in stock'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    await _cartStore.addToCart(variant.id, _quantity);

    if (!mounted) return;

    if (_cartStore.errorMessage != null) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_cartStore.errorMessage!),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added $_quantity item(s) to cart'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _increaseQuantity() {
    final variant = _store.selectedVariant;
    if (variant == null) return;

    if (_quantity < variant.stockQuantity) {
      setState(() {
        _quantity++;
      });
    }
  }

  void _decreaseQuantity() {
    if (_quantity > 1) {
      setState(() {
        _quantity--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) {
        final product = _store.product;
        final routeProductId =
            ModalRoute.of(context)?.settings.arguments as String?;
        if (!_hasLoadedInitialProduct && routeProductId != null) {
          _hasLoadedInitialProduct = true;
          _store.loadProduct(routeProductId);
        }

        if (routeProductId == null && product == null) {
          return const Scaffold(
            body: Center(
              child: Text('Please open a product from the storefront listing.'),
            ),
          );
        }

        if (_store.isLoading || product == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= _kWideBreakpoint;
            return Scaffold(
              appBar: _buildAppBar(),
              body: isWide ? _buildWideBody() : _buildNarrowBody(),
              bottomNavigationBar: isWide ? null : _buildBottomBar(),
            );
          },
        );
      },
    );
  }

  // -----------------------------------------------------------------------
  // App bar (shared)
  // -----------------------------------------------------------------------

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Observer(
        builder: (_) => Text(
          _store.product?.name ?? '',
          style: const TextStyle(fontSize: 16),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.share_outlined),
          onPressed: _onShare,
        ),
      ],
    );
  }

  // -----------------------------------------------------------------------
  // Narrow / mobile layout — single scrollable column
  // -----------------------------------------------------------------------

  Widget _buildNarrowBody() {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _buildGallery()),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              const SizedBox(height: 16),
              _buildProductHeader(),
              const SizedBox(height: 12),
              _buildRatingRow(),
              const SizedBox(height: 16),
              _buildPriceStock(),
              const SizedBox(height: 24),
              _buildDivider(),
              const SizedBox(height: 16),
              _buildVariantSelector(),
              const SizedBox(height: 20),
              _buildQuantitySelector(),
              const SizedBox(height: 24),
              _buildDivider(),
              const SizedBox(height: 16),
              _buildDescription(),
              const SizedBox(height: 16),
              _buildDivider(),
              const SizedBox(height: 16),
              _buildAttributes(),
              const SizedBox(height: 24),
              _buildDivider(),
              const SizedBox(height: 16),
              _buildReviews(),
              const SizedBox(height: 32),
            ]),
          ),
        ),
      ],
    );
  }

  // -----------------------------------------------------------------------
  // Wide / desktop layout — two-column: left scrollable, right sticky-ish
  // -----------------------------------------------------------------------

  Widget _buildWideBody() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // LEFT — gallery + details (scrollable)
        Expanded(
          flex: 5,
          child: ListView(
            padding: const EdgeInsets.only(bottom: 32),
            children: [
              _buildGallery(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    _buildDescription(),
                    const SizedBox(height: 16),
                    _buildDivider(),
                    const SizedBox(height: 16),
                    _buildAttributes(),
                    const SizedBox(height: 24),
                    _buildDivider(),
                    const SizedBox(height: 16),
                    _buildReviews(),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Vertical divider
        Container(
          width: 1,
          color:
              Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.08),
        ),

        // RIGHT — product info + variant selector + add to cart (scrollable)
        Expanded(
          flex: 4,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
            children: [
              _buildProductHeader(),
              const SizedBox(height: 12),
              _buildRatingRow(),
              const SizedBox(height: 20),
              _buildPriceStock(),
              const SizedBox(height: 28),
              _buildDivider(),
              const SizedBox(height: 20),
              _buildVariantSelector(),
              const SizedBox(height: 20),
              _buildQuantitySelector(),
              const SizedBox(height: 28),
              _buildAddToCartButton(),
            ],
          ),
        ),
      ],
    );
  }

  // -----------------------------------------------------------------------
  // Reusable section builders
  // -----------------------------------------------------------------------

  Widget _buildGallery() {
    return Observer(
      builder: (_) => ProductImageGallery(
        media: _store.product!.media,
        currentIndex: _store.currentImageIndex,
        onPageChanged: _store.setImageIndex,
      ),
    );
  }

  Widget _buildProductHeader() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final product = _store.product!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          product.brandName.toUpperCase(),
          style: theme.textTheme.labelSmall?.copyWith(
            letterSpacing: 1.5,
            color: colorScheme.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          product.name,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
      ],
    );
  }

  Widget _buildRatingRow() {
    final theme = Theme.of(context);
    final product = _store.product!;

    return Row(
      children: [
        ...List.generate(5, (i) {
          final starValue = i + 1;
          if (product.averageRating >= starValue) {
            return const Icon(Icons.star, size: 18, color: Colors.amber);
          } else if (product.averageRating >= starValue - 0.5) {
            return const Icon(Icons.star_half, size: 18, color: Colors.amber);
          } else {
            return const Icon(Icons.star_border, size: 18, color: Colors.amber);
          }
        }),
        const SizedBox(width: 8),
        Text(
          '${product.averageRating}',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          '(${product.reviewCount} reviews)',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            fontSize: 13,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildPriceStock() {
    return Observer(
      builder: (_) => PriceStockWidget(
        price: _store.displayPrice,
        originalPrice: _store.originalPrice,
        discountPercentage: _store.discountPercentage,
        selectedVariant: _store.selectedVariant,
      ),
    );
  }

  Widget _buildVariantSelector() {
    return Observer(
      builder: (_) => VariantSelectorWidget(
        availableColors: _store.availableColors,
        selectedColorName: _store.selectedColorName,
        availableSizes: _store.availableSizes,
        selectedSize: _store.selectedSize,
        isSizeInStock: _store.isSizeInStock,
        isSizeLowStock: _store.isSizeLowStock,
        onColorSelected: (colorName) {
          _store.selectColor(colorName);
          setState(() {
            _quantity = 1;
          });
        },
        onSizeSelected: (size) {
          _store.selectSize(size);
          setState(() {
            _quantity = 1;
          });
        },
      ),
    );
  }

  Widget _buildDescription() {
    return Observer(
      builder: (_) => ProductDescriptionWidget(
        descriptionHtml: _store.product!.descriptionHtml,
        isExpanded: _store.isDescriptionExpanded,
        onToggle: _store.toggleDescription,
      ),
    );
  }

  Widget _buildAttributes() {
    return AttributesTableWidget(
      specifications: _store.product!.specifications,
    );
  }

  Widget _buildReviews() {
    return ReviewsSectionWidget(
      reviews: _store.product!.reviews,
      averageRating: _store.product!.averageRating,
      reviewCount: _store.product!.reviewCount,
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.08),
    );
  }

  // -----------------------------------------------------------------------
  // Add-to-cart button — used in both layouts
  // -----------------------------------------------------------------------

  Widget _buildAddToCartButton() {
    final colorScheme = Theme.of(context).colorScheme;

    return Observer(
      builder: (_) {
        final variant = _store.selectedVariant;
        final canAdd = variant != null &&
            variant.inStock &&
            _quantity > 0 &&
            _quantity <= variant.stockQuantity &&
            !_cartStore.isLoading;

        return Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: canAdd ? _onAddToCart : null,
                  icon: _cartStore.isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.shopping_cart_outlined, size: 20),
                  label: Text(
                    _cartStore.isLoading
                        ? 'Adding...'
                        : canAdd
                            ? 'Add to Cart'
                            : 'Select Options',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor:
                        colorScheme.onSurface.withValues(alpha: 0.12),
                    disabledForegroundColor:
                        colorScheme.onSurface.withValues(alpha: 0.38),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 50,
              height: 50,
              child: Observer(
                builder: (_) => OutlinedButton(
                  onPressed: () {
                    // sau này có thể mở mini cart / navigate cart
                  },
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.zero,
                    side: BorderSide(
                      color: colorScheme.onSurface.withValues(alpha: 0.2),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Badge(
                    isLabelVisible: _cartStore.itemCount > 0,
                    label: Text('${_cartStore.itemCount}'),
                    child: Icon(
                      Icons.shopping_cart,
                      color: colorScheme.onSurface.withValues(alpha: 0.7),
                      size: 22,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildQuantitySelector() {
    final colorScheme = Theme.of(context).colorScheme;

    return Observer(
      builder: (_) {
        final variant = _store.selectedVariant;
        final maxQty = variant?.stockQuantity ?? 0;
        final canIncrease = variant != null && _quantity < maxQty;
        final canDecrease = _quantity > 1;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Quantity',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                SizedBox(
                  width: 44,
                  height: 44,
                  child: OutlinedButton(
                    onPressed: canDecrease ? _decreaseQuantity : null,
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Icon(Icons.remove),
                  ),
                ),
                Container(
                  width: 64,
                  alignment: Alignment.center,
                  child: Text(
                    '$_quantity',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                SizedBox(
                  width: 44,
                  height: 44,
                  child: OutlinedButton(
                    onPressed: canIncrease ? _increaseQuantity : null,
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Icon(Icons.add),
                  ),
                ),
                const SizedBox(width: 12),
                if (variant != null)
                  Text(
                    'Stock: ${variant.stockQuantity}',
                    style: TextStyle(
                      fontSize: 13,
                      color: colorScheme.onSurface.withValues(alpha: 0.65),
                    ),
                  ),
              ],
            ),
          ],
        );
      },
    );
  }

  // -----------------------------------------------------------------------
  // Bottom bar — mobile only
  // -----------------------------------------------------------------------

  Widget _buildBottomBar() {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: 12 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: _buildAddToCartButton(),
    );
  }
}

// =========================================================================
// Share bottom sheet
// =========================================================================

class _ShareSheet extends StatelessWidget {
  final String productName;

  const _ShareSheet({required this.productName});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const mockUrl = 'https://jarvis-erp.vn/products/prod_001';

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Share Product',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _ShareOption(
                  icon: Icons.link,
                  label: 'Copy Link',
                  onTap: () {
                    Clipboard.setData(const ClipboardData(text: mockUrl));
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Link copied to clipboard'),
                        behavior: SnackBarBehavior.floating,
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                ),
                _ShareOption(
                  icon: Icons.message,
                  label: 'Message',
                  onTap: () => Navigator.pop(context),
                ),
                _ShareOption(
                  icon: Icons.facebook,
                  label: 'Facebook',
                  onTap: () => Navigator.pop(context),
                ),
                _ShareOption(
                  icon: Icons.more_horiz,
                  label: 'More',
                  onTap: () => Navigator.pop(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ShareOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ShareOption({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: colorScheme.secondary.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: colorScheme.onSurface),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}
