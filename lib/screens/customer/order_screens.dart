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
    final appState = context.watch<AppState>();
    final order = appState.orders.firstWhere(
      (o) => o.id == appState.lastOrderId,
      orElse: () => appState.orders.first,
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Top Navigation Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
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
                      onPressed: () => nav('home'),
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: AppColors.gray800),
                    ),
                  ),
                  const Expanded(
                    child: Text(
                      'Order',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.gray900),
                    ),
                  ),
                  const SizedBox(width: 38),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 12),
                    // Confirmation Heading
                    const Text(
                      'Your order is being placed',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.gray900),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Order #${order.id} · ${order.date}',
                      style: const TextStyle(fontSize: 13, color: AppColors.gray500),
                    ),
                    const SizedBox(height: 20),

                    // Dynamic Order Lifecycle Progress Timeline Section
                    _OrderLifecycleTimeline(status: order.statusEnum),
                    const SizedBox(height: 20),

                    // Delivery Address Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.gray200),
                        boxShadow: AppShadows.subtle,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: const [
                              Icon(Icons.location_on_rounded, color: AppColors.brandRed, size: 20),
                              SizedBox(width: 8),
                              Text('Delivery Address', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.gray900)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            order.address,
                            style: const TextStyle(fontSize: 13, color: AppColors.gray700, height: 1.4),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Customer / Receiver Info Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.gray200),
                        boxShadow: AppShadows.subtle,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEF2F2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.person_outline_rounded, color: AppColors.brandRed, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  appState.userName.isNotEmpty ? appState.userName : 'DilipKumar K',
                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.gray900),
                                ),
                                Text(
                                  appState.userPhone.isNotEmpty ? appState.userPhone : '+91 9959490999',
                                  style: const TextStyle(fontSize: 12, color: AppColors.gray500),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Help & Cancel Order Actions
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => showAppToast(context, 'Connecting with Country Meat Support... 📞'),
                            icon: const Icon(Icons.help_outline_rounded, size: 16),
                            label: const Text('Help'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.gray800,
                              side: const BorderSide(color: AppColors.gray300),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _showCancelDialog(context, appState, order.id),
                            icon: const Icon(Icons.cancel_outlined, size: 16),
                            label: const Text('Cancel Order'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.brandRed,
                              side: const BorderSide(color: AppColors.brandRed),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Dev State Stepper Pill (Isolated for UI testing during review)
                    InkWell(
                      onTap: () {
                        appState.advanceOrderStatus(order.id);
                        showAppToast(context, 'Status updated: ${order.statusEnum.label}');
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFE5E7EB)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.bolt_rounded, size: 14, color: Color(0xFFF59E0B)),
                            const SizedBox(width: 4),
                            Text(
                              'Dev Toggle: ${order.statusEnum.label} (Tap to change)',
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.gray700),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // Fixed Bottom Track Order CTA
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: AppColors.gray200)),
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => nav('tracking', param: order.id),
                  icon: const Icon(Icons.local_shipping_rounded, size: 18),
                  label: const Text('Track Order'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.brandRed,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCancelDialog(BuildContext context, AppState appState, String orderId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel Order?'),
        content: const Text('Are you sure you want to cancel this order? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Keep Order'),
          ),
          TextButton(
            onPressed: () {
              appState.updateOrderStatus(orderId, OrderStatus.cancelled);
              Navigator.pop(ctx);
              showAppToast(context, 'Order #$orderId has been cancelled.');
            },
            child: const Text('Yes, Cancel', style: TextStyle(color: AppColors.brandRed, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

// ─── ORDER LIFECYCLE TIMELINE WIDGET ──────────────────────────────────────────
class _OrderLifecycleTimeline extends StatelessWidget {
  final OrderStatus status;
  const _OrderLifecycleTimeline({required this.status});

  @override
  Widget build(BuildContext context) {
    final stepIndex = switch (status) {
      OrderStatus.confirmed => 0,
      OrderStatus.slaughtering => 1,
      OrderStatus.driverAssigned => 2,
      OrderStatus.outForDelivery => 2,
      OrderStatus.delivered => 3,
      OrderStatus.cancelled => -1,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Column(
        children: [
          // Row 1: Node Circles + Connecting Lines
          Row(
            children: [
              _TimelineCircleNode(isCompleted: stepIndex >= 0, isActive: stepIndex == 0),
              Expanded(child: _TimelineConnectorLine(isCompleted: stepIndex >= 1)),
              _TimelineCircleNode(isCompleted: stepIndex >= 1, isActive: stepIndex == 1),
              Expanded(child: _TimelineConnectorLine(isCompleted: stepIndex >= 2)),
              _TimelineCircleNode(isCompleted: stepIndex >= 2, isActive: stepIndex >= 2),
            ],
          ),
          const SizedBox(height: 8),
          // Row 2: Status Labels (Strict 1-line horizontal alignment)
          Row(
            children: [
              Expanded(
                child: _TimelineLabelText(
                  title: 'Confirmed',
                  isCompleted: stepIndex >= 0,
                  isActive: stepIndex == 0,
                  align: TextAlign.left,
                ),
              ),
              Expanded(
                child: _TimelineLabelText(
                  title: 'Slaughtering',
                  isCompleted: stepIndex >= 1,
                  isActive: stepIndex == 1,
                  align: TextAlign.center,
                ),
              ),
              Expanded(
                child: _TimelineLabelText(
                  title: 'On the way',
                  isCompleted: stepIndex >= 2,
                  isActive: stepIndex >= 2,
                  align: TextAlign.right,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TimelineCircleNode extends StatelessWidget {
  final bool isCompleted;
  final bool isActive;

  const _TimelineCircleNode({
    required this.isCompleted,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    final color = isCompleted ? const Color(0xFF16A34A) : AppColors.gray300;
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: isCompleted ? const Color(0xFF16A34A) : Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 2),
      ),
      child: isCompleted
          ? const Icon(Icons.check_rounded, color: Colors.white, size: 16)
          : (isActive
              ? Center(
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFF16A34A),
                      shape: BoxShape.circle,
                    ),
                  ),
                )
              : const SizedBox()),
    );
  }
}

class _TimelineConnectorLine extends StatelessWidget {
  final bool isCompleted;
  const _TimelineConnectorLine({required this.isCompleted});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 3,
      color: isCompleted ? const Color(0xFF16A34A) : AppColors.gray200,
    );
  }
}

class _TimelineLabelText extends StatelessWidget {
  final String title;
  final bool isCompleted;
  final bool isActive;
  final TextAlign align;

  const _TimelineLabelText({
    required this.title,
    required this.isCompleted,
    required this.isActive,
    required this.align,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      textAlign: align,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: 11.5,
        fontWeight: isCompleted || isActive ? FontWeight.w700 : FontWeight.w500,
        color: isCompleted || isActive ? AppColors.gray900 : AppColors.gray400,
      ),
    );
  }
}

// ─── ORDER TRACKING ───────────────────────────────────────────────────────────
class CustTrackingScreen extends StatelessWidget {
  final String orderId;
  final void Function(String screen, {String? param}) nav;
  const CustTrackingScreen({super.key, required this.orderId, required this.nav});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final order = appState.orders.firstWhere(
      (o) => o.id == orderId,
      orElse: () => appState.orders.first,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: Column(
          children: [
            _CircleNavHeader(title: 'Order Tracking', onBack: () => nav('orders')),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                children: [
                  // Dev State Stepper Pill
                  Center(
                    child: InkWell(
                      onTap: () {
                        appState.advanceOrderStatus(order.id);
                        showAppToast(context, 'Status updated: ${order.statusEnum.label}');
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF2F2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.brandRed.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.bolt_rounded, size: 14, color: AppColors.brandRed),
                            const SizedBox(width: 4),
                            Text(
                              'Dev Status: ${order.statusEnum.label} (Tap to change)',
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.brandRed),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Delivered State View
                  if (order.statusEnum == OrderStatus.delivered) ...[
                    _DeliveredStateCard(
                      order: order,
                      onRateSubmit: (score, feedback) {
                        appState.rateOrder(order.id, score, feedback);
                        showAppToast(context, 'Rating submitted! ⭐ Thank you.');
                        nav('home');
                      },
                    ),
                    const SizedBox(height: 16),
                  ] else ...[
                    // Visual Mock Tracking Map Widget
                    _VisualTrackingMap(
                      status: order.statusEnum,
                      etaText: order.etaText,
                      address: order.address,
                    ),
                    const SizedBox(height: 16),

                    // Driver Information Card (for assigned/outForDelivery)
                    if (order.statusEnum == OrderStatus.driverAssigned || order.statusEnum == OrderStatus.outForDelivery) ...[
                      _DriverInfoCard(driver: order.driverInfo),
                      const SizedBox(height: 16),
                    ],
                  ],

                  // Items Card
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: AppShadows.subtle,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.asset(
                            order.items.isNotEmpty ? order.items.first.product.img : 'assets/images/country_king.jpg',
                            width: 70,
                            height: 70,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                order.items.isNotEmpty ? order.items.first.product.name : 'Country King Chicken',
                                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.gray900),
                              ),
                              const SizedBox(height: 2),
                              Text('Order ID: #${order.id}', style: const TextStyle(fontSize: 11, color: AppColors.gray500)),
                              const SizedBox(height: 6),
                              Wrap(
                                spacing: 4,
                                runSpacing: 4,
                                children: [
                                  _TagChip(label: order.items.isNotEmpty ? '${order.items.first.cut} Cut' : 'Medium Cut'),
                                  _TagChip(label: order.items.isNotEmpty ? order.items.first.gender : 'Rooster'),
                                  _TagChip(label: 'Qty: ${order.items.isNotEmpty ? order.items.first.qty : 1}'),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Delivery Address Info Card
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.gray200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.location_on_rounded, color: AppColors.brandRed, size: 18),
                            SizedBox(width: 8),
                            Text('Delivery Address', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.gray900)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(order.address, style: const TextStyle(fontSize: 12.5, color: AppColors.gray600, height: 1.4)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Bill Summary Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.gray200),
                    ),
                    child: Column(
                      children: [
                        _BillLine(label: 'Item Subtotal', val: '₹${order.total - 40}'),
                        const SizedBox(height: 6),
                        const _BillLine(label: 'Delivery Fee', val: '₹40'),
                        const Divider(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Total Amount', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.gray900)),
                            Text('₹${order.total}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.brandRed)),
                          ],
                        ),
                      ],
                    ),
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

// ─── VISUAL MOCK TRACKING MAP ────────────────────────────────────────────────
class _VisualTrackingMap extends StatelessWidget {
  final OrderStatus status;
  final String etaText;
  final String address;

  const _VisualTrackingMap({
    required this.status,
    required this.etaText,
    required this.address,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFE5E7EB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gray300),
        boxShadow: AppShadows.subtle,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // Map Grid Background (Vector-style custom drawing layout)
            Container(
              color: const Color(0xFFE2E8F0),
              child: CustomPaint(
                size: Size.infinite,
                painter: _MockMapPainter(),
              ),
            ),

            // Top Floating ETA Badge
            Positioned(
              top: 12,
              left: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: AppShadows.card,
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Color(0xFFFEF2F2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.timer_outlined, size: 18, color: AppColors.brandRed),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            status == OrderStatus.slaughtering
                                ? 'Ethical Slaughtering & Prep'
                                : status == OrderStatus.confirmed
                                    ? 'Order Received at Farm Store'
                                    : 'Estimated Arrival in $etaText',
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.gray900),
                          ),
                          Text(
                            status == OrderStatus.slaughtering
                                ? 'Fresh desi bird prepared on order'
                                : 'Live delivery tracking active',
                            style: const TextStyle(fontSize: 11, color: AppColors.gray500),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Store Pin (Left)
            Positioned(
              bottom: 40,
              left: 30,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: AppColors.brandRed,
                      shape: BoxShape.circle,
                      boxShadow: AppShadows.card,
                    ),
                    child: const Icon(Icons.storefront_rounded, color: Colors.white, size: 18),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text('Country Farm Store', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            ),

            // Customer Destination Pin (Right)
            Positioned(
              top: 75,
              right: 30,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Color(0xFF16A34A),
                      shape: BoxShape.circle,
                      boxShadow: AppShadows.card,
                    ),
                    child: const Icon(Icons.home_rounded, color: Colors.white, size: 18),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text('Delivery Location', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            ),

            // Delivery Partner Moving Marker (Middle)
            if (status == OrderStatus.outForDelivery || status == OrderStatus.driverAssigned)
              Positioned(
                bottom: 80,
                left: 140,
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: AppShadows.card,
                      ),
                      child: const Icon(Icons.delivery_dining_rounded, color: AppColors.brandRed, size: 24),
                    ),
                    const SizedBox(height: 2),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.brandRed,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text('Partner On The Way', style: TextStyle(fontSize: 8.5, color: Colors.white, fontWeight: FontWeight.w800)),
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

class _MockMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paintRoad = Paint()
      ..color = Colors.white
      ..strokeWidth = 14
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final paintRoute = Paint()
      ..color = const Color(0xFFEF4444)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Road grid
    final pathGrid = Path();
    pathGrid.moveTo(0, size.height * 0.7);
    pathGrid.cubicTo(size.width * 0.3, size.height * 0.8, size.width * 0.5, size.height * 0.4, size.width, size.height * 0.35);

    pathGrid.moveTo(size.width * 0.4, 0);
    pathGrid.lineTo(size.width * 0.45, size.height);

    canvas.drawPath(pathGrid, paintRoad);

    // Route line
    final pathRoute = Path();
    pathRoute.moveTo(40, size.height * 0.7);
    pathRoute.cubicTo(size.width * 0.3, size.height * 0.8, size.width * 0.5, size.height * 0.4, size.width - 45, size.height * 0.35);

    canvas.drawPath(pathRoute, paintRoute);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─── DRIVER INFO CARD ────────────────────────────────────────────────────────
class _DriverInfoCard extends StatelessWidget {
  final DriverInfo driver;
  const _DriverInfoCard({required this.driver});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.gray200),
        boxShadow: AppShadows.subtle,
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFFEF2F2),
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.brandRed, width: 1.5),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: const Icon(Icons.person_rounded, color: AppColors.brandRed, size: 28),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      driver.name,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.gray900),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '★ ${driver.rating}',
                        style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: Color(0xFFD97706)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text('Delivery Partner · ${driver.vehicleNo}', style: const TextStyle(fontSize: 12, color: AppColors.gray500)),
              ],
            ),
          ),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDF4),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF16A34A)),
            ),
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: const Icon(Icons.phone_rounded, color: Color(0xFF16A34A), size: 20),
              onPressed: () => showAppToast(context, 'Calling ${driver.name} (${driver.phone})... 📞'),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── DELIVERED STATE CARD WITH RATING ─────────────────────────────────────────
class _DeliveredStateCard extends StatefulWidget {
  final CustomerOrder order;
  final Function(int score, String feedback) onRateSubmit;

  const _DeliveredStateCard({
    required this.order,
    required this.onRateSubmit,
  });

  @override
  State<_DeliveredStateCard> createState() => _DeliveredStateCardState();
}

class _DeliveredStateCardState extends State<_DeliveredStateCard> {
  int _selectedRating = 5;
  final TextEditingController _feedbackCtrl = TextEditingController();
  bool _submitted = false;

  @override
  void initState() {
    super.initState();
    if (widget.order.ratingScore != null) {
      _selectedRating = widget.order.ratingScore!;
      _submitted = true;
    }
  }

  @override
  void dispose() {
    _feedbackCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFDCFCE7), width: 1.5),
        boxShadow: AppShadows.subtle,
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
              color: Color(0xFFDCFCE7),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_circle_rounded, color: Color(0xFF16A34A), size: 44),
          ),
          const SizedBox(height: 12),
          const Text(
            'Your order has been delivered! 🍗',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.gray900),
          ),
          const SizedBox(height: 4),
          const Text(
            'Enjoy your fresh Country Meat experience',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12.5, color: AppColors.gray500),
          ),
          const SizedBox(height: 18),
          const Divider(),
          const SizedBox(height: 10),

          Text(
            _submitted ? 'Your Delivery Rating' : 'Rate Your Delivery Experience',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.gray900),
          ),
          const SizedBox(height: 10),

          // Star Rating Row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (i) {
              final starNum = i + 1;
              return GestureDetector(
                onTap: _submitted ? null : () => setState(() => _selectedRating = starNum),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Icon(
                    starNum <= _selectedRating ? Icons.star_rounded : Icons.star_outline_rounded,
                    color: const Color(0xFFF59E0B),
                    size: 36,
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 12),

          if (!_submitted) ...[
            TextField(
              controller: _feedbackCtrl,
              decoration: InputDecoration(
                hintText: 'Leave optional feedback for driver & meat quality...',
                hintStyle: const TextStyle(fontSize: 12.5, color: AppColors.gray400),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.gray300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.brandRed),
                ),
                isDense: true,
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitted
                    ? null
                    : () {
                        setState(() => _submitted = true);
                        widget.onRateSubmit(_selectedRating, _feedbackCtrl.text.trim());
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.brandRed,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                ),
                child: const Text('Submit Rating'),
              ),
            ),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.thumb_up_alt_rounded, size: 16, color: Color(0xFF16A34A)),
                  SizedBox(width: 6),
                  Text('Rating Saved. Thank you!', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF16A34A))),
                ],
              ),
            ),
          ],
        ],
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
