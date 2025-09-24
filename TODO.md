# TODO: Implement Order Storage in Database

## Steps to Complete:

1. **Create Order Model** (`lib/models/order.dart`) ✅
   - Define Order class with fields: orderId, userId, items (List<CartItem>), totalPrice, orderDate, status
   - Add toMap() and fromMap() methods for Firestore

2. **Create Order Service** (`lib/services/order_service.dart`) ✅
   - Add placeOrder() method to save orders to Firestore
   - Add getUserOrders() method to fetch user's orders

3. **Update CartProvider** (`lib/providers/cart_provider.dart`) ✅
   - Add placeOrder() method that uses OrderService and clears cart

4. **Update CartPage** (`lib/pages/cart_page.dart`) ✅
   - Modify checkout dialog to call placeOrder() and show success message

5. **Update BookService** (`lib/services/book_service.dart`) ✅
   - Add updateStockAfterOrder() method to reduce book stock

6. **Test Implementation**
   - Add items to cart, checkout, verify order in Firestore
   - Check stock updates
