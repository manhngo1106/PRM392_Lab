import 'dart:async';
import 'dart:convert';

// ==========================================
// EXERCISE 1: Product Model & Repository
// ==========================================
class Product {
  final int id;
  final String name;
  final double price;

  Product({required this.id, required this.name, required this.price});

  @override
  String toString() => 'Product(id: $id, name: $name, price: $price)';
}

class ProductRepository {
  final List<Product> _db = [];
  
  // Use StreamController.broadcast() to allow multiple listeners to real-time updates
  final StreamController<Product> _controller = StreamController<Product>.broadcast();

  // Expose the stream for listeners
  Stream<Product> get liveAdded => _controller.stream;

  void addProduct(Product product) {
    _db.add(product);
    _controller.add(product); // Emit the new item to the stream
  }

  // Future to get all products (simulating database latency)
  Future<List<Product>> getAll() async {
    await Future.delayed(Duration(milliseconds: 300));
    return _db;
  }

  void dispose() {
    _controller.close(); // Always close controllers to prevent memory leaks
  }
}

// ==========================================
// EXERCISE 2: User Repository with JSON
// ==========================================
class User {
  final String name;
  final String email;

  User({required this.name, required this.email});

  // Named constructor to create a User object from a Map (JSON)
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      name: json['name'] as String,
      email: json['email'] as String,
    );
  }

  @override
  String toString() => 'User(name: $name, email: $email)';
}

// Simulate fetching and parsing JSON data from an API
Future<List<User>> fetchUsers() async {
  String jsonResponse = '''
  [
    {"name": "Alex", "email": "alex@example.com"},
    {"name": "Bella", "email": "bella@example.com"}
  ]
  ''';

  await Future.delayed(Duration(milliseconds: 300)); // Simulate network delay
  
  // Decode string into a List of dynamic objects (Maps)
  List<dynamic> parsedList = jsonDecode(jsonResponse);
  
  // Map the raw data into strongly typed User objects
  return parsedList.map((json) => User.fromJson(json)).toList();
}

// ==========================================
// EXERCISE 5: Factory Constructors & Cache
// ==========================================
class Settings {
  // 1. Private static instance holds the single cached object
  static final Settings _instance = Settings._internal();

  // 2. Factory constructor always returns the cached instance
  factory Settings() {
    return _instance;
  }

  // 3. Private constructor actually creates the object (runs only once)
  Settings._internal() {
    print("Settings initialized (This line should only print once!).");
  }
}

// ==========================================
// MAIN FUNCTION (Entry Point)
// ==========================================
void main() async {
  print('--- EXERCISE 1: Product Model & Repository ---');
  final repo = ProductRepository();

  // Listen to the live stream for real-time additions
  final subscription = repo.liveAdded.listen((product) {
    print("Stream Event: Real-time update -> $product added.");
  });

  // Trigger stream events
  repo.addProduct(Product(id: 101, name: 'Mechanical Keyboard', price: 120.00));
  repo.addProduct(Product(id: 102, name: 'Wireless Mouse', price: 45.50));

  // Await the Future to get all products
  final allProducts = await repo.getAll();
  print("Future Result: All DB products -> $allProducts\n");
  
  await subscription.cancel();
  repo.dispose();


  print('--- EXERCISE 2: User Repository with JSON ---');
  final users = await fetchUsers();
  print("Users successfully parsed from JSON:");
  for (var user in users) {
    print("- $user");
  }
  print("");


  print('--- EXERCISE 3: Async + Microtask Debugging ---');
  /*
    EXPLANATION OF THE EVENT LOOP:
    Dart executes synchronous code first. 
    Once the synchronous code is done, it checks the Microtask Queue. 
    Only after the Microtask Queue is completely empty will Dart process the Event Queue (Futures).
  */
  print("1. Main start (Synchronous code executes first)");

  // This goes to the Event Queue
  Future(() {
    print("4. Event queue execution (Future)");
  });

  // This goes to the Microtask Queue
  scheduleMicrotask(() {
    print("3. Microtask queue execution");
  });

  print("2. Main end (Synchronous code finishes)\n");

  // Brief delay to allow the Ex 3 async callbacks to print cleanly before Ex 4
  await Future.delayed(Duration(milliseconds: 100));


  print('--- EXERCISE 4: Stream Transformation ---');
  // Create a stream emitting numbers 1 through 5
  Stream<int> numbers = Stream.fromIterable([1, 2, 3, 4, 5]);

  print("Applying functional operations to Stream:");
  await numbers
      .map((n) => n * n)         // Transform: 1, 4, 9, 16, 25
      .where((n) => n % 2 == 0)  // Filter even: 4, 16
      .listen((value) {
        print("Emitted Transformed Value: $value");
      }).asFuture(); // Wait for the stream to finish before moving on
  print("");


  print('--- EXERCISE 5: Factory Constructors & Cache ---');
  // Attempt to create two separate instances
  Settings configA = Settings();
  Settings configB = Settings();

  // Use identical() to check if they point to the exact same memory reference
  bool isSingleton = identical(configA, configB);
  print("Are configA and configB identical in memory? $isSingleton");
  
  print("\nLab 3 Complete!");
}