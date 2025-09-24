import 'package:flutter/foundation.dart';
import '../models/book.dart';
import '../models/cart_item.dart';
import '../services/order_service.dart';
import '../auth_service.dart';

class CartProvider with ChangeNotifier {
  List<CartItem> _items = [];

  List<CartItem> get items => _items;

  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);

  double get totalPrice => _items.fold(0.0, (sum, item) => sum + item.totalPrice);

  void addItem(Book book) {
    final existingIndex = _items.indexWhere((item) => item.bookId == book.id);
    
    if (existingIndex >= 0) {
      _items[existingIndex].quantity++;
    } else {
      _items.add(CartItem(
        bookId: book.id,
        title: book.title,
        author: book.author,
        price: book.price,
        imageUrl: book.imageUrl,
        quantity: 1,
      ));
    }
    notifyListeners();
  }

  void removeItem(String bookId) {
    _items.removeWhere((item) => item.bookId == bookId);
    notifyListeners();
  }

  void updateQuantity(String bookId, int quantity) {
    final index = _items.indexWhere((item) => item.bookId == bookId);
    if (index >= 0) {
      if (quantity <= 0) {
        _items.removeAt(index);
      } else {
        _items[index].quantity = quantity;
      }
      notifyListeners();
    }
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  bool isInCart(String bookId) {
    return _items.any((item) => item.bookId == bookId);
  }

  int getItemQuantity(String bookId) {
    final item = _items.firstWhere(
      (item) => item.bookId == bookId,
      orElse: () => CartItem(
        bookId: '',
        title: '',
        author: '',
        price: 0.0,
        imageUrl: '',
        quantity: 0,
      ),
    );
    return item.quantity;
  }

  Future<String?> placeOrder() async {
    if (_items.isEmpty) return null;

    final authService = AuthService();
    final user = authService.currentUser;
    if (user == null) return null;

    final orderService = OrderService();
    final orderId = await orderService.placeOrder(user.uid, _items, totalPrice);

    if (orderId != null) {
      clearCart();
    }

    return orderId;
  }
}
