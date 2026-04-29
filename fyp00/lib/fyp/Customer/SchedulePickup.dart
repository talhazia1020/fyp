import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'OrderConfirmation.dart';
import 'Dashboard.dart';

class SchedulePickup extends StatefulWidget {
  final String uid;
  final String accountType;

  const SchedulePickup({
    Key? key,
    required this.uid,
    required this.accountType,
  }) : super(key: key);

  @override
  State<SchedulePickup> createState() => _SchedulePickupState();
}

class _SchedulePickupState extends State<SchedulePickup> {

  List<Map<String, dynamic>> recyclables = [];
  final Map<int, TextEditingController> controllers = {};

  bool isLoading = true;

  double subtotal = 0.0;
  double totalWeight = 0.0;

  @override
  void initState() {
    super.initState();
    fetchPrices();
  }

  // 🔥 FETCH FROM FIREBASE (FIXED PROPERLY)
  Future<void> fetchPrices() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('recyclables')
          .get();

      recyclables = snapshot.docs.map((doc) {
        var data = doc.data() as Map<String, dynamic>;

        // 🔥 FIX: smart field detection
        String itemName = '';
        if (data.containsKey('name')) {
          itemName = data['name'];
        } else if (data.containsKey('item')) {
          itemName = data['item'];
        } else {
          itemName = doc.id; // fallback
        }

        double price = 0.0;
        if (data.containsKey('price')) {
          price = (data['price'] as num).toDouble();
        }

        return {
          "item": itemName,
          "price": price,
        };
      }).toList();

      // controllers
      for (int i = 0; i < recyclables.length; i++) {
        controllers[i] = TextEditingController(text: "0");
      }

      calculate();

      setState(() {
        isLoading = false;
      });

    } catch (e) {
      print("ERROR FETCHING: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  // 🔢 CALCULATE TOTAL
  void calculate() {
    subtotal = 0.0;
    totalWeight = 0.0;

    for (int i = 0; i < recyclables.length; i++) {
      final price = recyclables[i]['price'];
      final qty = double.tryParse(controllers[i]!.text) ?? 0.0;

      subtotal += price * qty;
      totalWeight += qty;
    }

    setState(() {});
  }

  void increase(int i) {
    double val = double.tryParse(controllers[i]!.text) ?? 0.0;
    val += 0.1;
    controllers[i]!.text = val.toStringAsFixed(1);
    calculate();
  }

  void decrease(int i) {
    double val = double.tryParse(controllers[i]!.text) ?? 0.0;
    if (val > 0) val -= 0.1;
    controllers[i]!.text = val.toStringAsFixed(1);
    calculate();
  }

  // ✅ SAVE ORDER TO FIREBASE (FIXED)
  void submitOrder() async {
    try {
      List<Map<String, dynamic>> recyclablesList = [];

      for (int i = 0; i < recyclables.length; i++) {
        double qty = double.tryParse(controllers[i]!.text) ?? 0.0;

        if (qty > 0) {
          recyclablesList.add({
            "item": recyclables[i]['item'],
            "price": recyclables[i]['price'],
            "quantity": qty,
          });
        }
      }

      if (recyclablesList.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please add some weight")),
        );
        return;
      }

      // Fetch customer details to include in the order
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('appUsers')
          .doc(widget.uid)
          .get();
      
      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>? ?? {};
      String customerName = userData['name'] ?? 'Unknown';
      String customerPhone = userData['phone'] ?? '';
      String customerAddress = userData['address'] ?? '';
      String customerArea = userData['area'] ?? '';

      String orderId = DateTime.now().millisecondsSinceEpoch.toString();

      await FirebaseFirestore.instance.collection('orders').add({
        "orderid": orderId,
        "customer": widget.uid,
        "customerName": customerName,
        "phoneNumber": customerPhone,
        "address": customerAddress,
        "area": customerArea,
        "totalWeight": totalWeight,
        "totalPrice": subtotal,
        "orderDate": Timestamp.now(),
        "status": 0,
        "paymentStatus": "unpaid",
        "pickupPrice": 0.0,
        "pickupWeight": 0.0,
        "recyclables": recyclablesList,
      });

      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => OrderConfirmation()),
      );

      Future.delayed(const Duration(seconds: 2), () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => Dashboard(uid: widget.uid),
          ),
        );
      });

    } catch (e) {
      print("ERROR SAVING ORDER: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error saving order")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Schedule Pickup"),
        backgroundColor: const Color(0xFF00401A),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: recyclables.length,
              itemBuilder: (context, i) {
                final item = recyclables[i];

                return Card(
                  margin: const EdgeInsets.all(8),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove),
                          onPressed: () => decrease(i),
                        ),

                        SizedBox(
                          width: 70,
                          child: TextField(
                            controller: controllers[i],
                            keyboardType: TextInputType.number,
                            onChanged: (_) => calculate(),
                            decoration: const InputDecoration(
                              isDense: true,
                            ),
                          ),
                        ),

                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () => increase(i),
                        ),

                        const SizedBox(width: 10),

                        Expanded(
                          child: Text(
                            "${item['item']} (kg)",
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),

                        Text(
                          "PKR ${item['price'].toStringAsFixed(2)}",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Total Weight"),
                    Text("${totalWeight.toStringAsFixed(1)} kg"),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Subtotal"),
                    Text("PKR ${subtotal.toStringAsFixed(2)}"),
                  ],
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: submitOrder,
                  child: const Text("Confirm Pickup"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}