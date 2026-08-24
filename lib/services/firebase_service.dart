import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../data/mock_data.dart';
import '../models/product.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ── 1. Seed Initial Products & Data ───────────────────────────────────────
  Future<void> seedDatabaseIfEmpty() async {
    try {
      final snapshot = await _db.collection('products').limit(1).get();
      if (snapshot.docs.isEmpty) {
        debugPrint('🌱 Seeding products catalog to Firestore...');
        final batch = _db.batch();

        for (final p in kAllProducts) {
          final docRef = _db.collection('products').doc(p.id);
          batch.set(docRef, {
            'id': p.id,
            'name': p.name,
            'sub': p.sub,
            'img': p.img,
            'tags': p.tags,
            'weight': p.weight,
            'price': p.price,
            'mrp': p.mrp,
            'discount': p.discount,
            'age': p.age,
            'serves': p.serves,
            'gender': p.gender,
            'desc': p.desc,
            'benefits': p.benefits,
            'category': p.category,
          });
        }
        await batch.commit();
        debugPrint('✅ Products successfully seeded to Firestore database!');
      }
    } catch (e) {
      debugPrint('⚠️ Error seeding database: $e');
    }
  }

  // ── 2. Real-time Stream Products ──────────────────────────────────────────
  Stream<List<Product>> getProductsStream() {
    return _db.collection('products').snapshots().map((snapshot) {
      if (snapshot.docs.isEmpty) return kAllProducts;
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Product(
          id: data['id'] ?? doc.id,
          name: data['name'] ?? '',
          sub: data['sub'] ?? '',
          img: data['img'] ?? '',
          tags: List<String>.from(data['tags'] ?? []),
          weight: data['weight'] ?? '',
          price: (data['price'] ?? 0) as int,
          mrp: (data['mrp'] ?? 0) as int,
          discount: (data['discount'] ?? 0) as int,
          age: data['age'] ?? '',
          serves: data['serves'] ?? '',
          gender: data['gender'] ?? '',
          desc: data['desc'] ?? '',
          benefits: List<String>.from(data['benefits'] ?? []),
          category: data['category'] ?? '',
        );
      }).toList();
    });
  }

  // ── 3. Save Order to Firestore ────────────────────────────────────────────
  Future<void> saveOrder(CustomerOrder order) async {
    try {
      await _db.collection('orders').doc(order.id).set({
        'id': order.id,
        'date': order.date,
        'total': order.total,
        'status': order.status,
        'deliverySlot': order.deliverySlot,
        'agent': order.agent,
        'agentPhone': order.agentPhone,
        'address': order.address,
        'points': order.points,
        'paymentMethod': order.paymentMethod,
        'txnId': order.txnId,
        'timestamp': FieldValue.serverTimestamp(),
        'items': order.items.map((item) => {
          'productId': item.product.id,
          'productName': item.product.name,
          'qty': item.qty,
          'cut': item.cut,
          'gender': item.gender,
          'slot': item.slot,
          'price': item.product.price,
          'lineTotal': item.lineTotal,
        }).toList(),
      });
      debugPrint('📦 Order ${order.id} saved to Firestore!');
    } catch (e) {
      debugPrint('⚠️ Error saving order to Firestore: $e');
    }
  }

  // ── 4. Real-time Stream Orders ─────────────────────────────────────────────
  Stream<List<CustomerOrder>> getOrdersStream() {
    return _db
        .collection('orders')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        final rawItems = List<Map<String, dynamic>>.from(data['items'] ?? []);

        final items = rawItems.map((itemData) {
          final pId = itemData['productId'] ?? '';
          final matched = kAllProducts.where((p) => p.id == pId);
          final product = matched.isNotEmpty ? matched.first : kAllProducts.first;

          return CartItem(
            product: product,
            qty: (itemData['qty'] ?? 1) as int,
            cut: itemData['cut'] ?? 'Medium Cut',
            gender: itemData['gender'] ?? 'Rooster',
            slot: itemData['slot'] ?? '6AM–9AM',
          );
        }).toList();

        return CustomerOrder(
          id: data['id'] ?? doc.id,
          date: data['date'] ?? '',
          items: items,
          total: (data['total'] ?? 0) as int,
          status: data['status'] ?? 'Confirmed',
          deliverySlot: data['deliverySlot'] ?? '6AM–9AM',
          agent: data['agent'] ?? 'Ravi Kumar',
          agentPhone: data['agentPhone'] ?? '+91 9876543210',
          address: data['address'] ?? '',
          points: (data['points'] ?? 0) as int,
          paymentMethod: data['paymentMethod'] ?? 'UPI / Online',
          txnId: data['txnId'] ?? '',
        );
      }).toList();
    });
  }

  // ── 5. User Profile Sync ──────────────────────────────────────────────────
  Future<void> saveUserProfile({
    required String phone,
    required String name,
    required int rewardPoints,
    required List<SavedAddress> addresses,
  }) async {
    try {
      await _db.collection('users').doc(phone).set({
        'phone': phone,
        'name': name,
        'rewardPoints': rewardPoints,
        'updatedAt': FieldValue.serverTimestamp(),
        'addresses': addresses.map((a) => {
          'label': a.label,
          'address': a.address,
          'isDefault': a.isDefault,
        }).toList(),
      }, SetOptions(merge: true));
      debugPrint('👤 User profile synced with Firestore!');
    } catch (e) {
      debugPrint('⚠️ Error saving user profile: $e');
    }
  }
}
