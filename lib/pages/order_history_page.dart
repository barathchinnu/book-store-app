import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/order.dart';
import '../services/order_service.dart';
import '../auth_service.dart';
import 'order_edit_page.dart';

class OrderHistoryPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final user = authService.currentUser;
    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Order History')),
        body: Center(child: Text('Please log in to view order history.')),
      );
    }

    final orderService = OrderService();

    return Scaffold(
      appBar: AppBar(
        title: Text('Order History'),
      ),
      body: StreamBuilder<List<Order>>(
        stream: orderService.getUserOrders(user.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.history,
                    size: 100,
                    color: Colors.grey[400],
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No orders yet',
                    style: TextStyle(
                      fontSize: 24,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Place your first order to see it here!',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            );
          }

          List<Order> orders = snapshot.data!;

          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              Order order = orders[index];
              return _buildOrderCard(context, order);
            },
          );
        },
      ),
    );
  }

  Widget _buildOrderCard(BuildContext context, Order order) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Order #${order.orderId.substring(0, 8)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                Text(
                  order.status.toUpperCase(),
                  style: TextStyle(
                    color: _getStatusColor(order.status),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              'Date: ${order.orderDate.toString().split(' ')[0]}',
              style: TextStyle(color: Colors.grey[600]),
            ),
            SizedBox(height: 16),

            // Order Items
            Text(
              'Items:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            ...order.items.map((item) => _buildOrderItem(item)),
            SizedBox(height: 16),

            // Total and Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total: \$${order.totalPrice.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.brown[800],
                  ),
                ),
                if (order.status == 'pending')
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () => _editOrder(context, order),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                        ),
                        child: Text('Edit Order'),
                      ),
                      SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () => _showCancelDialog(context, order),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        child: Text('Delete Order'),
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderItem(cartItem) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 60,
            child: CachedNetworkImage(
              imageUrl: cartItem.imageUrl,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: Colors.grey[300],
                child: Icon(Icons.book, color: Colors.grey[600]),
              ),
              errorWidget: (context, url, error) => Container(
                color: Colors.grey[300],
                child: Icon(Icons.error, color: Colors.grey[600]),
              ),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cartItem.title,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  'by ${cartItem.author}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                Text(
                  '\$${cartItem.price.toStringAsFixed(2)} x ${cartItem.quantity}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            '\$${cartItem.totalPrice.toStringAsFixed(2)}',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      case 'completed':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  void _showCancelDialog(BuildContext context, Order order) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Order'),
          content: Text('Are you sure you want to delete this order? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('No'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                final orderService = OrderService();
                bool success = await orderService.deleteOrder(order.orderId);
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Order deleted successfully.')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to delete order. Please try again.')),
                  );
                }
              },
              child: Text('Yes, Delete'),
            ),
          ],
        );
      },
    );
  }

  void _editOrder(BuildContext context, Order order) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => OrderEditPage(order: order),
      ),
    );

    if (result == true) {
      // Order was updated successfully, show a message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Order updated successfully.')),
      );
    }
  }
}
