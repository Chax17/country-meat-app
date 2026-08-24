import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/product.dart';
import '../../../state/app_state.dart';
import '../../../theme/app_theme.dart';

Future<void> showAddToCartSheet(BuildContext context, Product p, {VoidCallback? onAdded}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (ctx) => _AddToCartSheet(p: p, onAdded: onAdded),
  );
}

class _AddToCartSheet extends StatefulWidget {
  final Product p;
  final VoidCallback? onAdded;
  const _AddToCartSheet({required this.p, this.onAdded});

  @override
  State<_AddToCartSheet> createState() => _AddToCartSheetState();
}

class _AddToCartSheetState extends State<_AddToCartSheet> {
  String cut = 'Medium';
  late String gender;
  String slot = '6AM–9AM';

  @override
  void initState() {
    super.initState();
    gender = widget.p.gender == 'Hen' ? 'Hen' : 'Rooster';
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.p;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.asset(p.img, height: 64, width: 64, fit: BoxFit.cover)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(p.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                      Text(p.sub, style: const TextStyle(fontSize: 12, color: AppColors.gray500)),
                      Text('₹${p.price}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text('Cuts', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
            const SizedBox(height: 8),
            _pillGroup(['Small', 'Medium', 'Large'], cut, (v) => setState(() => cut = v)),
            const SizedBox(height: 16),
            const Text('Gender', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
            const SizedBox(height: 8),
            _pillGroup(['Rooster', 'Hen'], gender, (v) => setState(() => gender = v), emojiMap: const {'Rooster': '🐓 ', 'Hen': '🐔 '}),
            const SizedBox(height: 16),
            const Text('Delivery Slot', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
            const SizedBox(height: 8),
            _pillGroup(['6AM–9AM', '8AM–11AM', '10AM–12PM'], slot, (v) => setState(() => slot = v)),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  context.read<AppState>().addToCart(p, cut: cut, gender: gender, slot: slot);
                  Navigator.of(context).pop();
                  widget.onAdded?.call();
                },
                child: Text('Add to Cart · ₹${p.price}'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _pillGroup(List<String> options, String active, ValueChanged<String> onSelect, {Map<String, String>? emojiMap}) {
    return Wrap(
      spacing: 8,
      children: options.map((o) {
        final isActive = o == active;
        return GestureDetector(
          onTap: () => onSelect(o),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isActive ? AppColors.brandRed : AppColors.gray100,
              borderRadius: BorderRadius.circular(AppRadius.full),
            ),
            child: Text(
              '${emojiMap?[o] ?? ''}$o',
              style: TextStyle(color: isActive ? Colors.white : AppColors.gray700, fontWeight: FontWeight.w600, fontSize: 12.5),
            ),
          ),
        );
      }).toList(),
    );
  }
}
