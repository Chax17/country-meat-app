import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/mock_data.dart';
import '../../models/product.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import 'widgets/product_cards.dart';

class CustDetailScreen extends StatefulWidget {
  final String productId;
  final void Function(String screen, {String? param}) nav;
  final void Function(Product p) openModal;
  const CustDetailScreen({
    super.key,
    required this.productId,
    required this.nav,
    required this.openModal,
  });

  @override
  State<CustDetailScreen> createState() => _CustDetailScreenState();
}

class _CustDetailScreenState extends State<CustDetailScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _descExpanded = false;

  @override
  void didUpdateWidget(CustDetailScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.productId != widget.productId) {
      setState(() {
        _descExpanded = false;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToTop();
      });
    }
  }

  void _scrollToTop() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = kAllProducts.firstWhere(
      (x) => x.id == widget.productId,
      orElse: () => kProducts['chicken']![0],
    );
    final related = (kProducts[p.category] ?? kProducts['chicken']!)
        .where((x) => x.id != p.id)
        .take(4)
        .toList();
    final appState = context.watch<AppState>();

    final topInset = MediaQuery.of(context).padding.top;
    final overlayTop = topInset > 0 ? topInset + 8 : 16.0;

    return Stack(
      children: [
        ListView(
          controller: _scrollController,
          padding: const EdgeInsets.only(top: 0, bottom: 96),
          children: [
            // ── Hero Image Tile ──────────────────────────────────────────────
            _ProductHeroTile(
              product: p,
              onBack: () => widget.nav('back'),
              onWishlist: () => showAppToast(context, 'Added to wishlist! ❤️'),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tags
                  Wrap(children: p.tags.map((t) => TagBadge(label: t)).toList()),
                  const SizedBox(height: 8),
                  // Name
                  Text(
                    p.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: AppColors.gray900,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    p.sub,
                    style: const TextStyle(
                      color: AppColors.gray600,
                      fontSize: 13.5,
                      height: 1.3,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Meta grid
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                    decoration: BoxDecoration(
                      color: AppColors.gray50,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(color: AppColors.gray200.withOpacity(0.5)),
                    ),
                    child: Row(
                      children: [
                        Expanded(child: _MetaItem(icon: '⏱️', label: 'Age', val: p.age)),
                        _vDivider(),
                        Expanded(child: _MetaItem(icon: '👥', label: 'Serves', val: p.serves)),
                        _vDivider(),
                        Expanded(child: _MetaItem(icon: '⚖️', label: 'Weight', val: p.weight)),
                        _vDivider(),
                        Expanded(child: _MetaItem(icon: '🐓', label: 'Gender', val: p.gender)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  // Price row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '₹${p.price}',
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              color: AppColors.gray900,
                              letterSpacing: -0.5,
                            ),
                          ),
                          Row(
                            children: [
                              Text(
                                '₹${p.mrp}',
                                style: const TextStyle(
                                  color: AppColors.gray400,
                                  decoration: TextDecoration.lineThrough,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Save ₹${p.mrp - p.price}',
                                style: const TextStyle(
                                  color: AppColors.success,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12.5,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const Spacer(),
                      ElevatedButton(
                        onPressed: () => widget.openModal(p),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
                        ),
                        child: const Text('Add to Cart +'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Description
                  GestureDetector(
                    onTap: () => setState(() => _descExpanded = !_descExpanded),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'About this Product',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 15.5,
                            color: AppColors.gray900,
                          ),
                        ),
                        const SizedBox(height: 8),
                        AnimatedCrossFade(
                          firstChild: Text(
                            p.desc,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.gray700,
                              height: 1.6,
                              fontSize: 14,
                            ),
                          ),
                          secondChild: Text(
                            p.desc,
                            style: const TextStyle(
                              color: AppColors.gray700,
                              height: 1.6,
                              fontSize: 14,
                            ),
                          ),
                          crossFadeState: _descExpanded
                              ? CrossFadeState.showSecond
                              : CrossFadeState.showFirst,
                          duration: const Duration(milliseconds: 250),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _descExpanded ? 'Show less ↑' : 'Read more ↓',
                          style: const TextStyle(
                            color: AppColors.brandRed,
                            fontWeight: FontWeight.w700,
                            fontSize: 12.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  // Health benefits
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.successLight.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(color: AppColors.success.withOpacity(0.15)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '🌿 Health Benefits',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 14.5,
                            color: AppColors.gray900,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...p.benefits.map((b) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.check_circle_rounded,
                                size: 16,
                                color: AppColors.success,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  b,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: AppColors.gray700,
                                    height: 1.45,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  // Delivery info
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.infoLight,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: const Row(
                      children: [
                        Text('🚚', style: TextStyle(fontSize: 22)),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Free Delivery',
                                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                              Text('Order before midnight, get by 6AM–9AM tomorrow',
                                  style: TextStyle(color: AppColors.gray600, fontSize: 11.5)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text('You May Also Like',
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                ],
              ),
            ),
            // Related products
            SizedBox(
              height: 220,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: related.map((r) => ProductCardHorizontal(
                  p: r,
                  onTap: () => widget.nav('detail', param: r.id),
                  onAdd: () {
                    appState.addToCart(r);
                    showAppToast(context, 'Added to cart! 🛒');
                  },
                )).toList(),
              ),
            ),
          ],
        ),
        // ── View Cart Bar ────────────────────────────────────────────────────
        if (appState.cartCount > 0)
          Positioned(
            left: 0, right: 0, bottom: 0,
            child: GestureDetector(
              onTap: () => widget.nav('cart'),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                decoration: const BoxDecoration(
                  gradient: AppGradients.brandRed,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${appState.cartCount} item${appState.cartCount != 1 ? 's' : ''} · ₹${appState.cartTotal}',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                    const Row(children: [
                      Text('View Cart',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14)),
                      SizedBox(width: 4),
                      Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 14),
                    ]),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _vDivider() => Container(width: 1, height: 32, color: AppColors.gray200, margin: const EdgeInsets.symmetric(horizontal: 6));
}

class _CircleBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _CircleBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38, height: 38,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: AppShadows.subtle,
        ),
        alignment: Alignment.center,
        child: Icon(icon, size: 16, color: AppColors.gray700),
      ),
    );
  }
}

class _MetaItem extends StatelessWidget {
  final String icon, label, val;
  const _MetaItem({required this.icon, required this.label, required this.val});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(icon, style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 10, color: AppColors.gray400)),
          Text(val,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _ProductHeroTile extends StatelessWidget {
  final Product product;
  final VoidCallback onBack;
  final VoidCallback onWishlist;

  const _ProductHeroTile({
    required this.product,
    required this.onBack,
    required this.onWishlist,
  });

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;
    final overlayTop = topInset > 0 ? topInset + 8 : 16.0;

    return Stack(
      children: [
        // ── Fixed Responsive Hero AspectRatio Viewport ─────────────────────
        AspectRatio(
          aspectRatio: 1.5,
          child: SizedBox(
            width: double.infinity,
            child: ClipRect(
              child: Image.asset(
                product.img,
                width: double.infinity,
                fit: BoxFit.cover,
                alignment: Alignment.center,
              ),
            ),
          ),
        ),
        // ── Overlay Controls ────────────────────────────────────────────────
        Positioned(
          top: overlayTop,
          left: 12,
          child: _CircleBtn(
            icon: Icons.arrow_back_ios_new_rounded,
            onTap: onBack,
          ),
        ),
        Positioned(
          top: overlayTop,
          right: 12,
          child: _CircleBtn(
            icon: Icons.favorite_border_rounded,
            onTap: onWishlist,
          ),
        ),
        if (product.discount > 0)
          Positioned(
            top: overlayTop + 4,
            left: 56,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.success,
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
              child: Text(
                '${product.discount}% OFF',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
