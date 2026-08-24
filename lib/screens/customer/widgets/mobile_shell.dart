import 'package:flutter/material.dart';

/// Wraps portal content in a phone-frame look on wide screens (desktop/web),
/// and simply fills the screen on real mobile devices.
class MobileShell extends StatelessWidget {
  final Widget child;
  const MobileShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 480;
        if (!isWide) return child;
        return Container(
          color: const Color(0xFFEDEDED),
          child: Center(
            child: Container(
              width: 400,
              height: constraints.maxHeight > 860 ? 860 : constraints.maxHeight * 0.96,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(32),
                boxShadow: const [
                  BoxShadow(color: Colors.black26, blurRadius: 30, offset: Offset(0, 10)),
                ],
              ),
              child: child,
            ),
          ),
        );
      },
    );
  }
}
