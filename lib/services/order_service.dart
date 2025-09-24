import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/order.dart' as order_model;
import '../models/cart_item.dart';

class OrderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'orders';

  // Place a new order
  Future<String?> placeOrder(String userId, List<CartItem> items, double totalPrice) async {
    try {
      String orderId = _firestore.collection(_collection).doc().id;
      order_model.Order order = order_model.Order(
        orderId: orderId,
        userId: userId,
        items: items,
        totalPrice: totalPrice,
        orderDate: DateTime.now(),
        status: 'pending',
      );

      await _firestore.collection(_collection).doc(orderId).set(order.toMap());
      return orderId;
    } catch (e) {
      print('Error placing order: $e');
      return null;
    }
  }

  // Get orders for a user
  Stream<List<order_model.Order>> getUserOrders(String userId) {
    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .orderBy('orderDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => order_model.Order.fromMap(doc.data()))
            .toList());
  }

  // Get order by ID
  Future<order_model.Order?> getOrderById(String orderId) async {
    try {
      DocumentSnapshot doc = await _firestore.collection(_collection).doc(orderId).get();
      if (doc.exists) {
        return order_model.Order.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print('Error getting order: $e');
      return null;
    }
  }

  // Update order status
  Future<bool> updateOrderStatus(String orderId, String status) async {
    try {
      await _firestore.collection(_collection).doc(orderId).update({'status': status});
      return true;
    } catch (e) {
      print('Error updating order status: $e');
      return false;
    }
  }
}
