import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/product.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';

// ─── ORDER CONFIRMATION ───────────────────────────────────────────────────────
class CustConfirmationScreen extends StatelessWidget {
  final void Function(String screen, {String? param}) nav;
  const CustConfirmationScreen({super.key, required this.nav});

  @override
  Widget build(BuildContext context) {
    final appState = context.read<AppState>();
    final order = appState.orders.firstWhere(
      (o) => o.id == appState.lastOrderId,
      orElse: () => appState.orders.first,
    );

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    // Success animation
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: AppColors.successLight,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.success, width: 2),
                      ),
                      child: const Icon(Icons.check_rounded,
                          color: AppColors.success, size: 52),
                    ),
                    const SizedBox(height: 20),
                    const Text('Order Confirmed! 🎉',
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 6),
                    Text(
                      'Your fresh meat will be delivered by ${order.deliverySlot} tomorrow.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          color: AppColors.gray500, fontSize: 14, height: 1.5),
                    ),
                    const SizedBox(height: 24),
                    // Order details card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.gray50,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(order.id,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.brandRed)),
                                Text(order.date,
                                    style: const TextStyle(
                                        color: AppColors.gray400,
                                        fontSize: 12)),
                              ]),
                          const Divider(height: 20),
                          ...order.items.map((item) => Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Row(children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(6),
                                    child: Image.asset(item.product.img,
                                        height: 44,
                                        width: 44,
                                        fit: BoxFit.cover),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(item.product.name,
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 13)),
                                          Text(
                                              '${item.cut} Cut · ${item.gender} · Qty ${item.qty}',
                                              style: const TextStyle(
                                                  fontSize: 11,
                                                  color: AppColors.gray400)),
                                        ]),
                                  ),
                                  Text('₹${item.lineTotal}',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w700)),
                                ]),
                              )),
                          const Divider(height: 16),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Grand Total',
                                    style:
                                        TextStyle(fontWeight: FontWeight.w800)),
                                Text('₹${order.total}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 16)),
                              ]),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Delivery info
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.brandRedBg,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Delivery Details',
                              style: TextStyle(
                                  fontWeight: FontWeight.w700, fontSize: 13)),
                          const SizedBox(height: 10),
                          _DetailRow(
                              icon: '🕕',
                              label: 'Slot',
                              val: order.deliverySlot),
                          _DetailRow(
                              icon: '📍', label: 'Address', val: order.address),
                          _DetailRow(
                              icon: '🚚',
                              label: 'Agent',
                              val: '${order.agent} · ${order.agentPhone}'),
                          _DetailRow(
                              icon: '⭐',
                              label: 'Points Earned',
                              val: '+${order.points} reward points'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Track button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => nav('tracking', param: order.id),
                        child: const Text('📍 Track My Order'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => nav('home'),
                  child: const Text('Continue Shopping →'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── ORDER TRACKING ───────────────────────────────────────────────────────────
class CustTrackingScreen extends StatelessWidget {
  final String orderId;
  final void Function(String screen, {String? param}) nav;
  const CustTrackingScreen(
      {super.key, required this.orderId, required this.nav});

  @override
  Widget build(BuildContext context) {
    final appState = context.read<AppState>();
    final order = appState.orders.firstWhere(
      (o) => o.id == orderId,
      orElse: () => appState.orders.first,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: Column(
          children: [
            _CircleNavHeader(
                title: 'Order Details', onBack: () => nav('orders')),
            Expanded(
              child: ListView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                children: [
                  // Order Status Banner Card
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: AppShadows.subtle,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(
                              order.status == 'Confirmed' ? '🚜' : order.status == 'Delivered' ? '🍗' : '🚚',
                              style: const TextStyle(fontSize: 24),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  order.status == 'Confirmed'
                                      ? 'Order Confirmed & Sourced'
                                      : order.status == 'Delivered'
                                          ? 'Order Was Delivered'
                                          : 'Out for Dawn Delivery',
                                  style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.gray900),
                                ),
                                Text(
                                  'Slot: ${order.deliverySlot}',
                                  style: const TextStyle(fontSize: 11, color: AppColors.gray500),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Text(order.status == 'Confirmed' ? '✅' : '🥚', style: const TextStyle(fontSize: 22)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Item Detail Card
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: AppShadows.subtle,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.asset(
                            order.items.isNotEmpty
                                ? order.items.first.product.img
                                : 'assets/images/country_king.jpg',
                            width: 84,
                            height: 84,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                order.items.isNotEmpty
                                    ? order.items.first.product.name
                                    : 'Country King Chicken',
                                style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.gray900),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Order ID : #${order.id}',
                                style: const TextStyle(
                                    fontSize: 11, color: AppColors.gray500),
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 4,
                                runSpacing: 4,
                                children: const [
                                  _TagChip(label: 'Chicken'),
                                  _TagChip(label: '1.1 - 1.5 kg'),
                                  _TagChip(label: 'Rooster'),
                                  _TagChip(label: 'Medium Cut'),
                                  _TagChip(label: 'Smoked & Turmeric'),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Bill Summary Header
                  Row(
                    children: [
                      const Text(
                        'Bill Summary',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.gray900),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.brandRed),
                        ),
                        child: const Icon(Icons.arrow_downward_rounded,
                            size: 14, color: AppColors.brandRed),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Bill Summary Card
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.gray200),
                    ),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              _BillLine(
                                  label: 'Item total',
                                  val:
                                      '₹${order.total > 40 ? order.total - 40 : 950}'),
                              const SizedBox(height: 8),
                              _BillLine(
                                label: 'Store packing charges',
                                sub: 'This is decided and charged by the store',
                                val: '₹5',
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Delivery partner fee',
                                      style: TextStyle(
                                          fontSize: 13,
                                          color: AppColors.gray800)),
                                  Row(
                                    children: const [
                                      Text('₹39 ',
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: AppColors.gray400,
                                              decoration:
                                                  TextDecoration.lineThrough)),
                                      Text('₹20',
                                          style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.brandRed)),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              _BillLine(label: 'Platform fee', val: '₹12'),
                              const SizedBox(height: 8),
                              _BillLine(label: 'GST(govt.taxes)', val: ''),
                              const Divider(height: 20),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('To Pay',
                                      style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w800)),
                                  Text('₹${order.total}',
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w800)),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Save with Wallet banner
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFFE53935), Color(0xFFFFB300)],
                            ),
                            borderRadius: BorderRadius.vertical(
                                bottom: Radius.circular(15)),
                          ),
                          child: const Text(
                            'Save your ₹13 with Wallet',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Customer & Delivery Info Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.gray200),
                    ),
                    child: Column(
                      children: [
                        _InfoItemRow(
                          icon: Icons.phone_outlined,
                          title: 'DilipKumar K,',
                          sub: '+91-9959490999',
                        ),
                        const Divider(height: 16),
                        _InfoItemRow(
                          icon: Icons.credit_card_rounded,
                          title: 'Payment Method',
                          sub: 'Paid via : UPI',
                        ),
                        const Divider(height: 16),
                        _InfoItemRow(
                          icon: Icons.calendar_today_rounded,
                          title: 'Payment Date',
                          sub: 'October 1 ,2025 at 4:22PM',
                        ),
                        const Divider(height: 16),
                        _InfoItemRow(
                          icon: Icons.location_on_outlined,
                          title: 'Delivery Address',
                          sub: '3rd Cross , Basaweshwara Nagara , Hebbal',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Action Buttons Row
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            showAppToast(context, 'Items added to cart!');
                            nav('home');
                          },
                          icon: const Icon(Icons.refresh_rounded,
                              color: Colors.white, size: 18),
                          label: const Text('Reorder'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.brandRed,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            textStyle: const TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => showAppToast(
                              context, 'Downloading Invoice PDF...'),
                          icon: const Icon(Icons.receipt_long_rounded,
                              color: AppColors.brandRed, size: 18),
                          label: const Text('Invoice'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.brandRed,
                            side: const BorderSide(color: AppColors.brandRed),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            textStyle: const TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                    ],
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
}

// ─── ORDERS LIST ─────────────────────────────────────────────────────────────
class CustOrdersScreen extends StatefulWidget {
  final void Function(String screen, {String? param}) nav;
  const CustOrdersScreen({super.key, required this.nav});

  @override
  State<CustOrdersScreen> createState() => _CustOrdersScreenState();
}

class _CustOrdersScreenState extends State<CustOrdersScreen> {
  String _selectedTab = 'All';

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final allOrders = appState.orders;

    final filteredOrders = switch (_selectedTab) {
      'Active' => allOrders.where((o) => o.isActive).toList(),
      'Delivered' => allOrders.where((o) => o.status == 'Delivered').toList(),
      'Cancelled' => allOrders.where((o) => o.status == 'Cancelled').toList(),
      _ => allOrders,
    };

    final activeCount = allOrders.where((o) => o.isActive).length;
    final deliveredCount =
        allOrders.where((o) => o.status == 'Delivered').length;
    final cancelledCount =
        allOrders.where((o) => o.status == 'Cancelled').length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top Header & Filter Tabs
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () => widget.nav('home'),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: AppColors.gray100,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_back_ios_new_rounded,
                          size: 16, color: AppColors.gray800),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'My Orders',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: AppColors.gray900),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.brandRedBg,
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                    child: Text(
                      '${allOrders.length}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: AppColors.brandRed,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              // Filter Tabs
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _FilterTabChip(
                      label: 'All Orders',
                      count: allOrders.length,
                      isSelected: _selectedTab == 'All',
                      onTap: () => setState(() => _selectedTab = 'All'),
                    ),
                    const SizedBox(width: 8),
                    _FilterTabChip(
                      label: 'Active',
                      count: activeCount,
                      isSelected: _selectedTab == 'Active',
                      onTap: () => setState(() => _selectedTab = 'Active'),
                    ),
                    const SizedBox(width: 8),
                    _FilterTabChip(
                      label: 'Delivered',
                      count: deliveredCount,
                      isSelected: _selectedTab == 'Delivered',
                      onTap: () => setState(() => _selectedTab = 'Delivered'),
                    ),
                    const SizedBox(width: 8),
                    _FilterTabChip(
                      label: 'Cancelled',
                      count: cancelledCount,
                      isSelected: _selectedTab == 'Cancelled',
                      onTap: () => setState(() => _selectedTab = 'Cancelled'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Orders List or Empty View
        Expanded(
          child: filteredOrders.isEmpty
              ? _EmptyOrdersView(
                  selectedTab: _selectedTab,
                  onShopNow: () => widget.nav('home'))
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  itemCount: filteredOrders.length,
                  itemBuilder: (ctx, i) {
                    final o = filteredOrders[i];
                    return _OrderCardItem(
                      order: o,
                      onTap: () => widget.nav('tracking', param: o.id),
                      onReorder: () {
                        for (final item in o.items) {
                          appState.addToCart(item.product);
                        }
                        showAppToast(
                            context, 'Reordered! Items added to cart 🛒');
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }
}

// ─── ORDER CARD ITEM ─────────────────────────────────────────────────────────
class _OrderCardItem extends StatelessWidget {
  final CustomerOrder order;
  final VoidCallback onTap;
  final VoidCallback onReorder;

  const _OrderCardItem({
    required this.order,
    required this.onTap,
    required this.onReorder,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
          boxShadow: const [
            BoxShadow(
              color: Color(0x08000000),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Header Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                color: Color(0xFFF9FAFB),
                borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0xFFE5E7EB)),
                        ),
                        child: Text(
                          '#${order.id}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                            color: AppColors.gray900,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        order.date,
                        style: const TextStyle(
                          color: AppColors.gray500,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  _StatusBadge(status: order.status),
                ],
              ),
            ),

            const Divider(height: 1, color: Color(0xFFF3F4F6)),

            // Middle Details Section
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  if (order.items.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset(
                        order.items.first.product.img,
                        height: 54,
                        width: 54,
                        fit: BoxFit.cover,
                      ),
                    ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order.items.isNotEmpty
                              ? order.items.first.product.name
                              : 'Country Meat Pack',
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 14.5,
                            color: AppColors.gray900,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          order.items.length > 1
                              ? '${order.items.first.cut} Cut · ${order.items.first.gender} +${order.items.length - 1} more items'
                              : '${order.items.first.cut} Cut · ${order.items.first.gender} · Qty: ${order.items.first.qty}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.gray500,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 7, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEF2F2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.schedule_rounded,
                                      size: 12, color: AppColors.brandRed),
                                  const SizedBox(width: 4),
                                  Text(
                                    order.deliverySlot,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.brandRed,
                                    ),
                                  ),
                                ],
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

            const Divider(height: 1, color: Color(0xFFF3F4F6)),

            // Bottom Action Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Total Bill',
                        style: TextStyle(
                            fontSize: 10.5,
                            color: AppColors.gray400,
                            fontWeight: FontWeight.w500),
                      ),
                      Text(
                        '₹${order.total}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 16.5,
                          color: AppColors.gray900,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      OutlinedButton.icon(
                        onPressed: onReorder,
                        icon: const Icon(Icons.refresh_rounded, size: 14),
                        label: const Text('Reorder'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.brandRed,
                          side: const BorderSide(
                              color: AppColors.brandRed, width: 1.2),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                          textStyle: const TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w700),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: onTap,
                        icon: const Icon(Icons.chevron_right_rounded, size: 16),
                        label: const Text('Details'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.brandRed,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                          textStyle: const TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w700),
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

// ─── FILTER TAB CHIP ─────────────────────────────────────────────────────────
class _FilterTabChip extends StatelessWidget {
  final String label;
  final int count;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterTabChip({
    required this.label,
    required this.count,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.brandRed : AppColors.gray100,
          borderRadius: BorderRadius.circular(AppRadius.full),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.gray700,
                fontSize: 12.5,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              ),
            ),
            if (count > 0) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withOpacity(0.25)
                      : AppColors.gray300,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppColors.gray800,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
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

// ─── EMPTY ORDERS VIEW ───────────────────────────────────────────────────────
class _EmptyOrdersView extends StatelessWidget {
  final String selectedTab;
  final VoidCallback onShopNow;

  const _EmptyOrdersView({
    required this.selectedTab,
    required this.onShopNow,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: const BoxDecoration(
                color: Color(0xFFFEF2F2),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text('🍗', style: TextStyle(fontSize: 36)),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              selectedTab == 'All'
                  ? 'No orders placed yet'
                  : 'No $selectedTab orders',
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.gray900),
            ),
            const SizedBox(height: 8),
            const Text(
              'Order fresh, free-range country chicken & meats delivered straight from open farms to your doorstep.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: AppColors.gray500, fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onShopNow,
              icon: const Icon(Icons.shopping_bag_outlined, size: 18),
              label: const Text('Explore Fresh Meats →'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.brandRed,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                textStyle:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final (color, bg, icon) = switch (status) {
      'Confirmed' => (
          const Color(0xFF1D4ED8),
          const Color(0xFFEFF6FF),
          Icons.check_circle_outline_rounded
        ),
      'Preparing' => (
          const Color(0xFFC2410C),
          const Color(0xFFFFF7ED),
          Icons.local_fire_department_rounded
        ),
      'Out for Delivery' => (
          AppColors.brandRed,
          const Color(0xFFFEF2F2),
          Icons.local_shipping_outlined
        ),
      'Delivered' => (
          const Color(0xFF15803D),
          const Color(0xFFF0FDF4),
          Icons.check_circle_rounded
        ),
      _ => (
          AppColors.gray600,
          const Color(0xFFF3F4F6),
          Icons.info_outline_rounded
        ),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
          color: bg, borderRadius: BorderRadius.circular(AppRadius.full)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            status,
            style: TextStyle(
                color: color, fontSize: 11, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

// ─── HELPERS ─────────────────────────────────────────────────────────────────
class _TrackStep {
  final String title, sub, icon;
  final bool done;
  const _TrackStep(
      {required this.title,
      required this.sub,
      required this.icon,
      required this.done});
}

class _TimelineStep extends StatelessWidget {
  final _TrackStep step;
  final bool isLast;
  const _TimelineStep({required this.step, required this.isLast});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: step.done ? AppColors.success : AppColors.gray100,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: step.done
                ? const Icon(Icons.check_rounded, color: Colors.white, size: 18)
                : Text(step.icon, style: const TextStyle(fontSize: 16)),
          ),
          if (!isLast)
            Container(
              width: 2,
              height: 40,
              color: step.done ? AppColors.success : AppColors.gray200,
            ),
        ]),
        const SizedBox(width: 14),
        Padding(
          padding: const EdgeInsets.only(top: 6, bottom: 16),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(step.title,
                style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: step.done ? AppColors.gray900 : AppColors.gray400)),
            Text(step.sub,
                style: const TextStyle(fontSize: 12, color: AppColors.gray500)),
          ]),
        ),
      ],
    );
  }
}

class _OrderItemRow extends StatelessWidget {
  final CartItem item;
  const _OrderItemRow({required this.item});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Image.asset(item.product.img,
                height: 38, width: 38, fit: BoxFit.cover),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text('${item.product.name} (${item.cut} · Qty ${item.qty})',
                style: const TextStyle(
                    fontSize: 12.5, fontWeight: FontWeight.w500)),
          ),
          Text('₹${item.lineTotal}',
              style:
                  const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
        ]),
      );
}

class _DetailRow extends StatelessWidget {
  final String icon, label, val;
  const _DetailRow(
      {required this.icon, required this.label, required this.val});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(icon, style: const TextStyle(fontSize: 13)),
          const SizedBox(width: 8),
          Text('$label: ',
              style: const TextStyle(fontSize: 12, color: AppColors.gray500)),
          Expanded(
              child: Text(val,
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w600))),
        ]),
      );
}

class _TagChip extends StatelessWidget {
  final String label;
  const _TagChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Text(
        label,
        style: const TextStyle(
            fontSize: 10,
            color: Color(0xFF4B5563),
            fontWeight: FontWeight.w500),
      ),
    );
  }
}

class _BillLine extends StatelessWidget {
  final String label;
  final String val;
  final String? sub;
  const _BillLine({required this.label, required this.val, this.sub});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style:
                      const TextStyle(fontSize: 13, color: AppColors.gray800)),
              if (sub != null)
                Text(sub!,
                    style: const TextStyle(
                        fontSize: 10, color: AppColors.gray400)),
            ],
          ),
        ),
        if (val.isNotEmpty)
          Text(val,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.gray900)),
      ],
    );
  }
}

class _InfoItemRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String sub;
  const _InfoItemRow(
      {required this.icon, required this.title, required this.sub});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppColors.gray700),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.gray900)),
              const SizedBox(height: 2),
              Text(sub,
                  style:
                      const TextStyle(fontSize: 12, color: AppColors.gray500)),
            ],
          ),
        ),
      ],
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
              icon: const Icon(Icons.arrow_back_ios_new_rounded,
                  size: 16, color: AppColors.gray800),
            ),
          ),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.gray900),
            ),
          ),
          const SizedBox(width: 38), // Balance for centering title
        ],
      ),
    );
  }
}
