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
  bool _descExpanded = false;

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

    return Stack(
      children: [
        ListView(
          padding: const EdgeInsets.only(bottom: 80),
          children: [
            // ── Hero Image ──────────────────────────────────────────────────
            Stack(
              children: [
                Image.asset(p.img,
                    height: 260, width: double.infinity, fit: BoxFit.cover),
                // Gradient
                Positioned(
                  bottom: 0, left: 0, right: 0,
                  child: Container(height: 80,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.transparent, Colors.white],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ),
                // Back button
                Positioned(
                  top: 16, left: 12,
                  child: _CircleBtn(
                    icon: Icons.arrow_back_ios_new_rounded,
                    onTap: () => widget.nav('listing', param: p.category),
                  ),
                ),
                // Wishlist
                Positioned(
                  top: 16, right: 12,
                  child: _CircleBtn(
                    icon: Icons.favorite_border_rounded,
                    onTap: () => showAppToast(context, 'Added to wishlist! ❤️'),
                  ),
                ),
                // Discount badge
                if (p.discount > 0)
                  Positioned(
                    top: 16, left: 56,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.success,
                        borderRadius: BorderRadius.circular(AppRadius.full),
                      ),
                      child: Text('${p.discount}% OFF',
                          style: const TextStyle(
                              color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800)),
                    ),
                  ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tags
                  Wrap(children: p.tags.map((t) => TagBadge(label: t)).toList()),
                  const SizedBox(height: 6),
                  // Name
                  Text(p.name,
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
                  Text(p.sub, style: const TextStyle(color: AppColors.gray500, fontSize: 13)),
                  const SizedBox(height: 16),
                  // Meta grid
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.gray50,
                      borderRadius: BorderRadius.circular(AppRadius.md),
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
                  const SizedBox(height: 16),
                  // Price row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('₹${p.price}',
                              style: const TextStyle(
                                  fontSize: 28, fontWeight: FontWeight.w900, color: AppColors.gray900)),
                          Row(children: [
                            Text('₹${p.mrp}',
                                style: const TextStyle(
                                    color: AppColors.gray400,
                                    decoration: TextDecoration.lineThrough,
                                    fontSize: 13)),
                            const SizedBox(width: 6),
                            Text('Save ₹${p.mrp - p.price}',
                                style: const TextStyle(
                                    color: AppColors.success,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13)),
                          ]),
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
                  const SizedBox(height: 18),
                  // Description
                  GestureDetector(
                    onTap: () => setState(() => _descExpanded = !_descExpanded),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('About this Product',
                            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                        const SizedBox(height: 6),
                        AnimatedCrossFade(
                          firstChild: Text(p.desc,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: AppColors.gray700, height: 1.6, fontSize: 13.5)),
                          secondChild: Text(p.desc,
                              style: const TextStyle(color: AppColors.gray700, height: 1.6, fontSize: 13.5)),
                          crossFadeState: _descExpanded
                              ? CrossFadeState.showSecond
                              : CrossFadeState.showFirst,
                          duration: const Duration(milliseconds: 250),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _descExpanded ? 'Show less ↑' : 'Read more ↓',
                          style: const TextStyle(
                              color: AppColors.brandRed, fontWeight: FontWeight.w600, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
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
                        const Text('🌿 Health Benefits',
                            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                        const SizedBox(height: 10),
                        ...p.benefits.map((b) => Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.check_circle_rounded,
                                  size: 15, color: AppColors.success),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(b,
                                    style: const TextStyle(
                                        fontSize: 12.5, color: AppColors.gray700, height: 1.4)),
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
