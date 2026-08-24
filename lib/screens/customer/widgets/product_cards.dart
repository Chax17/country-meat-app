import 'package:flutter/material.dart';
import '../../../models/product.dart';
import '../../../theme/app_theme.dart';

// ─── HORIZONTAL CARD (used in Home carousels) ─────────────────────────────────
class ProductCardHorizontal extends StatelessWidget {
  final Product p;
  final VoidCallback onTap;
  final VoidCallback onAdd;
  const ProductCardHorizontal({
    super.key,
    required this.p,
    required this.onTap,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 155,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.md),
          boxShadow: AppShadows.card,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.md)),
              child: Stack(
                children: [
                  Image.asset(p.img, height: 115, width: 155, fit: BoxFit.cover),
                  if (p.discount > 0)
                    Positioned(
                      top: 8, left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.success,
                          borderRadius: BorderRadius.circular(AppRadius.full),
                        ),
                        child: Text('${p.discount}% OFF',
                            style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700)),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(p.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5)),
                  Text(p.weight,
                      style: const TextStyle(color: AppColors.gray400, fontSize: 11)),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('₹${p.price}',
                            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                        Text('₹${p.mrp}',
                            style: const TextStyle(
                                color: AppColors.gray400,
                                decoration: TextDecoration.lineThrough,
                                fontSize: 10)),
                      ]),
                      GestureDetector(
                        onTap: onAdd,
                        child: Container(
                          width: 30, height: 30,
                          decoration: const BoxDecoration(
                              color: AppColors.brandRed, shape: BoxShape.circle),
                          alignment: Alignment.center,
                          child: const Icon(Icons.add_rounded, color: Colors.white, size: 18),
                        ),
                      ),
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
}

// ─── VERTICAL CARD (used in Listing screen) ───────────────────────────────────
class ProductCardVertical extends StatelessWidget {
  final Product p;
  final VoidCallback onTap;
  final VoidCallback onAdd;
  const ProductCardVertical({
    super.key,
    required this.p,
    required this.onTap,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.md),
          boxShadow: AppShadows.subtle,
          border: Border.all(color: AppColors.gray100),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.base),
              child: Stack(
                children: [
                  Image.asset(p.img, height: 90, width: 90, fit: BoxFit.cover),
                  if (p.discount > 0)
                    Positioned(
                      top: 5, left: 5,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.success,
                          borderRadius: BorderRadius.circular(AppRadius.full),
                        ),
                        child: Text('${p.discount}%',
                            style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700)),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(p.name,
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                  Text(p.sub,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: AppColors.gray400, fontSize: 11)),
                  const SizedBox(height: 4),
                  Wrap(
                    children: p.tags.take(2).map((t) => TagBadge(label: t)).toList(),
                  ),
                  const SizedBox(height: 4),
                  Text('⏱ ${p.age} · 👥 ${p.serves} · ⚖ ${p.weight}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 10.5, color: AppColors.gray400)),
                  const SizedBox(height: 6),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Flexible(
                      child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                        Text('₹${p.price}',
                            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text('₹${p.mrp}',
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  color: AppColors.gray400,
                                  decoration: TextDecoration.lineThrough,
                                  fontSize: 11)),
                        ),
                      ]),
                    ),
                    const SizedBox(width: 4),
                    ElevatedButton(
                      onPressed: onAdd,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                      ),
                      child: const Text('+ Add'),
                    ),
                  ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── ADD TO CART BOTTOM SHEET ─────────────────────────────────────────────────
class AddToCartSheet extends StatefulWidget {
  final Product product;
  final void Function(Product p, String cut, String gender, String slot) onAdd;
  const AddToCartSheet({super.key, required this.product, required this.onAdd});

  @override
  State<AddToCartSheet> createState() => _AddToCartSheetState();
}

class _AddToCartSheetState extends State<AddToCartSheet> {
  String _cut = 'Medium';
  late String _gender;
  String _slot = '6AM–9AM';
  int _qty = 1;

  static const _cuts = ['Small', 'Medium', 'Large', 'Full'];
  static const _slots = ['6AM–9AM', '9AM–12PM'];

  @override
  void initState() {
    super.initState();
    _gender = widget.product.gender == 'Both' ? 'Rooster' : widget.product.gender;
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40, height: 4,
              margin: const EdgeInsets.only(top: 12, bottom: 16),
              decoration: BoxDecoration(
                color: AppColors.gray200,
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
            ),
          ),
          // Product header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.base),
                child: Image.asset(p.img, height: 60, width: 60, fit: BoxFit.cover),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(p.name,
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                  Text(p.weight, style: const TextStyle(color: AppColors.gray400, fontSize: 12)),
                ]),
              ),
              Text('₹${p.price * _qty}',
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: AppColors.brandRed)),
            ]),
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Cut selection (only for chicken and mutton)
                if (p.category == 'chicken' || p.category == 'mutton') ...[
                  _sheetLabel('Cut Preference'),
                  _ChipGroup(
                    items: p.category == 'mutton'
                        ? const ['Curry Cut', 'Biryani Cut', 'Mutton Chops', 'Ribs']
                        : _cuts,
                    selected: _cut,
                    onSelected: (v) => setState(() => _cut = v),
                  ),
                  const SizedBox(height: 12),
                ],
                // Gender (only for chicken)
                if (p.category == 'chicken' && p.gender == 'Both') ...[
                  _sheetLabel('Gender'),
                  _ChipGroup(
                    items: const ['Rooster', 'Hen'],
                    selected: _gender,
                    onSelected: (v) => setState(() => _gender = v),
                  ),
                  const SizedBox(height: 12),
                ],
                // Slot
                _sheetLabel('Delivery Slot'),
                _ChipGroup(
                  items: _slots,
                  selected: _slot,
                  onSelected: (v) => setState(() => _slot = v),
                ),
                const SizedBox(height: 16),
                // Qty + Add button
                Row(children: [
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.gray200),
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                    child: Row(children: [
                      _qtyBtn(Icons.remove, () { if (_qty > 1) setState(() => _qty--); }),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text('$_qty',
                            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
                      ),
                      _qtyBtn(Icons.add, () => setState(() => _qty++)),
                    ]),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        for (int i = 0; i < _qty; i++) {
                          widget.onAdd(p, _cut, _gender, _slot);
                        }
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                      child: const Text('Add to Cart 🛒', style: TextStyle(fontSize: 15)),
                    ),
                  ),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sheetLabel(String label) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(label,
        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5, color: AppColors.gray500)),
  );

  Widget _qtyBtn(IconData icon, VoidCallback onTap) => Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.full),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Icon(icon, size: 18, color: AppColors.gray700),
          ),
        ),
      );
}

class _ChipGroup extends StatelessWidget {
  final List<String> items;
  final String selected;
  final ValueChanged<String> onSelected;
  const _ChipGroup({required this.items, required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: 8,
    runSpacing: 8,
    children: items.map((item) => GestureDetector(
      onTap: () => onSelected(item),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: selected == item ? AppColors.brandRed : AppColors.gray100,
          borderRadius: BorderRadius.circular(AppRadius.full),
        ),
        child: Text(item,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: selected == item ? Colors.white : AppColors.gray600,
            )),
      ),
    )).toList(),
  );
}
