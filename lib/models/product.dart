class Product {
  final String id;
  final String name;
  final String sub;
  final String img;
  final List<String> tags;
  final String weight;
  final int price;
  final int mrp;
  final int discount;
  final String age;
  final String serves;
  final String gender;
  final String desc;
  final List<String> benefits;
  final String category;

  const Product({
    required this.id,
    required this.name,
    required this.sub,
    required this.img,
    required this.tags,
    required this.weight,
    required this.price,
    required this.mrp,
    required this.discount,
    required this.age,
    required this.serves,
    required this.gender,
    required this.desc,
    required this.benefits,
    required this.category,
  });
}

class CartItem {
  final Product product;
  int qty;
  String cut;
  String gender;
  String slot;

  CartItem({
    required this.product,
    this.qty = 1,
    this.cut = 'Medium',
    required this.gender,
    this.slot = '6AM–9AM',
  });

  int get lineTotal => product.price * qty;
}

class CustomerOrder {
  final String id;
  final String date;
  final List<CartItem> items;
  final int total;
  final String status;
  final String deliverySlot;
  final String agent;
  final String agentPhone;
  final String address;
  final int points;
  final String paymentMethod;
  final String txnId;

  const CustomerOrder({
    required this.id,
    required this.date,
    required this.items,
    required this.total,
    required this.status,
    required this.deliverySlot,
    required this.agent,
    required this.agentPhone,
    required this.address,
    required this.points,
    this.paymentMethod = 'UPI / Online',
    this.txnId = '',
  });

  bool get isActive => status != 'Delivered' && status != 'Cancelled';
}

class AppUser {
  final String id;
  final String name;
  final String phone;
  final int orders;
  final double rating;

  const AppUser({
    required this.id,
    required this.name,
    required this.phone,
    required this.orders,
    required this.rating,
  });
}

class SavedAddress {
  final String label;
  final String address;
  final bool isDefault;

  const SavedAddress({
    required this.label,
    required this.address,
    this.isDefault = false,
  });
}
