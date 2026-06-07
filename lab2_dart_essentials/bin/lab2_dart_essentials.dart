import 'dart:async';

// ==========================================
// EXERCISE 3 & 5: FUNCTIONS, STREAMS & ASYNC
// ==========================================

// Ex 3: Normal function
String evaluateScore(int score) {
  if (score >= 50) return "Pass";
  return "Fail";
}

// Ex 3: Arrow function syntax
int multiply(int a, int b) => a * b;

// Ex 5: Async function using Future + await + Future.delayed()
Future<void> simulateLoading() async {
  print("Loading data...");
  await Future.delayed(Duration(seconds: 1));
  print("Data loaded successfully!");
}

// Ex 5: Simple Stream of integers
Stream<int> numberStream() async* {
  for (int i = 1; i <= 3; i++) {
    await Future.delayed(Duration(milliseconds: 500));
    yield i;
  }
}

// ==========================================
// EXERCISE 4: OOP CLASSES
// ==========================================

// Create a class Car with one property and a method.
class Car {
  String brand;

  // Normal constructor
  Car(this.brand);

  // Named constructor
  Car.unknownBrand() : brand = 'Unknown';

  void drive() {
    print("Driving a $brand car.");
  }
}

// Create a subclass ElectricCar that overrides a method.
class ElectricCar extends Car {
  ElectricCar(String brand) : super(brand);

  @override
  void drive() {
    print("Driving a $brand electric car quietly.");
  }
}

// ==========================================
// MAIN FUNCTION (Entry Point)
// ==========================================
void main() async {
  print('--- EXERCISE 1: Basic Syntax & Data Types ---');
  // Declare variables using core types
  int itemsCount = 10;
  double price = 9.99;
  String itemName = "Notebook";
  bool inStock = true;

  // Use print() and string interpolation
  print("Item: $itemName");
  print("Total cost for $itemsCount items: \$${itemsCount * price}");
  print("In stock: $inStock\n");


  print('--- EXERCISE 2: Collections & Operators ---');
  // Create a List of integers
  List<int> numbers = [5, 10, 15, 20];
  
  // Use arithmetic & comparison operators (+, -, ==, &&)
  int sum = numbers[0] + numbers[1];
  int diff = numbers[3] - numbers[2];
  bool checkCondition = (sum == 15) && (diff > 0);
  
  // Use ternary operator (? :)
  print("Condition met? ${checkCondition ? 'Yes' : 'No'}");

  // Create a Set (unique values) and a Map (key-value)
  Set<String> uniqueColors = {'Red', 'Blue', 'Red'}; // Second 'Red' is ignored
  Map<String, String> userMap = {'id': 'U123', 'name': 'Alice'};

  // Use indexing, add(), remove(), and map access
  numbers.add(25);
  numbers.remove(10);
  print("List after add/remove: $numbers");
  print("Set values: $uniqueColors");
  print("Map access (Name): ${userMap['name']}\n");


  print('--- EXERCISE 3: Control Flow & Functions ---');
  // if/else block to check score
  int testScore = 85;
  if (testScore >= 80) {
    print("Grade: A");
  } else if (testScore >= 60) {
    print("Grade: B");
  } else {
    print("Grade: C");
  }

  // switch case for day of week
  int dayOfWeek = 3;
  switch (dayOfWeek) {
    case 1:
      print("Day: Monday");
      break;
    case 2:
      print("Day: Tuesday");
      break;
    case 3:
      print("Day: Wednesday");
      break;
    default:
      print("Day: Other");
  }

  // Loop through a collection using for, for-in, and forEach()
  print("For loop:");
  for (int i = 0; i < numbers.length; i++) {
    print("- ${numbers[i]}");
  }
  
  print("For-in loop:");
  for (var num in numbers) {
    print("- $num");
  }
  
  print("forEach loop:");
  numbers.forEach((n) => print("- $n"));
  
  // Test functions
  print("Normal Function Result: ${evaluateScore(45)}");
  print("Arrow Function Result: ${multiply(4, 5)}\n");


  print('--- EXERCISE 4: Intro to OOP ---');
  // Instantiate objects and print results
  Car regularCar = Car('Toyota');
  regularCar.drive();

  Car mysteriousCar = Car.unknownBrand();
  mysteriousCar.drive();

  ElectricCar tesla = ElectricCar('Tesla');
  tesla.drive();
  print("");


  print('--- EXERCISE 5: Async, Future, Null Safety & Streams ---');
  // Practice null-safety operators (?, ??, !)
  String? nullString; // Can be null
  String defaultString = nullString ?? "Default Value"; // ?? operator
  print("Using ?? operator: $defaultString");
  
  String? validString = "Dart Rules!";
  print("Using ! operator: ${validString!.toUpperCase()}"); // ! operator safely asserting it's not null

  // Future + await
  await simulateLoading();

  // Listen to Stream values
  print("Listening to integer stream:");
  await for (int val in numberStream()) {
    print("Received: $val");
  }
  
  print("\nLab 2 Complete!");
}