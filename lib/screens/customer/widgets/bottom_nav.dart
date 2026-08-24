import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

class CustomerBottomNav extends StatelessWidget {
  final String active; // home | cart | categories | profile
  final ValueChanged<String> onTap;
  const CustomerBottomNav({super.key, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final items = [
      ('home', Icons.home_outlined, 'Home'),
      ('cart', Icons.shopping_cart_outlined, 'Cart'),
      ('categories', Icons.grid_view_outlined, 'Categories'),
      ('profile', Icons.person_outline, 'Profile'),
    ];
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.gray100)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: items.map((it) {
          final isActive = active == it.$1;
          final color = isActive ? AppColors.brandRed : AppColors.gray400;
          return InkWell(
            onTap: () => onTap(it.$1),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(it.$2, color: color, size: 22),
                const SizedBox(height: 2),
                Text(it.$3, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w600)),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
