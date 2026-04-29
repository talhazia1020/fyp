import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'fyp/Customer/Login.dart';

class ScheduleProvider extends ChangeNotifier {
  late List<ScheduleItem> _items;

  ScheduleProvider() {
    _items = [];
    fetchRecyclablesFromDatabase();
  }

  List<ScheduleItem> get items => _items;

  void increaseQuantity(int index) {
    _items[index].quantity += 0.1;
    notifyListeners();
  }

  void decreaseQuantity(int index) {
    if (_items[index].quantity > 0.0) {
      _items[index].quantity -= 0.1;
      notifyListeners();
    }
  }

  double calculateTotalQuantity() {
    return _items.fold(0.0, (total, item) => total + item.quantity);
  }

  double calculateTotalPrice() {
    return _items.fold(0.0, (total, item) => total + (item.quantity * item.price));
  }

  void resetQuantities() {
    for (var item in _items) {
      item.quantity = 0.0;
    }
    notifyListeners();
  }

  void fetchRecyclablesFromDatabase() async {
    try {
      QuerySnapshot querySnapshot =
      await FirebaseFirestore.instance.collection('recyclables').get();

      _items = querySnapshot.docs.map((doc) {
        return ScheduleItem(
          itemName: doc['item'],
          price: doc['price'].toDouble(),
          quantity: 0.0,
        );
      }).toList();

      notifyListeners();
    } catch (error) {
      print('Error fetching recyclables: $error');
    }
  }
}

class ScheduleItem {
  final String itemName;
  final double price;
  double quantity;

  ScheduleItem({
    required this.itemName,
    required this.price,
    required double quantity,
  }) : quantity = quantity;
}

class RiderOrderProvider extends ChangeNotifier {
  late List<RecyclableItem> _recyclableItems;

  RiderOrderProvider() {
    _recyclableItems = [];
  }

  List<RecyclableItem> get recyclableItems => _recyclableItems;

  void addRecyclableItem(RecyclableItem item) {
    _recyclableItems.add(item);
    notifyListeners();
  }

  void removeRecyclableItem(int index) {
    _recyclableItems.removeAt(index);
    notifyListeners();
  }

  double calculateTotalPrice() {
    return _recyclableItems.fold(0.0, (total, item) => total + item.totalPrice);
  }
}

class RecyclableItem {
  final String itemName;
  final int quantity;
  final double totalPrice;

  RecyclableItem({
    required this.itemName,
    required this.quantity,
    required this.totalPrice,
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: const FirebaseOptions(
    apiKey: 'AIzaSyAX_2YhxrkkqcAjH_18D1Bwi08-JRjNRBg', 
    appId: '1:1048990693052:web:6e7038b72b104f4d4842b9', 
    projectId: 'saafpakistan-c22b3', 
    messagingSenderId: '1048990693052', 
  ));

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ScheduleProvider()),
        ChangeNotifierProvider(create: (context) => RiderOrderProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: CLogin(), // Make sure this points to a valid login screen
    );
  }
}
