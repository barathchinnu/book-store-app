class CartItem {
  final String bookId;
  final String title;
  final String author;
  final double price;
  final String imageUrl;
  int quantity;

  CartItem({
    required this.bookId,
    required this.title,
    required this.author,
    required this.price,
    required this.imageUrl,
    this.quantity = 1,
  });

  double get totalPrice => price * quantity;

  Map<String, dynamic> toMap() {
    return {
      'bookId': bookId,
      'title': title,
      'author': author,
      'price': price,
      'imageUrl': imageUrl,
      'quantity': quantity,
    };
  }

  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      bookId: map['bookId'] ?? '',
      title: map['title'] ?? '',
      author: map['author'] ?? '',
      price: (map['price'] ?? 0.0).toDouble(),
      imageUrl: map['imageUrl'] ?? '',
      quantity: map['quantity'] ?? 1,
    );
  }

  CartItem copyWith({
    String? bookId,
    String? title,
    String? author,
    double? price,
    String? imageUrl,
    int? quantity,
  }) {
    return CartItem(
      bookId: bookId ?? this.bookId,
      title: title ?? this.title,
      author: author ?? this.author,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      quantity: quantity ?? this.quantity,
    );
  }
}
