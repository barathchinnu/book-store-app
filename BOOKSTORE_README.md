# BookStore Flutter App

A comprehensive book store application built with Flutter and Firebase. This app allows users to browse, search, and purchase books with a complete shopping cart functionality.

## Features

### 🔐 Authentication
- User registration and login
- Firebase Authentication integration
- Secure user sessions

### 📚 Book Management
- Browse books by categories
- Search books by title or author
- View detailed book information
- Add/edit books (admin functionality)
- Book ratings and reviews

### 🛒 Shopping Cart
- Add books to cart
- Update quantities
- Remove items
- Calculate total price
- Checkout process

### 🎨 Modern UI
- Beautiful book store theme
- Responsive design
- Image caching for better performance
- Intuitive navigation

## Project Structure

```
lib/
├── models/
│   ├── book.dart              # Book data model
│   └── cart_item.dart         # Cart item model
├── services/
│   ├── auth_service.dart      # Firebase Authentication service
│   └── book_service.dart      # Firebase Firestore book operations
├── providers/
│   └── cart_provider.dart     # Shopping cart state management
├── pages/
│   ├── book_store_home_page.dart  # Main book store page
│   ├── book_detail_page.dart      # Individual book details
│   ├── cart_page.dart             # Shopping cart page
│   └── add_book_page.dart         # Add/edit book page
├── login_page.dart            # User login
├── register_page.dart         # User registration
├── home_page.dart             # Main app entry point
└── main.dart                  # App configuration
```

## Firebase Setup

### 1. Firebase Console Configuration
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create a new project or use existing one
3. Enable Authentication (Email/Password)
4. Enable Firestore Database
5. Download `google-services.json` for Android
6. Download `GoogleService-Info.plist` for iOS

### 2. Firestore Collections
The app uses the following Firestore collections:

#### `users` Collection
```json
{
  "uid": "user_id",
  "email": "user@example.com",
  "fullName": "User Name",
  "createdAt": "timestamp"
}
```

#### `books` Collection
```json
{
  "id": "book_id",
  "title": "Book Title",
  "author": "Author Name",
  "description": "Book description",
  "price": 12.99,
  "imageUrl": "https://example.com/image.jpg",
  "category": "Fiction",
  "stock": 50,
  "rating": 4.5,
  "reviewCount": 120,
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
}
```

## Getting Started

### Prerequisites
- Flutter SDK (3.8.1 or higher)
- Dart SDK
- Firebase project setup
- Android Studio / VS Code

### Installation

1. **Clone the repository**
   ```bash
   git clone <your-repo-url>
   cd firebaseproject
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Firebase**
   - Place `google-services.json` in `android/app/`
   - Place `GoogleService-Info.plist` in `ios/Runner/`

4. **Run the app**
   ```bash
   flutter run
   ```

## Usage

### For Users
1. **Register/Login**: Create an account or sign in
2. **Browse Books**: View books by category or search
3. **View Details**: Tap on any book to see full details
4. **Add to Cart**: Use the cart icon to add books
5. **Manage Cart**: View cart, update quantities, checkout

### For Admins
1. **Add Books**: Use the menu to access "Add Book"
2. **Edit Books**: Modify existing book information
3. **Manage Inventory**: Update stock quantities

## Dependencies

- `firebase_core`: Firebase core functionality
- `firebase_auth`: User authentication
- `cloud_firestore`: Database operations
- `provider`: State management
- `cached_network_image`: Image caching
- `image_picker`: Image selection
- `fluttertoast`: Toast notifications
- `intl`: Internationalization

## Features in Detail

### Book Store Home Page
- Grid layout of books
- Category filtering
- Search functionality
- Shopping cart indicator
- Add book option (admin)

### Book Detail Page
- Full book information
- Rating display
- Stock status
- Add to cart functionality
- Beautiful image display

### Shopping Cart
- Item management
- Quantity updates
- Price calculation
- Checkout process
- Clear cart option

### Add/Edit Book Page
- Complete book information form
- Image selection
- Category selection
- Validation
- Save/Update functionality

## Customization

### Themes
The app uses a brown color scheme that can be customized in `main.dart`:

```dart
theme: ThemeData(
  primarySwatch: Colors.brown,
  primaryColor: Colors.brown[800],
  // ... other theme configurations
),
```

### Categories
Add new book categories in `add_book_page.dart`:

```dart
final List<String> _categories = [
  'Fiction',
  'Non-Fiction',
  'Science Fiction',
  // Add your categories here
];
```

## Sample Data

The app automatically adds sample books when first launched. These include:
- The Great Gatsby
- To Kill a Mockingbird
- 1984
- Pride and Prejudice
- The Catcher in the Rye

## Troubleshooting

### Common Issues

1. **Firebase not initialized**
   - Ensure `google-services.json` is in the correct location
   - Check Firebase project configuration

2. **Images not loading**
   - Verify image URLs are accessible
   - Check network permissions

3. **Authentication issues**
   - Enable Email/Password authentication in Firebase Console
   - Check Firebase rules

### Debug Mode
Run in debug mode to see detailed logs:
```bash
flutter run --debug
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For support and questions:
- Create an issue in the repository
- Check Firebase documentation
- Review Flutter documentation

---

**Happy Reading! 📚**
