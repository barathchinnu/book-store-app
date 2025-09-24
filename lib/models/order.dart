import 'package:cloud_firestore/cloud_firestore.dart';
import 'cart_item.dart';

class Order {
  final String orderId;
  final String userId;
  final List<CartItem> items;
  final double totalPrice;
  final DateTime orderDate;
  final String status;

  Order({
    required this.orderId,
    required this.userId,
    required this.items,
    required this.totalPrice,
    required this.orderDate,
    this.status = 'pending',
  });

  Map<String, dynamic> toMap() {
    return {
      'orderId': orderId,
      'userId': userId,
      'items': items.map((item) => item.toMap()).toList(),
      'totalPrice': totalPrice,
      'orderDate': Timestamp.fromDate(orderDate),
      'status': status,
    };
  }

  factory Order.fromMap(Map<String, dynamic> map) {
    return Order(
      orderId: map['orderId'] ?? '',
      userId: map['userId'] ?? '',
      items: (map['items'] as List<dynamic>?)
              ?.map((item) => CartItem.fromMap(item as Map<String, dynamic>))
              .toList() ??
          [],
      totalPrice: (map['totalPrice'] ?? 0.0).toDouble(),
      orderDate: (map['orderDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      status: map['status'] ?? 'pending',
    );
  }
}
