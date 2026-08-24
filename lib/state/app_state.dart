import 'package:flutter/foundation.dart';
import '../models/product.dart';
import '../data/mock_data.dart';
import '../services/firebase_service.dart';

class AppState extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();

  AppState() {
    _initFirebase();
  }

  void _initFirebase() async {
    await _firebaseService.seedDatabaseIfEmpty();
    _firebaseService.saveUserProfile(
      phone: userPhone,
      name: userName,
      rewardPoints: rewardPoints,
      addresses: addresses,
    );

    _firebaseService.getOrdersStream().listen((firestoreOrders) {
      if (firestoreOrders.isNotEmpty) {
        orders = firestoreOrders;
        notifyListeners();
      }
    });
  }

  // ── Cart ──────────────────────────────────────────────────────────────────
  final List<CartItem> cart = [];

  int get cartCount => cart.fold(0, (sum, item) => sum + item.qty);
  int get cartTotal => cart.fold(0, (sum, item) => sum + item.lineTotal);

  void addToCart(Product p, {String cut = 'Medium', String? gender, String slot = '6AM–9AM'}) {
    final existing = cart.where((c) => c.product.id == p.id && c.cut == cut);
    if (existing.isNotEmpty) {
      existing.first.qty++;
    } else {
      cart.add(CartItem(
        product: p,
        qty: 1,
        cut: cut,
        gender: gender ?? (p.gender != 'Both' ? p.gender : 'Rooster'),
        slot: slot,
      ));
    }
    notifyListeners();
  }

  void changeQty(int index, int delta) {
    cart[index].qty += delta;
    if (cart[index].qty <= 0) cart.removeAt(index);
    notifyListeners();
  }

  void clearCart() {
    cart.clear();
    notifyListeners();
  }

  // ── Orders ────────────────────────────────────────────────────────────────
  List<CustomerOrder> orders = List.from(kMockOrders);

  void placeOrder(String slot, String address, {String paymentMethod = 'UPI / PhonePe', String txnId = '', int? customTotal}) {
    final orderTotal = customTotal ?? (cartTotal + 40);
    final newOrder = CustomerOrder(
      id: 'ORD${(orders.length + 1).toString().padLeft(3, '0')}',
      date: _todayStr(),
      items: List.from(cart),
      total: orderTotal,
      status: 'Confirmed',
      deliverySlot: slot,
      agent: 'Ravi Kumar',
      agentPhone: '+91 9876543210',
      address: address,
      points: (orderTotal * 0.05).round(),
      paymentMethod: paymentMethod,
      txnId: txnId.isNotEmpty ? txnId : 'TXN${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}',
    );
    orders.insert(0, newOrder);
    rewardPoints += newOrder.points;
    clearCart();
    lastOrderId = newOrder.id;
    notifyListeners();

    // Persist to Firestore
    _firebaseService.saveOrder(newOrder);
    _syncUserToFirestore();
  }

  String lastOrderId = '';

  // ── Rewards ───────────────────────────────────────────────────────────────
  int rewardPoints = 320;
  bool isRewardRedeemed = false;

  int get rewardDiscount => isRewardRedeemed ? ((rewardPoints / 100).floor() * 10) : 0;

  void toggleRewardRedemption(bool value) {
    isRewardRedeemed = value;
    notifyListeners();
  }

  String get rewardTier {
    if (rewardPoints >= 1000) return 'Platinum';
    if (rewardPoints >= 500) return 'Gold';
    return 'Silver';
  }

  int get nextTierPoints {
    if (rewardPoints >= 1000) return 0;
    if (rewardPoints >= 500) return 1000 - rewardPoints;
    return 500 - rewardPoints;
  }

  // ── User / Auth ───────────────────────────────────────────────────────────
  bool isLoggedIn = false;
  String userName = 'Arjun Kumar';
  String userPhone = '+91 98765 43210';
  String selectedSlot = '6AM–9AM';

  List<SavedAddress> addresses = const [
    SavedAddress(label: 'Home', address: 'Basaveshwara Nagar, Hebbal 1st Stage, Mysore', isDefault: true),
    SavedAddress(label: 'Work', address: '3rd Floor, Tech Park, Mysore Road, Bangalore'),
  ];

  String get defaultAddress =>
      addresses.firstWhere((a) => a.isDefault, orElse: () => addresses.first).address;

  void setSlot(String slot) {
    selectedSlot = slot;
    notifyListeners();
  }

  void updateUser(String name, String phone) {
    if (name.isNotEmpty) userName = name;
    if (phone.isNotEmpty) userPhone = phone;
    notifyListeners();
    _syncUserToFirestore();
  }

  void setDefaultAddress(SavedAddress target) {
    addresses = addresses.map((a) => SavedAddress(
      label: a.label,
      address: a.address,
      isDefault: a.address == target.address && a.label == target.label,
    )).toList();
    notifyListeners();
    _syncUserToFirestore();
  }

  void addAddress(SavedAddress address) {
    List<SavedAddress> list = List.from(addresses);
    if (address.isDefault) {
      list = list.map((a) => SavedAddress(label: a.label, address: a.address, isDefault: false)).toList();
    }
    list.add(address);
    addresses = list;
    notifyListeners();
    _syncUserToFirestore();
  }

  void removeAddress(SavedAddress address) {
    List<SavedAddress> list = List.from(addresses);
    list.removeWhere((a) => a.address == address.address && a.label == address.label);
    if (list.isNotEmpty && !list.any((a) => a.isDefault)) {
      list[0] = SavedAddress(label: list[0].label, address: list[0].address, isDefault: true);
    }
    addresses = list;
    notifyListeners();
    _syncUserToFirestore();
  }

  void _syncUserToFirestore() {
    _firebaseService.saveUserProfile(
      phone: userPhone,
      name: userName,
      rewardPoints: rewardPoints,
      addresses: addresses,
    );
  }

  // ── Navigation state ──────────────────────────────────────────────────────
  String currentCategory = 'chicken';

  void setCategory(String cat) {
    currentCategory = cat;
    notifyListeners();
  }

  // ── Helpers ───────────────────────────────────────────────────────────────
  String _todayStr() {
    final now = DateTime.now();
    final months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${now.day} ${months[now.month - 1]} ${now.year}';
  }
}
