import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';

// ─── CART SCREEN ─────────────────────────────────────────────────────────────
class CustCartScreen extends StatefulWidget {
  final void Function(String screen, {String? param}) nav;
  const CustCartScreen({super.key, required this.nav});

  @override
  State<CustCartScreen> createState() => _CustCartScreenState();
}

class _CustCartScreenState extends State<CustCartScreen> {
  final _couponCtrl = TextEditingController();
  bool _couponApplied = false;

  @override
  void dispose() {
    _couponCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    const deliveryFee = 40;
    final itemTotal = appState.cartTotal;
    final discount = _couponApplied ? (itemTotal * 0.1).round() : 0;
    final rewardDiscount = appState.rewardDiscount;
    final grand = (itemTotal + deliveryFee - discount - rewardDiscount).clamp(0, 999999);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 10, 16, 6),
          child: Row(children: [
            IconButton(
              onPressed: () => widget.nav('home'),
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
            ),
            const Expanded(
              child: Text('My Cart',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            ),
            if (appState.cartCount > 0)
              Text('${appState.cartCount} item${appState.cartCount != 1 ? 's' : ''}',
                  style: const TextStyle(
                      color: AppColors.brandRed, fontWeight: FontWeight.w700, fontSize: 13)),
          ]),
        ),

        if (appState.cart.isEmpty)
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🛒', style: TextStyle(fontSize: 64)),
                  const SizedBox(height: 16),
                  const Text('Your cart is empty',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  const Text('Add some fresh country meat!',
                      style: TextStyle(color: AppColors.gray400, fontSize: 14)),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => widget.nav('categories'),
                    child: const Text('Browse Products →'),
                  ),
                ],
              ),
            ),
          )
        else ...[
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                // Cart items
                ...appState.cart.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final item = entry.value;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      boxShadow: AppShadows.subtle,
                      border: Border.all(color: AppColors.gray100),
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(AppRadius.base),
                          child: Image.asset(item.product.img,
                              height: 70, width: 70, fit: BoxFit.cover),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item.product.name,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w700, fontSize: 14)),
                              Text('${item.cut} Cut · ${item.gender} · ${item.slot}',
                                  style: const TextStyle(
                                      fontSize: 11, color: AppColors.gray500)),
                              const SizedBox(height: 4),
                              Text('₹${item.lineTotal}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 15,
                                      color: AppColors.brandRed)),
                            ],
                          ),
                        ),
                        // Qty control
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.gray200),
                            borderRadius: BorderRadius.circular(AppRadius.full),
                          ),
                          child: Row(
                            children: [
                              _QtyBtn(
                                  icon: Icons.remove,
                                  onTap: () => appState.changeQty(idx, -1)),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                child: Text('${item.qty}',
                                    style: const TextStyle(fontWeight: FontWeight.w800)),
                              ),
                              _QtyBtn(
                                  icon: Icons.add,
                                  onTap: () => appState.changeQty(idx, 1)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }),

                // Delivery slot
                const SizedBox(height: 4),
                const Text('Delivery Slot',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                const SizedBox(height: 8),
                Row(children: [
                  _SlotChip(label: '6AM–9AM', selected: appState.selectedSlot == '6AM–9AM',
                      onTap: () => appState.setSlot('6AM–9AM')),
                  _SlotChip(label: '9AM–12PM', selected: appState.selectedSlot == '9AM–12PM',
                      onTap: () => appState.setSlot('9AM–12PM')),
                ]),

                const SizedBox(height: 14),
                // Delivery address info
                _InfoRow(
                    icon: '📍',
                    label: 'Delivery Address',
                    val: appState.defaultAddress,
                    action: 'Change',
                    onAction: () => _showAddressPickerSheet(context, appState)),
                const SizedBox(height: 8),
                _InfoRow(
                    icon: '🚚',
                    label: 'Delivery Partner',
                    val: 'Assigned automatically upon order confirmation',
                    action: 'Info',
                    onAction: () => showAppToast(context, 'Verified local partner will deliver at dawn 🌅')),

                // Reward Points Toggle Card
                if (appState.rewardPoints >= 100) ...[
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.brandRedBg,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(color: AppColors.brandRed.withOpacity(0.2)),
                    ),
                    child: Row(
                      children: [
                        const Text('🎁', style: TextStyle(fontSize: 22)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Use ${appState.rewardPoints} Reward Pts',
                                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: AppColors.brandRedDark)),
                              Text('Save ₹${(appState.rewardPoints / 100).floor() * 10} on this order',
                                  style: const TextStyle(fontSize: 11, color: AppColors.gray600)),
                            ],
                          ),
                        ),
                        Switch(
                          value: appState.isRewardRedeemed,
                          activeColor: AppColors.brandRed,
                          onChanged: (val) => appState.toggleRewardRedemption(val),
                        ),
                      ],
                    ),
                  ),
                ],

                // Coupon
                const SizedBox(height: 14),
                Row(children: [
                  Expanded(
                    child: TextField(
                      controller: _couponCtrl,
                      decoration: const InputDecoration(
                        hintText: 'Enter coupon code (e.g. FARM10)',
                        hintStyle: TextStyle(fontSize: 13),
                        prefixIcon: Icon(Icons.discount_outlined, size: 18, color: AppColors.gray400),
                        contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 14),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      if (_couponCtrl.text.trim().toUpperCase() == 'FARM10') {
                        setState(() => _couponApplied = true);
                        showAppToast(context, '🎉 10% off applied!');
                      } else {
                        showAppToast(context, 'Invalid coupon code. Try FARM10');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                    child: const Text('Apply'),
                  ),
                ]),

                // Bill summary
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.gray50,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Bill Summary',
                          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                      const SizedBox(height: 12),
                      _BillRow('Item Total', '₹$itemTotal'),
                      _BillRow('Delivery Fee', '₹$deliveryFee'),
                      if (_couponApplied)
                        _BillRow('Coupon (FARM10)', '−₹$discount',
                            valueColor: AppColors.success),
                      if (appState.isRewardRedeemed && rewardDiscount > 0)
                        _BillRow('Reward Points', '−₹$rewardDiscount',
                            valueColor: AppColors.success),
                      const Divider(height: 20),
                      _BillRow('Grand Total', '₹$grand', bold: true),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
          // Bottom CTA
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: AppColors.gray100)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('${appState.selectedSlot} delivery',
                          style: const TextStyle(fontSize: 11, color: AppColors.gray400),
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                      Text('₹$grand Total',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => widget.nav('payment'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  ),
                  child: const Text('Proceed to Pay →'),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  void _showAddressPickerSheet(BuildContext ctx, AppState appState) {
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (modalCtx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Select Delivery Address',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(modalCtx),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...appState.addresses.map((a) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: a.isDefault ? AppColors.brandRedBg : AppColors.gray50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: a.isDefault ? AppColors.brandRed : AppColors.gray200,
                        width: a.isDefault ? 1.5 : 1,
                      ),
                    ),
                    child: ListTile(
                      leading: Icon(
                        a.label == 'Home' ? Icons.home_rounded : Icons.work_rounded,
                        color: a.isDefault ? AppColors.brandRed : AppColors.gray600,
                      ),
                      title: Text(
                        a.label,
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: a.isDefault ? AppColors.brandRed : AppColors.gray900,
                        ),
                      ),
                      subtitle: Text(a.address, style: const TextStyle(fontSize: 12)),
                      trailing: a.isDefault
                          ? const Icon(Icons.check_circle_rounded, color: AppColors.brandRed)
                          : null,
                      onTap: () {
                        appState.setDefaultAddress(a);
                        Navigator.pop(modalCtx);
                        showAppToast(ctx, 'Delivery address updated to ${a.label}');
                      },
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─── PAYMENT SCREEN ───────────────────────────────────────────────────────────
class CustPaymentScreen extends StatefulWidget {
  final void Function(String screen, {String? param}) nav;
  const CustPaymentScreen({super.key, required this.nav});

  @override
  State<CustPaymentScreen> createState() => _CustPaymentScreenState();
}

class _CustPaymentScreenState extends State<CustPaymentScreen> {
  bool _showingWalletSubScreen = false;
  String _selectedPaymentOption = 'phonepe';

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final total = appState.cartTotal > 0 ? appState.cartTotal + 40 : 950;

    if (_showingWalletSubScreen) {
      return _buildWalletSubScreen(context, total);
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: Column(
          children: [
            _CircleNavHeader(title: 'Bill total : ₹$total', onBack: () => widget.nav('cart')),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                children: [
                  // RECOMMENDED
                  const _SubSectionHeader('RECOMMENDED'),
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: AppShadows.subtle,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Column(
                        children: [
                          InkWell(
                            onTap: () => setState(() => _showingWalletSubScreen = true),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  const Text('🐓', style: TextStyle(fontSize: 28)),
                                  const SizedBox(width: 14),
                                  const Expanded(
                                    child: Text(
                                      'Country Meat Wallet',
                                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.gray900),
                                    ),
                                  ),
                                  const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.gray800),
                                ],
                              ),
                            ),
                          ),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            color: const Color(0xFFFF5252),
                            child: const Text(
                              '5 % Instant Discount on Country Meat Pay',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // CARDS
                  const _SubSectionHeader('CARDS'),
                  _PaymentTile(
                    iconWidget: const Icon(Icons.credit_card_rounded, color: Color(0xFFE53935), size: 24),
                    title: 'Credit Card or Debit Card',
                    trailingWidget: const Text('+', style: TextStyle(color: AppColors.brandRed, fontSize: 20, fontWeight: FontWeight.w700)),
                    onTap: () => _pay(context, 'Credit/Debit Card'),
                  ),

                  // PAY BY ANY UPI APP
                  const _SubSectionHeader('PAY BY ANY UPI APP'),
                  _PaymentTile(
                    iconWidget: _buildAppLogo('G', const Color(0xFF4285F4)),
                    title: 'Google Pay UPI',
                    onTap: () => _pay(context, 'Google Pay UPI'),
                  ),
                  _PaymentTile(
                    iconWidget: _buildAppLogo('पे', const Color(0xFF5F259F)),
                    title: 'PhonePe UPI',
                    onTap: () => _pay(context, 'PhonePe UPI'),
                  ),
                  _PaymentTile(
                    iconWidget: _buildAppLogo('slice', const Color(0xFF8B5CF6), isText: true),
                    title: 'Slice Pay UPI',
                    onTap: () => _pay(context, 'Slice Pay UPI'),
                  ),
                  _PaymentTile(
                    iconWidget: const Icon(Icons.chat_bubble_outline_rounded, color: Color(0xFF25D366), size: 26),
                    title: 'WhatsApp Pay UPI',
                    onTap: () => _pay(context, 'WhatsApp Pay UPI'),
                  ),
                  _PaymentTile(
                    iconWidget: _buildAppLogo('pay', const Color(0xFF232F3E), isText: true),
                    title: 'Amazon Pay UPI',
                    onTap: () => _pay(context, 'Amazon Pay UPI'),
                  ),

                  // CASH ON DELIVERY
                  const _SubSectionHeader('PAY ON DELIVERY'),
                  _PaymentTile(
                    iconWidget: const Icon(Icons.payments_rounded, color: Color(0xFF16A34A), size: 24),
                    title: 'Cash on Delivery (COD)',
                    trailingWidget: const Text('Pay Cash', style: TextStyle(color: Color(0xFF16A34A), fontSize: 12, fontWeight: FontWeight.w800)),
                    onTap: () => _pay(context, 'Cash on Delivery'),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Wallet selection sub-screen
  Widget _buildWalletSubScreen(BuildContext context, int total) {
    final optionNames = {
      'phonepe': 'PhonePe UPI',
      'gpay': 'Google Pay UPI',
      'slice': 'Slice Pay UPI',
      'whatsapp': 'WhatsApp Pay UPI',
      'amazon': 'Amazon Pay UPI',
      'add_upi': 'Custom UPI ID',
      'card': 'Credit / Debit Card',
    };

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: Column(
          children: [
            _CircleNavHeader(
              title: 'Country Meat Wallet',
              onBack: () => setState(() => _showingWalletSubScreen = false),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const Text(
                    'Choose a payment option',
                    style: TextStyle(fontSize: 14, color: AppColors.gray500, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 14),

                  _SelectablePayTile(
                    id: 'phonepe',
                    selectedId: _selectedPaymentOption,
                    iconWidget: _buildAppLogo('पे', const Color(0xFF5F259F)),
                    title: 'PhonePe UPI',
                    onTap: () => setState(() => _selectedPaymentOption = 'phonepe'),
                  ),
                  _SelectablePayTile(
                    id: 'gpay',
                    selectedId: _selectedPaymentOption,
                    iconWidget: _buildAppLogo('G', const Color(0xFF4285F4)),
                    title: 'Google Pay UPI',
                    onTap: () => setState(() => _selectedPaymentOption = 'gpay'),
                  ),
                  _SelectablePayTile(
                    id: 'slice',
                    selectedId: _selectedPaymentOption,
                    iconWidget: _buildAppLogo('slice', const Color(0xFF8B5CF6), isText: true),
                    title: 'Slice Pay UPI',
                    onTap: () => setState(() => _selectedPaymentOption = 'slice'),
                  ),
                  _SelectablePayTile(
                    id: 'whatsapp',
                    selectedId: _selectedPaymentOption,
                    iconWidget: const Icon(Icons.chat_bubble_outline_rounded, color: Color(0xFF25D366), size: 26),
                    title: 'WhatsApp Pay UPI',
                    onTap: () => setState(() => _selectedPaymentOption = 'whatsapp'),
                  ),
                  _SelectablePayTile(
                    id: 'amazon',
                    selectedId: _selectedPaymentOption,
                    iconWidget: _buildAppLogo('pay', const Color(0xFF232F3E), isText: true),
                    title: 'Amazon Pay UPI',
                    onTap: () => setState(() => _selectedPaymentOption = 'amazon'),
                  ),
                  _SelectablePayTile(
                    id: 'card',
                    selectedId: _selectedPaymentOption,
                    iconWidget: const Icon(Icons.credit_card_rounded, color: Color(0xFFE53935), size: 24),
                    title: 'Credit Card or Debit Card',
                    trailingWidget: const Text('+', style: TextStyle(color: AppColors.brandRed, fontSize: 20, fontWeight: FontWeight.w700)),
                    onTap: () => setState(() => _selectedPaymentOption = 'card'),
                  ),
                ],
              ),
            ),

            // Bottom Pay button
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: AppColors.gray200)),
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _pay(context, optionNames[_selectedPaymentOption] ?? 'UPI / Wallet'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.brandRed,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  child: Text('Pay ₹$total'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppLogo(String label, Color bg, {bool isText = false}) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w900,
          fontSize: isText ? 11 : 16,
        ),
      ),
    );
  }

  void _pay(BuildContext context, String method) {
    final appState = context.read<AppState>();
    final grandTotal = appState.cartTotal > 0 ? appState.cartTotal + 40 : 950;
    final txnId = 'TXN${DateTime.now().millisecondsSinceEpoch.toString().substring(4)}';

    // Show Payment Gateway Interactive Modal
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (modalCtx) {
        return _PaymentGatewayModal(
          method: method,
          total: grandTotal,
          txnId: txnId,
          onComplete: () {
            appState.placeOrder(
              appState.selectedSlot,
              appState.defaultAddress,
              paymentMethod: method,
              txnId: txnId,
              customTotal: grandTotal,
            );
            Navigator.pop(modalCtx);
            widget.nav('confirmation');
          },
        );
      },
    );
  }
}

// ─── PAYMENT GATEWAY MODAL WIDGET ─────────────────────────────────────────────
class _PaymentGatewayModal extends StatefulWidget {
  final String method;
  final int total;
  final String txnId;
  final VoidCallback onComplete;

  const _PaymentGatewayModal({
    required this.method,
    required this.total,
    required this.txnId,
    required this.onComplete,
  });

  @override
  State<_PaymentGatewayModal> createState() => _PaymentGatewayModalState();
}

class _PaymentGatewayModalState extends State<_PaymentGatewayModal> {
  int _step = 0; // 0 = processing, 1 = verifying, 2 = success receipt

  @override
  void initState() {
    super.initState();
    _startGatewaySimulation();
  }

  void _startGatewaySimulation() async {
    await Future.delayed(const Duration(milliseconds: 1400));
    if (mounted) setState(() => _step = 1);
    await Future.delayed(const Duration(milliseconds: 1200));
    if (mounted) setState(() => _step = 2);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_step == 0 || _step == 1) ...[
              const SizedBox(height: 20),
              SizedBox(
                width: 60,
                height: 60,
                child: CircularProgressIndicator(
                  color: AppColors.brandRed,
                  strokeWidth: 4,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                _step == 0 ? 'Connecting to Payment Gateway...' : 'Verifying Payment Authorization...',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.gray900),
              ),
              const SizedBox(height: 6),
              Text(
                'Method: ${widget.method} · Amount: ₹${widget.total}',
                style: const TextStyle(fontSize: 13, color: AppColors.gray500),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.lock_outline_rounded, size: 14, color: AppColors.gray400),
                  SizedBox(width: 4),
                  Text('256-Bit Bank Grade Encryption', style: TextStyle(fontSize: 11, color: AppColors.gray400)),
                ],
              ),
              const SizedBox(height: 20),
            ] else ...[
              // Step 2: Success Receipt
              Container(
                width: 70,
                height: 70,
                decoration: const BoxDecoration(
                  color: Color(0xFFDCFCE7),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle_rounded, color: Color(0xFF16A34A), size: 48),
              ),
              const SizedBox(height: 16),
              const Text(
                'Payment Successful!',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.gray900),
              ),
              const SizedBox(height: 4),
              Text(
                'Paid ₹${widget.total} via ${widget.method}',
                style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: AppColors.gray600),
              ),
              const SizedBox(height: 16),

              // Receipt Summary Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.gray50,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.gray200),
                ),
                child: Column(
                  children: [
                    _ReceiptRow('Transaction ID', widget.txnId),
                    const SizedBox(height: 8),
                    _ReceiptRow('Payment Status', 'SUCCESS', valueColor: AppColors.success),
                    const SizedBox(height: 8),
                    _ReceiptRow('Timestamp', 'Just now'),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: widget.onComplete,
                  icon: const Icon(Icons.local_shipping_rounded, size: 18),
                  label: const Text('Track Live Delivery →'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.brandRed,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ReceiptRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _ReceiptRow(this.label, this.value, {this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.gray500)),
        Text(
          value,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w800,
            color: valueColor ?? AppColors.gray900,
          ),
        ),
      ],
    );
  }
}

// ─── SHARED WIDGETS ───────────────────────────────────────────────────────────
class _QtyBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _QtyBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) => Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.full),
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: Icon(icon, size: 16, color: AppColors.gray700),
          ),
        ),
      );
}

class _SlotChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _SlotChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: selected ? AppColors.brandRedBg : AppColors.gray50,
        border: Border.all(
            color: selected ? AppColors.brandRed : AppColors.gray200, width: 1.5),
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Text(label,
          style: TextStyle(
              fontWeight: FontWeight.w600,
              color: selected ? AppColors.brandRed : AppColors.gray600,
              fontSize: 13)),
    ),
  );
}

class _InfoRow extends StatelessWidget {
  final String icon, label, val, action;
  final VoidCallback onAction;
  const _InfoRow({required this.icon, required this.label, required this.val, required this.action, required this.onAction});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.gray100),
        borderRadius: BorderRadius.circular(AppRadius.base),
      ),
      child: Row(children: [
        Text(icon, style: const TextStyle(fontSize: 18)),
        const SizedBox(width: 10),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: const TextStyle(fontSize: 10.5, color: AppColors.gray400)),
            Text(val, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
          ]),
        ),
        TextButton(onPressed: onAction,
            child: Text(action,
                style: const TextStyle(color: AppColors.brandRed, fontWeight: FontWeight.w700))),
      ]),
    );
  }
}

class _BillRow extends StatelessWidget {
  final String label, val;
  final bool bold;
  final Color? valueColor;
  const _BillRow(this.label, this.val, {this.bold = false, this.valueColor});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label,
          style: TextStyle(
              fontWeight: bold ? FontWeight.w800 : FontWeight.w500,
              fontSize: bold ? 15 : 13)),
      Text(val,
          style: TextStyle(
              fontWeight: bold ? FontWeight.w800 : FontWeight.w500,
              fontSize: bold ? 15 : 13,
              color: valueColor ?? (bold ? AppColors.gray900 : AppColors.gray700))),
    ]),
  );
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: Text(text,
        style: const TextStyle(
            fontSize: 11, fontWeight: FontWeight.w700,
            color: AppColors.gray400, letterSpacing: 1)),
  );
}

class _SubSectionHeader extends StatelessWidget {
  final String text;
  const _SubSectionHeader(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 14, bottom: 8, left: 2),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: AppColors.gray500,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _PaymentTile extends StatelessWidget {
  final Widget iconWidget;
  final String title;
  final Widget? trailingWidget;
  final VoidCallback onTap;

  const _PaymentTile({
    required this.iconWidget,
    required this.title,
    this.trailingWidget,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppShadows.subtle,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              SizedBox(width: 36, child: Center(child: iconWidget)),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.gray900),
                ),
              ),
              trailingWidget ?? const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.gray800),
            ],
          ),
        ),
      ),
    );
  }
}

class _SelectablePayTile extends StatelessWidget {
  final String id;
  final String selectedId;
  final Widget iconWidget;
  final String title;
  final Widget? trailingWidget;
  final VoidCallback onTap;

  const _SelectablePayTile({
    required this.id,
    required this.selectedId,
    required this.iconWidget,
    required this.title,
    this.trailingWidget,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final selected = id == selectedId;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: selected ? AppColors.brandRed : Colors.transparent,
          width: 2,
        ),
        boxShadow: AppShadows.subtle,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              SizedBox(width: 36, child: Center(child: iconWidget)),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.gray900),
                ),
              ),
              if (trailingWidget != null) trailingWidget!,
            ],
          ),
        ),
      ),
    );
  }
}

class _CircleNavHeader extends StatelessWidget {
  final String title;
  final VoidCallback onBack;
  const _CircleNavHeader({required this.title, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        boxShadow: AppShadows.subtle,
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.gray300),
            ),
            child: IconButton(
              padding: EdgeInsets.zero,
              onPressed: onBack,
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: AppColors.gray800),
            ),
          ),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.gray900),
            ),
          ),
          const SizedBox(width: 38), // Balance for centering title
        ],
      ),
    );
  }
}
