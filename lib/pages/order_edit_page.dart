import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/order.dart';
import '../models/cart_item.dart';
import '../services/order_service.dart';
import '../auth_service.dart';

class OrderEditPage extends StatefulWidget {
  final Order order;

  OrderEditPage({required this.order});

  @override
  _OrderEditPageState createState() => _OrderEditPageState();
}

class _OrderEditPageState extends State<OrderEditPage> {
  late List<CartItem> _items;
  late double _totalPrice;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _items = List.from(widget.order.items);
    _totalPrice = widget.order.totalPrice;
  }

  void _updateTotalPrice() {
    _totalPrice = _items.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  void _updateQuantity(int index, int newQuantity) {
    if (newQuantity <= 0) {
      _items.removeAt(index);
    } else {
      _items[index] = _items[index].copyWith(quantity: newQuantity);
    }
    _updateTotalPrice();
    setState(() {});
  }

  Future<void> _saveChanges() async {
    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Order must have at least one item.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      Order updatedOrder = Order(
        orderId: widget.order.orderId,
        userId: widget.order.userId,
        items: _items,
        totalPrice: _totalPrice,
        orderDate: widget.order.orderDate,
        status: widget.order.status,
      );

      OrderService orderService = OrderService();
      bool success = await orderService.updateOrder(widget.order.orderId, updatedOrder);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Order updated successfully.')),
        );
        Navigator.of(context).pop(true); // Return true to indicate success
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update order. Please try again.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Order'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveChanges,
            child: _isLoading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order #${widget.order.orderId.substring(0, 8)}',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _items.length,
                itemBuilder: (context, index) {
                  CartItem item = _items[index];
                  return _buildEditableItemCard(item, index);
                },
              ),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  '\$${_totalPrice.toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.brown[800]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditableItemCard(CartItem item, int index) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 80,
              child: CachedNetworkImage(
                imageUrl: item.imageUrl,
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
                    item.title,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    'by ${item.author}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  Text(
                    '\$${item.price.toStringAsFixed(2)} each',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                Text('Qty:', style: TextStyle(fontSize: 12)),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.remove, size: 16),
                      onPressed: () => _updateQuantity(index, item.quantity - 1),
                    ),
                    Text(
                      '${item.quantity}',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: Icon(Icons.add, size: 16),
                      onPressed: () => _updateQuantity(index, item.quantity + 1),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(width: 8),
            Text(
              '\$${item.totalPrice.toStringAsFixed(2)}',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
