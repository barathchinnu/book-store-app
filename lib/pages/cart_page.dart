import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/cart_provider.dart';
import '../models/cart_item.dart';
import 'order_history_page.dart';

class CartPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Shopping Cart'),
        actions: [
          Consumer<CartProvider>(
            builder: (context, cart, child) {
              if (cart.items.isEmpty) return SizedBox.shrink();
              
              return TextButton(
                onPressed: () {
                  _showClearCartDialog(context, cart);
                },
                child: Text(
                  'Clear All',
                  style: TextStyle(color: Colors.white),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<CartProvider>(
        builder: (context, cart, child) {
          if (cart.items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 100,
                    color: Colors.grey[400],
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Your cart is empty',
                    style: TextStyle(
                      fontSize: 24,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Add some books to get started!',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Cart Items
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: cart.items.length,
                  itemBuilder: (context, index) {
                    CartItem item = cart.items[index];
                    return _buildCartItem(context, item, cart);
                  },
                ),
              ),
              
              // Total and Checkout
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: Offset(0, -3),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total Items:',
                          style: TextStyle(fontSize: 16),
                        ),
                        Text(
                          '${cart.itemCount}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total Price:',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '\$${cart.totalPrice.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.brown[800],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          _showCheckoutDialog(context, cart);
                        },
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text(
                          'Proceed to Checkout',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCartItem(BuildContext context, CartItem item, CartProvider cart) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Row(
          children: [
            // Book Image
            Container(
              width: 80,
              height: 100,
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
            
            // Book Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  Text(
                    item.author,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '\$${item.price.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.brown[800],
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            
            // Quantity Controls
            Column(
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.remove_circle_outline),
                      onPressed: () {
                        cart.updateQuantity(item.bookId, item.quantity - 1);
                      },
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '${item.quantity}',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.add_circle_outline),
                      onPressed: () {
                        cart.updateQuantity(item.bookId, item.quantity + 1);
                      },
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  '\$${item.totalPrice.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.brown[800],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showClearCartDialog(BuildContext context, CartProvider cart) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Clear Cart'),
          content: Text('Are you sure you want to remove all items from your cart?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                cart.clearCart();
                Navigator.of(context).pop();
              },
              child: Text('Clear'),
            ),
          ],
        );
      },
    );
  }

  void _showCheckoutDialog(BuildContext context, CartProvider cart) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Checkout'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Processing your order...'),
              SizedBox(height: 16),
              Text('Total: \$${cart.totalPrice.toStringAsFixed(2)}'),
              SizedBox(height: 8),
              Text('Items: ${cart.itemCount}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                final orderId = await cart.placeOrder();
                Navigator.of(context).pop();
                if (orderId != null) {
                  _showOrderSuccessDialog(context, orderId);
                } else {
                  _showOrderErrorDialog(context);
                }
              },
              child: Text('Complete Order'),
            ),
          ],
        );
      },
    );
  }

  void _showOrderSuccessDialog(BuildContext context, String orderId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Order Placed!'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Your order has been placed successfully.'),
              SizedBox(height: 16),
              Text('Order ID: $orderId'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop(); // Go back to home
                // Navigate to order history
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => OrderHistoryPage()),
                );
              },
              child: Text('View Order History'),
            ),
          ],
        );
      },
    );
  }

  void _showOrderErrorDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Order Failed'),
          content: Text('There was an error placing your order. Please try again.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
