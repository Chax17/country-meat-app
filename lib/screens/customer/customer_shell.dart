import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/mock_data.dart';
import '../../models/product.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import 'home_screen.dart';
import 'categories_listing_screens.dart';
import 'detail_screen.dart';
import 'cart_payment_screens.dart';
import 'order_screens.dart';
import 'rewards_screen.dart';
import 'profile_addcard_screens.dart';
import 'splash_otp_location_screens.dart';
import 'search_screen.dart';
import 'widgets/product_cards.dart';

enum CustomerAuthStep { splash, onboarding, login, otp, location, done }

class CustomerShell extends StatefulWidget {
  final CustomerAuthStep initialAuthStep;
  const CustomerShell({super.key, this.initialAuthStep = CustomerAuthStep.splash});

  @override
  State<CustomerShell> createState() => _CustomerShellState();
}

class _CustomerShellState extends State<CustomerShell> {
  // ── Auth Flow ────────────────────────────────────────────────────────────
  late CustomerAuthStep _authStep;
  String _userPhone = '9876543210';

  // ── In-app navigation ────────────────────────────────────────────────────
  int _navIndex = 0;
  String _screen = 'home';
  String? _param;

  @override
  void initState() {
    super.initState();
    _authStep = widget.initialAuthStep;
  }

  void _nav(String screen, {String? param}) {
    setState(() {
      _screen = screen;
      _param = param;
      // Sync bottom tab if navigating to root screens
      switch (screen) {
        case 'home': _navIndex = 0; break;
        case 'categories':
        case 'listing': _navIndex = 1; break;
        case 'orders':
        case 'tracking':
        case 'confirmation': _navIndex = 2; break;
        case 'rewards':
        case 'profile':
        case 'addcard': _navIndex = 3; break;
      }
    });
  }

  void _onNavTap(int idx) {
    setState(() {
      _navIndex = idx;
      switch (idx) {
        case 0: _screen = 'home'; _param = null; break;
        case 1: _screen = 'categories'; _param = null; break;
        case 2: _screen = 'orders'; _param = null; break;
        case 3: _screen = 'profile'; _param = null; break;
      }
    });
  }

  void _openAddToCart(Product p) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddToCartSheet(
        product: p,
        onAdd: (prod, cut, gender, slot) {
          context.read<AppState>().addToCart(prod, cut: cut, gender: gender, slot: slot);
          showAppToast(context, '${prod.name} added to cart! 🛒');
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // ── Auth Flow ────────────────────────────────────────────────────────
    if (_authStep == CustomerAuthStep.splash) {
      return CustSplashScreen(
        onDone: () => setState(() => _authStep = CustomerAuthStep.onboarding),
      );
    }
    if (_authStep == CustomerAuthStep.onboarding) {
      return CustOnboardingScreen(
        onDone: () => setState(() => _authStep = CustomerAuthStep.login),
      );
    }
    if (_authStep == CustomerAuthStep.login) {
      return CustLoginScreen(
        onContinue: (phone) {
          setState(() {
            _userPhone = phone;
            _authStep = CustomerAuthStep.otp;
          });
        },
      );
    }
    if (_authStep == CustomerAuthStep.otp) {
      return CustOtpScreen(
        phone: _userPhone,
        onContinue: () {
          context.read<AppState>().updateUser('Arjun Kumar', '+91 $_userPhone');
          setState(() => _authStep = CustomerAuthStep.location);
        },
      );
    }
    if (_authStep == CustomerAuthStep.location) {
      return CustLocationScreen(
        onContinue: () => setState(() => _authStep = CustomerAuthStep.done),
      );
    }

    // ── Main App ─────────────────────────────────────────────────────────
    final appState = context.watch<AppState>();

    // Full-screen overlays (no bottom nav)
    if (_screen == 'confirmation') {
      return CustConfirmationScreen(nav: _nav);
    }
    if (_screen == 'tracking') {
      return CustTrackingScreen(
        orderId: _param ?? (appState.orders.isNotEmpty ? appState.orders.first.id : ''),
        nav: _nav,
      );
    }
    if (_screen == 'payment') {
      return Scaffold(
        backgroundColor: AppColors.white,
        body: SafeArea(child: CustPaymentScreen(nav: _nav)),
      );
    }

    Widget body;
    switch (_screen) {
      case 'home':
        body = CustHomeScreen(nav: _nav);
        break;
      case 'categories':
        body = CustCategoriesScreen(nav: _nav);
        break;
      case 'listing':
        body = CustListingScreen(category: _param ?? 'chicken', nav: _nav);
        break;
      case 'detail':
        body = CustDetailScreen(
          productId: _param ?? kAllProducts.first.id,
          nav: _nav,
          openModal: _openAddToCart,
        );
        break;
      case 'cart':
        body = CustCartScreen(nav: _nav);
        break;
      case 'orders':
        body = CustOrdersScreen(nav: _nav);
        break;
      case 'rewards':
        body = CustRewardsScreen(nav: _nav);
        break;
      case 'profile':
        body = CustProfileScreen(nav: _nav);
        break;
      case 'addcard':
        body = CustAddCardScreen(nav: _nav);
        break;
      case 'search':
        body = CustSearchScreen(nav: _nav, initialQuery: _param);
        break;
      default:
        body = CustHomeScreen(nav: _nav);
    }

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(child: body),
      bottomNavigationBar: _BottomNav(
        currentIndex: _navIndex,
        cartCount: appState.cartCount,
        onTap: (i) {
          _onNavTap(i);
        },
        onCartTap: () => setState(() {
          _screen = 'cart';
        }),
      ),
    );
  }
}

// ─── BOTTOM NAV ──────────────────────────────────────────────────────────────
class _BottomNav extends StatelessWidget {
  final int currentIndex;
  final int cartCount;
  final ValueChanged<int> onTap;
  final VoidCallback onCartTap;
  const _BottomNav({
    required this.currentIndex,
    required this.cartCount,
    required this.onTap,
    required this.onCartTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.gray100)),
      ),
      child: SafeArea(
        child: SizedBox(
          height: 62,
          child: Row(
            children: [
              _NavItem(
                icon: Icons.home_rounded,
                iconOutline: Icons.home_outlined,
                label: 'Home',
                selected: currentIndex == 0,
                onTap: () => onTap(0),
              ),
              _NavItem(
                icon: Icons.storefront_rounded,
                iconOutline: Icons.storefront_outlined,
                label: 'Shop',
                selected: currentIndex == 1,
                onTap: () => onTap(1),
              ),
              // Center cart button
              Expanded(
                child: GestureDetector(
                  onTap: onCartTap,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 48, height: 48,
                        decoration: const BoxDecoration(
                          gradient: AppGradients.brandRed,
                          shape: BoxShape.circle,
                          boxShadow: AppShadows.card,
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            const Icon(Icons.shopping_cart_rounded, color: Colors.white, size: 22),
                            if (cartCount > 0)
                              Positioned(
                                right: 6, top: 6,
                                child: Container(
                                  width: 16, height: 16,
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  alignment: Alignment.center,
                                  child: Text('$cartCount',
                                      style: const TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.brandRed)),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              _NavItem(
                icon: Icons.receipt_long_rounded,
                iconOutline: Icons.receipt_long_outlined,
                label: 'Orders',
                selected: currentIndex == 2,
                onTap: () => onTap(2),
              ),
              _NavItem(
                icon: Icons.person_rounded,
                iconOutline: Icons.person_outline_rounded,
                label: 'Profile',
                selected: currentIndex == 3,
                onTap: () => onTap(3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon, iconOutline;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _NavItem({
    required this.icon,
    required this.iconOutline,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => Expanded(
    child: InkWell(
      onTap: onTap,
      splashColor: Colors.transparent,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Icon(
              selected ? icon : iconOutline,
              key: ValueKey(selected),
              color: selected ? AppColors.brandRed : AppColors.gray400,
              size: 22,
            ),
          ),
          const SizedBox(height: 2),
          Text(label,
              style: TextStyle(
                  fontSize: 10,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: selected ? AppColors.brandRed : AppColors.gray400)),
        ],
      ),
    ),
  );
}
