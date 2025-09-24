import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/book.dart';
import 'additional_books.dart';

class BookService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'books';

  // Get all books
  Stream<List<Book>> getBooks() {
    return _firestore
        .collection(_collection)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Book.fromMap(doc.data()))
            .toList()
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt))); // Sort in memory instead
  }

  // Get books by category
  Stream<List<Book>> getBooksByCategory(String category) {
    return _firestore
        .collection(_collection)
        .where('category', isEqualTo: category)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Book.fromMap(doc.data()))
            .toList()
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt))); // Sort in memory instead
  }

  // Get featured books (high rating)
  Stream<List<Book>> getFeaturedBooks() {
    return _firestore
        .collection(_collection)
        .where('rating', isGreaterThan: 4.0)
        .orderBy('rating', descending: true)
        .limit(10)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Book.fromMap(doc.data()))
            .toList());
  }

  // Search books by title or author
  Stream<List<Book>> searchBooks(String query) {
    return _firestore
        .collection(_collection)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Book.fromMap(doc.data()))
            .where((book) =>
                book.title.toLowerCase().contains(query.toLowerCase()) ||
                book.author.toLowerCase().contains(query.toLowerCase()))
            .toList());
  }

  // Get book by ID
  Future<Book?> getBookById(String id) async {
    try {
      DocumentSnapshot doc = await _firestore.collection(_collection).doc(id).get();
      if (doc.exists) {
        return Book.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print('Error getting book: $e');
      return null;
    }
  }

  // Add a new book
  Future<String?> addBook(Book book) async {
    try {
      DocumentReference docRef = await _firestore.collection(_collection).add(book.toMap());
      return docRef.id;
    } catch (e) {
      print('Error adding book: $e');
      return null;
    }
  }

  // Update a book
  Future<bool> updateBook(String id, Book book) async {
    try {
      await _firestore.collection(_collection).doc(id).update(book.toMap());
      return true;
    } catch (e) {
      print('Error updating book: $e');
      return false;
    }
  }

  // Delete a book
  Future<bool> deleteBook(String id) async {
    try {
      await _firestore.collection(_collection).doc(id).delete();
      return true;
    } catch (e) {
      print('Error deleting book: $e');
      return false;
    }
  }

  // Update book stock
  Future<bool> updateStock(String id, int newStock) async {
    try {
      await _firestore.collection(_collection).doc(id).update({
        'stock': newStock,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print('Error updating stock: $e');
      return false;
    }
  }

  // Get categories
  Stream<List<String>> getCategories() {
    return _firestore
        .collection(_collection)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Book.fromMap(doc.data()).category)
            .toSet()
            .toList());
  }

  // Get book count for debugging
  Future<int> getBookCount() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection(_collection).get();
      print('Current book count in Firebase: ${snapshot.docs.length}');
      return snapshot.docs.length;
    } catch (e) {
      print('Error getting book count: $e');
      return 0;
    }
  }

  // Check if collection exists and is accessible
  Future<bool> checkCollectionAccess() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection(_collection).limit(1).get();
      print('Collection access successful. Sample document: ${snapshot.docs.isNotEmpty ? snapshot.docs.first.id : 'none'}');
      return true;
    } catch (e) {
      print('Collection access failed: $e');
      return false;
    }
  }

  // Add sample books for testing (only if collection is empty)
  Future<void> addSampleBooks() async {
    try {
      // Check if books already exist
      QuerySnapshot snapshot = await _firestore.collection(_collection).limit(1).get();
      if (snapshot.docs.isNotEmpty) {
        print('Books already exist in Firebase, skipping sample books');
        return;
      }

      List<Book> sampleBooks = [
        Book(
          id: '1',
          title: 'The Great Gatsby',
          author: 'F. Scott Fitzgerald',
          description: 'A classic American novel set in the Jazz Age, exploring themes of wealth, love, and the American Dream.',
          price: 12.99,
          imageUrl: 'https://picsum.photos/300/400?random=1',
          category: 'Fiction',
          stock: 50,
          rating: 4.5,
          reviewCount: 120,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        Book(
          id: '2',
          title: 'To Kill a Mockingbird',
          author: 'Harper Lee',
          description: 'A gripping tale of racial injustice and childhood innocence in the American South.',
          price: 14.99,
          imageUrl: 'https://picsum.photos/300/400?random=2',
          category: 'Fiction',
          stock: 30,
          rating: 4.8,
          reviewCount: 200,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      print('Adding ${sampleBooks.length} sample books to Firebase...');

      for (Book book in sampleBooks) {
        try {
          String? docId = await addBook(book);
          print('Added sample book: ${book.title} with ID: $docId');
        } catch (e) {
          print('Error adding sample book ${book.title}: $e');
        }
      }

      print('Finished adding sample books');
    } catch (e) {
      print('Error in addSampleBooks: $e');
    }
  }

  // Add additional books from additional_books.dart
  Future<void> addAdditionalBooks() async {
    List<Book> additionalBooks = getAdditionalBooks();

    print('Adding ${additionalBooks.length} additional books to Firebase...');

    for (Book book in additionalBooks) {
      try {
        String? docId = await addBook(book);
        print('Added book: ${book.title} with ID: $docId');
      } catch (e) {
        print('Error adding book ${book.title}: $e');
      }
    }

    print('Finished adding additional books');
  }

  // Add all books (sample + additional)
  Future<void> addAllBooks() async {
    print('Starting to add all books...');

    try {
      await addSampleBooks();
      print('Sample books added successfully');
    } catch (e) {
      print('Error adding sample books: $e');
    }

    try {
      await addAdditionalBooks();
      print('Additional books added successfully');
    } catch (e) {
      print('Error adding additional books: $e');
    }

    print('Finished adding all books');
  }

  // Update stock after order
  Future<bool> updateStockAfterOrder(String bookId, int quantityOrdered) async {
    try {
      DocumentSnapshot doc = await _firestore.collection(_collection).doc(bookId).get();
      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        int currentStock = data['stock'] ?? 0;
        int newStock = currentStock - quantityOrdered;
        if (newStock < 0) newStock = 0; // Prevent negative stock

        await _firestore.collection(_collection).doc(bookId).update({
          'stock': newStock,
          'updatedAt': FieldValue.serverTimestamp(),
        });
        return true;
      }
      return false;
    } catch (e) {
      print('Error updating stock: $e');
      return false;
    }
  }
}
