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
import 'tier_progress_screen.dart';
import 'referral_screen.dart';
import 'birthday_screen.dart';
import 'profile_addcard_screens.dart';
import 'wallet_screen.dart';
import 'splash_otp_location_screens.dart';
import 'search_screen.dart';
import 'widgets/product_cards.dart';

enum CustomerAuthStep { splash, onboarding, login, otp, location, done }

class _NavHistoryItem {
  final CustomerAuthStep authStep;
  final String screen;
  final String? param;
  final int navIndex;

  const _NavHistoryItem({
    required this.authStep,
    required this.screen,
    this.param,
    required this.navIndex,
  });
}

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

  // ── History Stack ────────────────────────────────────────────────────────
  final List<_NavHistoryItem> _history = [];

  @override
  void initState() {
    super.initState();
    _authStep = widget.initialAuthStep;
  }

  void _pushHistory() {
    if (_history.isNotEmpty) {
      final top = _history.last;
      if (top.authStep == _authStep &&
          top.screen == _screen &&
          top.param == _param &&
          top.navIndex == _navIndex) {
        return;
      }
    }
    _history.add(_NavHistoryItem(
      authStep: _authStep,
      screen: _screen,
      param: _param,
      navIndex: _navIndex,
    ));
  }

  void _pop() {
    if (_history.isNotEmpty) {
      final previous = _history.removeLast();
      setState(() {
        _authStep = previous.authStep;
        _screen = previous.screen;
        _param = previous.param;
        _navIndex = previous.navIndex;
      });
    } else {
      setState(() {
        _screen = 'home';
        _param = null;
        _navIndex = 0;
      });
    }
  }

  void _nav(String screen, {String? param}) {
    if (screen == 'back' || screen == 'pop') {
      _pop();
      return;
    }

    if (_authStep == CustomerAuthStep.done && _screen == screen && _param == param) {
      return;
    }

    // Handle checkout & post-rating completion: purge completed flow screens from back history
    if (screen == 'confirmation' || screen == 'tracking') {
      _history.removeWhere((item) => item.screen == 'payment' || item.screen == 'cart');
    } else if (screen == 'home') {
      _history.removeWhere((item) =>
          item.screen == 'tracking' ||
          item.screen == 'confirmation' ||
          item.screen == 'payment' ||
          item.screen == 'cart');
    }

    _pushHistory();

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
        case 'tier_progress':
        case 'referral':
        case 'birthday':
        case 'profile':
        case 'addcard':
        case 'wallet': _navIndex = 3; break;
      }
    });
  }

  void _onNavTap(int idx) {
    String targetScreen = 'home';
    switch (idx) {
      case 0: targetScreen = 'home'; break;
      case 1: targetScreen = 'categories'; break;
      case 2: targetScreen = 'orders'; break;
      case 3: targetScreen = 'profile'; break;
    }

    if (_navIndex == idx && _screen == targetScreen && _param == null) {
      return;
    }

    // Entering a primary root tab: clear sub-screen history to prevent back loops
    _history.clear();

    setState(() {
      _navIndex = idx;
      _screen = targetScreen;
      _param = null;
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
    Widget content;

    // ── Auth Flow ────────────────────────────────────────────────────────
    if (_authStep == CustomerAuthStep.splash) {
      content = CustSplashScreen(
        onDone: () {
          final isLoggedIn = context.read<AppState>().isLoggedIn;
          _history.clear();
          setState(() {
            _authStep = isLoggedIn ? CustomerAuthStep.done : CustomerAuthStep.onboarding;
          });
        },
      );
    } else if (_authStep == CustomerAuthStep.onboarding) {
      content = CustOnboardingScreen(
        onDone: () {
          _pushHistory();
          setState(() => _authStep = CustomerAuthStep.login);
        },
      );
    } else if (_authStep == CustomerAuthStep.login) {
      content = CustLoginScreen(
        onContinue: (phone) {
          _pushHistory();
          setState(() {
            _userPhone = phone;
            _authStep = CustomerAuthStep.otp;
          });
        },
      );
    } else if (_authStep == CustomerAuthStep.otp) {
      content = CustOtpScreen(
        phone: _userPhone,
        onContinue: () {
          _pushHistory();
          context.read<AppState>().updateUser('Arjun Kumar', '+91 $_userPhone');
          setState(() => _authStep = CustomerAuthStep.location);
        },
      );
    } else if (_authStep == CustomerAuthStep.location) {
      content = CustLocationScreen(
        onContinue: () {
          _history.clear();
          setState(() => _authStep = CustomerAuthStep.done);
        },
      );
    } else {
      // ── Main App ─────────────────────────────────────────────────────────
      final appState = context.watch<AppState>();

      // Full-screen overlays (no bottom nav)
      if (_screen == 'confirmation') {
        content = CustConfirmationScreen(nav: _nav);
      } else if (_screen == 'tracking') {
        content = CustTrackingScreen(
          orderId: _param ?? (appState.orders.isNotEmpty ? appState.orders.first.id : ''),
          nav: _nav,
        );
      } else if (_screen == 'payment') {
        content = Scaffold(
          backgroundColor: AppColors.white,
          body: SafeArea(child: CustPaymentScreen(nav: _nav)),
        );
      } else if (_screen == 'location') {
        final isProfileAddress = _param == 'profileAddress' || _param == 'profile';
        final isHomeAddress = _param == 'homeAddress' || _param == 'home';
        final isFromCart = _param == 'cart';

        final LocationOrigin origin;
        if (isProfileAddress) {
          origin = LocationOrigin.profileAddress;
        } else if (isHomeAddress) {
          origin = LocationOrigin.homeAddress;
        } else if (isFromCart) {
          origin = LocationOrigin.cart;
        } else {
          origin = LocationOrigin.onboarding;
        }

        content = CustLocationScreen(
          origin: origin,
          fromCart: isFromCart,
          onContinue: () {
            _nav('back', param: isProfileAddress ? 'addresses' : null);
          },
          onBack: () => _nav('back', param: isProfileAddress ? 'addresses' : null),
        );
      } else {
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
          case 'tier_progress':
            body = CustTierProgressScreen(nav: _nav);
            break;
          case 'referral':
            body = CustReferralScreen(nav: _nav);
            break;
          case 'birthday':
            body = CustBirthdayScreen(nav: _nav);
            break;
          case 'profile':
            body = CustProfileScreen(nav: _nav, param: _param);
            break;
          case 'addcard':
            body = CustAddCardScreen(nav: _nav);
            break;
          case 'wallet':
            body = CustWalletScreen(nav: _nav);
            break;
          case 'search':
            body = CustSearchScreen(nav: _nav, initialQuery: _param);
            break;
          default:
            body = CustHomeScreen(nav: _nav);
        }

        content = Scaffold(
          backgroundColor: AppColors.white,
          body: SafeArea(child: body),
          bottomNavigationBar: _BottomNav(
            currentIndex: _navIndex,
            cartCount: appState.cartCount,
            onTap: (i) {
              _onNavTap(i);
            },
            onCartTap: () => _nav('cart'),
          ),
        );
      }
    }

    return PopScope(
      canPop: _history.isEmpty,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (_history.isNotEmpty) {
          _pop();
        }
      },
      child: content,
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
