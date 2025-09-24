import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/book.dart';
import '../providers/cart_provider.dart';

class BookDetailPage extends StatelessWidget {
  final Book book;

  const BookDetailPage({Key? key, required this.book}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Book Details'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Book Image
            Container(
              height: 300,
              width: double.infinity,
              child: CachedNetworkImage(
                imageUrl: book.imageUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey[300],
                  child: Icon(Icons.book, size: 100, color: Colors.grey[600]),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[300],
                  child: Icon(Icons.error, size: 100, color: Colors.grey[600]),
                ),
              ),
            ),
            
            // Book Information
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    book.title,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  
                  // Author
                  Text(
                    'by ${book.author}',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 16),
                  
                  // Rating
                  Row(
                    children: [
                      ...List.generate(5, (index) {
                        return Icon(
                          index < book.rating ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                          size: 20,
                        );
                      }),
                      SizedBox(width: 8),
                      Text(
                        '${book.rating.toStringAsFixed(1)} (${book.reviewCount} reviews)',
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  
                  // Price
                  Text(
                    '\$${book.price.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.brown[800],
                    ),
                  ),
                  SizedBox(height: 16),
                  
                  // Category and Stock
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.brown[100],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          book.category,
                          style: TextStyle(
                            color: Colors.brown[800],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      SizedBox(width: 16),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: book.stock > 0 ? Colors.green[100] : Colors.red[100],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          book.stock > 0 ? 'In Stock (${book.stock})' : 'Out of Stock',
                          style: TextStyle(
                            color: book.stock > 0 ? Colors.green[800] : Colors.red[800],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24),
                  
                  // Description
                  Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    book.description,
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                  SizedBox(height: 32),
                  
                  // Add to Cart Button
                  Consumer<CartProvider>(
                    builder: (context, cart, child) {
                      bool inCart = cart.isInCart(book.id);
                      int quantity = cart.getItemQuantity(book.id);
                      
                      return Container(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: book.stock > 0 ? () {
                            if (inCart) {
                              cart.removeItem(book.id);
                            } else {
                              cart.addItem(book);
                            }
                          } : null,
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: inCart ? Colors.green : Colors.brown[800],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                inCart ? Icons.remove_shopping_cart : Icons.add_shopping_cart,
                                color: Colors.white,
                              ),
                              SizedBox(width: 8),
                              Text(
                                inCart 
                                  ? 'Remove from Cart (${quantity})' 
                                  : 'Add to Cart',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
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
