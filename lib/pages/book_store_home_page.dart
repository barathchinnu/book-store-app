import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/book.dart';
import '../services/book_service.dart';
import '../providers/cart_provider.dart';
import '../auth_service.dart';
import 'book_detail_page.dart';
import 'cart_page.dart';
import 'add_book_page.dart';
import 'order_history_page.dart';

class BookStoreHomePage extends StatefulWidget {
  @override
  _BookStoreHomePageState createState() => _BookStoreHomePageState();
}

class _BookStoreHomePageState extends State<BookStoreHomePage> {
  final BookService _bookService = BookService();
  String _selectedCategory = 'All';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Add all books (sample + additional) if the collection is empty
    _bookService.addAllBooks();

    // Debug: Check Firebase connection and book count
    _debugFirebaseConnection();
  }

  Future<void> _debugFirebaseConnection() async {
    print('=== DEBUG: Checking Firebase Connection ===');

    // Check collection access
    bool canAccess = await _bookService.checkCollectionAccess();
    print('Collection access: $canAccess');

    // Get current book count
    int bookCount = await _bookService.getBookCount();
    print('Current book count: $bookCount');

    print('=== END DEBUG ===');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('BookStore'),
        actions: [
          IconButton(
            icon: Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => OrderHistoryPage()),
              );
            },
          ),
          Consumer<CartProvider>(
            builder: (context, cart, child) {
              return Stack(
                children: [
                  IconButton(
                    icon: Icon(Icons.shopping_cart),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => CartPage()),
                      );
                    },
                  ),
                  if (cart.itemCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '${cart.itemCount}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'logout') {
                AuthService().signOut();
              } else if (value == 'add_book') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddBookPage()),
                );
              }
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem<String>(
                value: 'add_book',
                child: Text('Add Book'),
              ),
              PopupMenuItem<String>(
                value: 'logout',
                child: Text('Logout'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search books...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          
          // Category Filter
          Container(
            height: 50,
            child: StreamBuilder<List<String>>(
              stream: _bookService.getCategories(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return SizedBox.shrink();
                }
                
                List<String> categories = ['All', ...snapshot.data!];
                
                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    String category = categories[index];
                    bool isSelected = category == _selectedCategory;
                    
                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: FilterChip(
                        label: Text(category),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            _selectedCategory = category;
                          });
                        },
                        backgroundColor: Colors.grey[200],
                        selectedColor: Colors.brown[200],
                      ),
                    );
                  },
                );
              },
            ),
          ),
          
          // Books List
          Expanded(
            child: _buildBooksList(),
          ),
        ],
      ),
    );
  }

  Widget _buildBooksList() {
    Stream<List<Book>> booksStream;
    
    if (_searchQuery.isNotEmpty) {
      booksStream = _bookService.searchBooks(_searchQuery);
    } else if (_selectedCategory == 'All') {
      booksStream = _bookService.getBooks();
    } else {
      booksStream = _bookService.getBooksByCategory(_selectedCategory);
    }

    return StreamBuilder<List<Book>>(
      stream: booksStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No books found'));
        }
        
        List<Book> books = snapshot.data!;
        
        return GridView.builder(
          padding: EdgeInsets.all(16),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.7,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: books.length,
          itemBuilder: (context, index) {
            Book book = books[index];
            return _buildBookCard(book);
          },
        );
      },
    );
  }

  Widget _buildBookCard(Book book) {
    return Card(
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BookDetailPage(book: book),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Book Image
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                child: CachedNetworkImage(
                  imageUrl: book.imageUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: Colors.grey[300],
                    child: Icon(Icons.book, size: 50, color: Colors.grey[600]),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey[300],
                    child: Icon(Icons.error, size: 50, color: Colors.grey[600]),
                  ),
                ),
              ),
            ),
            
            // Book Info
            Expanded(
              flex: 2,
              child: Padding(
                padding: EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      book.title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),
                    Text(
                      book.author,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '\$${book.price.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.brown[800],
                          ),
                        ),
                        Consumer<CartProvider>(
                          builder: (context, cart, child) {
                            bool inCart = cart.isInCart(book.id);
                            return IconButton(
                              icon: Icon(
                                inCart ? Icons.shopping_cart : Icons.add_shopping_cart,
                                color: inCart ? Colors.green : Colors.brown[800],
                              ),
                              onPressed: () {
                                if (inCart) {
                                  cart.removeItem(book.id);
                                } else {
                                  cart.addItem(book);
                                }
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
