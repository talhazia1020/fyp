// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'riderLogin.dart';
// import 'Profile.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'OrderDetails.dart';
// import 'Orders.dart';

// class Dashboard extends StatefulWidget {
//   final String uid;

//   const Dashboard({Key? key, required this.uid}) : super(key: key);

//   @override
//   _DashboardState createState() => _DashboardState();
// }

// class _DashboardState extends State<Dashboard> {
//   String? userName;
//   late String uid;
//   String? riderArea; 
//   late List<Map<String, dynamic>> ordersList = [];
//   bool isLoading = false;

//   @override
//   void initState() {
//     super.initState();
//     uid = widget.uid;
//     getRiderName();
//     displayRiderArea();
//     checkInprocessOrders();
//   }

//   Future<void> getRiderName() async {
//     setState(() {
//       isLoading = true;
//     });

//     try {
//       DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
//           .collection('rider')
//           .doc(uid)
//           .get();

//       if (userSnapshot.exists) {
//         var data = userSnapshot.data() as Map<String, dynamic>;
//         setState(() {
//           userName = data['name'];
//           isLoading = false;
//         });
//       } else {
//         print('User data not found for UID: $uid');
//         setState(() {
//           isLoading = false;
//         });
//       }
//     } catch (error) {
//       print('Error fetching user data: $error');
//       setState(() {
//         isLoading = false;
//       });
//     }
//   }

//   Future<void> checkInprocessOrders() async {
//     try {
//       QuerySnapshot ordersSnapshot = await FirebaseFirestore.instance
//           .collection('orders')
//           .where('rider', isEqualTo: uid)
//           .where('status', isEqualTo: 1)
//           .get();

//       if (ordersSnapshot.docs.isNotEmpty) {
//         String orderId = ordersSnapshot.docs.first['orderid'];
//         _showInprocessOrderDialog(orderId);
//       }
//     } catch (error) {
//       print('Error checking inprocess orders: $error');
//     }
//   }

//   void _showInprocessOrderDialog(String orderId) {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text('In-process Order'),
//           content: Text('You have an order in process. Please complete it first.'),
//           actions: <Widget>[
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => OrderDetails(
//                       orderId: orderId,
//                       uid: uid,
//                     ),
//                   ),
//                 );
//               },
//               child: Text('Go to Order'),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   Future<void> displayRiderArea() async {
//     try {
//       DocumentSnapshot areaSnapshot = await FirebaseFirestore.instance
//           .collection('rider')
//           .doc(uid)
//           .get();

//       if (areaSnapshot.exists) {
//         // String? location = areaSnapshot['location'];
//         String location = (areaSnapshot['area'] ?? '').toString().toLowerCase();
//         print('Rider location found: $location');
//         setState(() {
//           riderArea = location;
//         });
//         if (location != null && location.isNotEmpty) {
//           fetchOrders(location);
//         } else {
//           print('Warning: Rider location is empty or null');
//         }
//       } else {
//         print('Error: Rider profile not found for UID: $uid');
//       }
//     } catch (error) {
//       print('Error fetching rider area: $error');
//     }
//   }

//   Future<void> fetchOrders(String location) async {
//     setState(() {
//       isLoading = true;
//     });

//     try {
//       print('Fetching orders for area: "$location" with status 0');
//       QuerySnapshot ordersSnapshot = await FirebaseFirestore.instance
//           .collection('orders')
//           .where('area', isEqualTo: location)
//           .where('status', isEqualTo: 0)
//           .get();

//       print('Orders found in Firestore: ${ordersSnapshot.docs.length}');

//       ordersList = ordersSnapshot.docs.map((order) {
//         dynamic rawDate = order['orderDate'];
//         String formattedDate = "";
//         if (rawDate is Timestamp) {
//           formattedDate = rawDate.toDate().toString();
//         } else if (rawDate is String) {
//           formattedDate = rawDate;
//         } else {
//           formattedDate = rawDate?.toString() ?? "Unknown Date";
//         }

//         return {
//           'orderid': order['orderid'],
//           'address': order['address'],
//           'totalWeight': order['totalWeight'],
//           'phoneNumber': order['phoneNumber'],
//           'orderDate': formattedDate,
//         };
//       }).toList();

//       print('Successfully processed ${ordersList.length} orders for display');
//       setState(() {
//         isLoading = false;
//       });
//     } catch (error) {
//       print('Error in fetchOrders: $error');
//       setState(() {
//         isLoading = false;
//       });
//     }
//   }

//   void _confirmSignOut() {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text("Confirm Sign Out"),
//           content: const Text("Are you sure you want to sign out?"),
//           actions: <Widget>[
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//               child: const Text("Cancel"),
//             ),
//             TextButton(
//               onPressed: () {
//                 _signOut();
//               },
//               child: const Text("Sign Out"),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   void _signOut() async {
//     try {
//       await FirebaseAuth.instance.signOut();
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (context) => const RLogin()),
//       );
//     } catch (e) {
//       print("Error signing out: $e");
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     double screenHeight = MediaQuery.of(context).size.height;
//     double screenWidth = MediaQuery.of(context).size.width;

//     return Scaffold(
//         body: Container(
//           padding: const EdgeInsets.only(left: 10, right: 10),
//           width: double.infinity,
//           height: double.infinity,
//           color: const Color(0xFFCCCCCC).withOpacity(0.3),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.start,
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               SizedBox(height: screenHeight * 0.1),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: [
//                   Container(
//                     padding: const EdgeInsets.all(10),
//                     width: screenWidth * 0.8,
//                     child: Column(
//                       mainAxisSize: MainAxisSize.min,
//                       mainAxisAlignment: MainAxisAlignment.start,
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         isLoading
//                             ? Text("")
//                             : Text(
//                           'Hi, ${userName ?? "Rider"}',
//                           style: TextStyle(
//                             color: Color(0xFF111111),
//                             fontSize: 18,
//                             fontFamily: 'Poppins',
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                         SizedBox(height: screenHeight * 0.025),
//                         Text(
//                           'Let\'s Paint Pakistan Green!',
//                           style: TextStyle(
//                             color: Colors.black,
//                             fontSize: 15,
//                             fontFamily: 'Poppins',
//                             fontWeight: FontWeight.w300,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   IconButton(
//                     icon: const Icon(
//                       Icons.exit_to_app,
//                       color: Colors.black,
//                     ),
//                     onPressed: () {
//                       _confirmSignOut();
//                     },
//                   )
//                 ],
//               ),
//               SizedBox(height: screenHeight * 0.001),
//               const Divider(
//                 thickness: 1,
//                 color: Colors.black,
//               ),
//               Padding(
//                 padding: const EdgeInsets.only(left: 10.0),
//                 child: Row(
//                   children: [
//                     Text(
//                       "Orders",
//                       style: TextStyle(
//                           color: Color(0xFF00401A),
//                           fontWeight: FontWeight.bold,
//                           fontSize: 18),
//                     )
//                   ],
//                 ),
//               ),
//               Expanded(
//                 child: isLoading
//                     ? Center(child: CircularProgressIndicator())
//                     : ordersList.isEmpty
//                     ? RefreshIndicator(
//                         onRefresh: () => displayRiderArea(),
//                         child: ListView(
//                           children: [
//                             SizedBox(height: screenHeight * 0.2),
//                             Center(
//                                 child: Text('No Orders To Pickup',
//                                     style: TextStyle(
//                                         color: Color(0xFF00401A), fontSize: 25))),
//                           ],
//                         ),
//                       )
//                     : RefreshIndicator(
//                         onRefresh: () => displayRiderArea(),
//                         child: ListView.builder(
//                   itemCount: ordersList.length,
//                   itemBuilder: (context, index) {
//                     Map<String, dynamic> order = ordersList[index];

//                     return Container(
//                         margin: EdgeInsets.symmetric(vertical: 3),
//                         padding: EdgeInsets.all(8),
//                         decoration: BoxDecoration(
//                           color: Colors.white,
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                         child: ListTile(
//                           title: Column(
//                             crossAxisAlignment:
//                             CrossAxisAlignment.start,
//                             children: [
//                               Row(
//                                 mainAxisAlignment:
//                                 MainAxisAlignment.spaceBetween,
//                                 children: [
//                                   Container(
//                                     child: Text(
//                                       'ORDER ID: ${order['orderid']}',
//                                       style: TextStyle(
//                                           color: Color(0xFF00401A),
//                                           fontWeight: FontWeight.bold),
//                                     ),
//                                   ),
//                                   Container(
//                                     child: ElevatedButton(
//                                       onPressed: () {
//                                         Navigator.push(
//                                           context,
//                                           MaterialPageRoute(
//                                             builder: (context) =>
//                                                 OrderDetails(
//                                                   orderId:
//                                                   order['orderid'],
//                                                   uid: uid,
//                                                 ),
//                                           ),
//                                         );
//                                       },
//                                       style: ElevatedButton.styleFrom(
//                                         backgroundColor:
//                                         Color(0xFF00401A),
//                                         shape: RoundedRectangleBorder(
//                                           borderRadius:
//                                           BorderRadius.circular(
//                                               8.0),
//                                         ),
//                                       ),
//                                       child: Text(
//                                         "Pick Up",
//                                         style: TextStyle(
//                                             color: Colors.white),
//                                       ),
//                                     ),
//                                   )
//                                 ]),
//                             ],
//                           ),
//                           subtitle: Column(
//                             crossAxisAlignment:
//                             CrossAxisAlignment.start,
//                             children: [
//                               SizedBox(height: 5),
//                               Row(
//                                 children: [
//                                   Icon(
//                                     Icons.location_on,
//                                     color: Colors.red,
//                                   ),
//                                   SizedBox(width: 8),
//                                   Flexible(
//                                     child: Text(
//                                         'Address: ${order['address']}'),
//                                   ),
//                                 ],
//                               ),
//                               SizedBox(height: 5),
//                               Row(
//                                 children: [
//                                   Icon(
//                                     Icons.assignment,
//                                     color: Colors.blue,
//                                   ),
//                                   SizedBox(width: 8),
//                                   Text(
//                                       'Total Weight: ${order['totalWeight']} kgs'),
//                                 ],
//                               ),
//                               SizedBox(height: 5),
//                               Row(
//                                 children: [
//                                   Icon(
//                                     Icons.phone,
//                                     color: Colors.green,
//                                   ),
//                                   SizedBox(width: 8),
//                                   Text(
//                                       'Phone Number: ${order['phoneNumber']}'),
//                                 ],
//                               ),
//                               SizedBox(height: 5),
//                               Row(
//                                 children: [
//                                   Icon(
//                                     Icons.calendar_today,
//                                     color: Colors.orange,
//                                   ),
//                                   SizedBox(width: 8),
//                                   Flexible(
//                                     child: Text(
//                                         'Order Date: ${order['orderDate']}'),
//                                   ),
//                                 ],
//                               ),
//                             ],
//                           ),
//                         ),
//                       );
//                   },
//                 ),
//               ),
//             ),
//               SizedBox(height: screenHeight * 0.01),
//               Container(
//                 width: screenWidth * 0.87,
//                 height: screenHeight * 0.06,
//                 decoration: ShapeDecoration(
//                   color: Colors.white,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                 ),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//                     Padding(
//                       padding: const EdgeInsets.only(left: 25.0),
//                       child: IconButton(
//                         icon: const Icon(
//                           Icons.home,
//                           color: Colors.blue,
//                         ),
//                         onPressed: () {},
//                       ),
//                     ),
//                     Container(
//                       height: screenHeight * 0.05,
//                       width: 1,
//                       color: Colors.green,
//                     ),
//                     IconButton(
//                       icon: const Icon(
//                         Icons.menu,
//                         color: Colors.black,
//                       ),
//                       onPressed: () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) =>
//                                 Orders(uid: widget.uid, area: riderArea ?? ""),
//                           ),
//                         );
//                       },
//                     ),
//                     Container(
//                       height: screenHeight * 0.05,
//                       width: 1,
//                       color: Colors.green,
//                     ),
//                     Padding(
//                       padding: const EdgeInsets.only(right: 25.0),
//                       child: IconButton(
//                         icon: const Icon(
//                           Icons.person,
//                           color: Colors.black,
//                         ),
//                         onPressed: () {
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (context) => Profile(uid: uid),
//                             ),
//                           );
//                         },
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               SizedBox(height: screenHeight * 0.03),
//             ],
//           ),
//         ),
//     );
//   }
// }









// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// import 'riderLogin.dart';
// import 'Profile.dart';
// import 'OrderDetails.dart';
// import 'Orders.dart';

// class Dashboard extends StatefulWidget {
//   final String uid;

//   const Dashboard({Key? key, required this.uid}) : super(key: key);

//   @override
//   _DashboardState createState() => _DashboardState();
// }

// class _DashboardState extends State<Dashboard> {
//   String? userName;
//   late String uid;
//   String? riderArea;
//   List<Map<String, dynamic>> ordersList = [];
//   bool isLoading = false;

//   @override
//   void initState() {
//     super.initState();
//     uid = widget.uid;
//     getRiderName();
//     displayRiderArea();
//     checkInprocessOrders();
//   }

//   Future<void> getRiderName() async {
//     try {
//       final doc = await FirebaseFirestore.instance
//           .collection('rider')
//           .doc(uid)
//           .get();

//       if (doc.exists) {
//         setState(() {
//           userName = doc['name'] ?? "Rider";
//         });
//       }
//     } catch (e) {
//       print("getRiderName error: $e");
//     }
//   }

//   Future<void> displayRiderArea() async {
//     try {
//       final doc = await FirebaseFirestore.instance
//           .collection('rider')
//           .doc(uid)
//           .get();

//       if (!doc.exists) return;

//       final data = doc.data() as Map<String, dynamic>;

//       // FIXED: correct field
//       // String location = (data['address'] ?? data['area'] ?? "")
//       //     .toString()
//       //     .toLowerCase()
//       //     .trim();

// String location = (data['address'] ?? "")
//     .toString()
//     .trim();
    
//       setState(() {
//         riderArea = location;
//       });

//       if (location.isNotEmpty) {
//         fetchOrders(location);
//       }
//     } catch (e) {
//       print("displayRiderArea error: $e");
//     }
//   }

//   Future<void> fetchOrders(String location) async {
//     setState(() => isLoading = true);

//     try {
//       final snapshot = await FirebaseFirestore.instance
//           .collection('orders')
//           .where('area', isEqualTo: location)
//           .where('status', isEqualTo: 0)
//           .get();

//       ordersList = snapshot.docs.map((doc) {
//         final data = doc.data();

//         return {
//           'orderid': data['orderid'] ?? '',
//           'address': data['address'] ?? '',
//           'totalWeight': data['totalWeight'] ?? 0,
//           'phoneNumber': data['phoneNumber'] ?? '',
//           'orderDate': data['orderDate'].toString(),
//         };
//       }).toList();

//       setState(() => isLoading = false);
//     } catch (e) {
//       print("fetchOrders error: $e");
//       setState(() => isLoading = false);
//     }
//   }

//   Future<void> checkInprocessOrders() async {
//     try {
//       final snapshot = await FirebaseFirestore.instance
//           .collection('orders')
//           .where('rider', isEqualTo: uid)
//           .where('status', isEqualTo: 1)
//           .get();

//       if (snapshot.docs.isNotEmpty) {
//         final orderId = snapshot.docs.first['orderid'];

//         showDialog(
//           context: context,
//           builder: (_) => AlertDialog(
//             title: Text("In-process Order"),
//             content: Text("Complete current order first."),
//             actions: [
//               TextButton(
//                 onPressed: () {
//                   Navigator.pop(context);
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (_) => OrderDetails(
//                         orderId: orderId,
//                         uid: uid,
//                       ),
//                     ),
//                   );
//                 },
//                 child: Text("Go"),
//               )
//             ],
//           ),
//         );
//       }
//     } catch (e) {
//       print("checkInprocessOrders error: $e");
//     }
//   }

//   void _signOut() async {
//     await FirebaseAuth.instance.signOut();
//     Navigator.pushReplacement(
//       context,
//       MaterialPageRoute(builder: (_) => RLogin()),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SafeArea(
//         child: Column(
//           children: [
//             SizedBox(height: 20),

//             Text("Hi, ${userName ?? "Rider"}"),

//             SizedBox(height: 10),

//             Expanded(
//               child: isLoading
//                   ? Center(child: CircularProgressIndicator())
//                   : ordersList.isEmpty
//                   ? Center(child: Text("No Orders Found"))
//                   : ListView.builder(
//                 itemCount: ordersList.length,
//                 itemBuilder: (context, index) {
//                   final order = ordersList[index];

//                   return Card(
//                     child: ListTile(
//                       title: Text("Order: ${order['orderid']}"),
//                       subtitle: Text(order['address']),
//                       trailing: ElevatedButton(
//                         child: Text("Pickup"),
//                         onPressed: () {
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (_) => OrderDetails(
//                                 orderId: order['orderid'],
//                                 uid: uid,
//                               ),
//                             ),
//                           );
//                         },
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }







import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'riderLogin.dart';
import 'Profile.dart';
import 'OrderDetails.dart';
import 'Orders.dart';

class Dashboard extends StatefulWidget {
  final String uid;

  const Dashboard({Key? key, required this.uid}) : super(key: key);

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  String? userName;
  late String uid;
  String? riderArea;
  List<Map<String, dynamic>> ordersList = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    uid = widget.uid;
    getRiderName();
    displayRiderArea();
    checkInprocessOrders();
  }

  // ✅ GET RIDER NAME
  Future<void> getRiderName() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('rider')
          .doc(uid)
          .get();

      if (doc.exists) {
        setState(() {
          userName = doc['name'] ?? "Rider";
        });
      }
    } catch (e) {
      print("getRiderName error: $e");
    }
  }

  // ✅ GET RIDER AREA (FIX #1 APPLIED)
  Future<void> displayRiderArea() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('rider')
          .doc(uid)
          .get();

      if (!doc.exists) return;

      final data = doc.data() as Map<String, dynamic>;

      String location = (data['address'] ?? "").toString().trim();

      print("Rider location: '$location'");

      setState(() {
        riderArea = location;
      });

      if (location.isNotEmpty) {
        fetchOrders(location);
      }
    } catch (e) {
      print("displayRiderArea error: $e");
    }
  }

  // ✅ FETCH ORDERS
  Future<void> fetchOrders(String location) async {
    setState(() => isLoading = true);

    try {
      print("Fetching orders for: '$location'");

      final snapshot = await FirebaseFirestore.instance
          .collection('orders')
          .where('area', isEqualTo: location)
          .where('status', isEqualTo: 0)
          .get();

      print("Orders found: ${snapshot.docs.length}");

      ordersList = snapshot.docs.map((doc) {
        final data = doc.data();

        return {
          'orderid': data['orderid'] ?? '',
          'address': data['address'] ?? '',
          'totalWeight': data['totalWeight'] ?? 0,
          'phoneNumber': data['phoneNumber'] ?? '',
          'orderDate': data['orderDate'] is Timestamp
              ? (data['orderDate'] as Timestamp).toDate().toString()
              : data['orderDate'].toString(),
        };
      }).toList();

      setState(() => isLoading = false);
    } catch (e) {
      print("fetchOrders error: $e");
      setState(() => isLoading = false);
    }
  }

  // ✅ CHECK IN-PROCESS ORDER
  Future<void> checkInprocessOrders() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('orders')
          .where('rider', isEqualTo: uid)
          .where('status', isEqualTo: 1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final orderId = snapshot.docs.first['orderid'];

        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text("In-process Order"),
            content: const Text("Complete current order first."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => OrderDetails(
                        orderId: orderId,
                        uid: uid,
                      ),
                    ),
                  );
                },
                child: const Text("Go"),
              )
            ],
          ),
        );
      }
    } catch (e) {
      print("checkInprocessOrders error: $e");
    }
  }

  void _signOut() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => RLogin()),
    );
  }

  // 🎨 UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),

      appBar: AppBar(
        backgroundColor: const Color(0xFF00401A),
        title: Text("Hi, ${userName ?? "Rider"}"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _signOut,
          )
        ],
      ),

      body: RefreshIndicator(
        onRefresh: () => displayRiderArea(),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : ordersList.isEmpty
                ? ListView(
                    children: const [
                      SizedBox(height: 200),
                      Center(
                        child: Text(
                          "No Orders Available",
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ],
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(10),
                    itemCount: ordersList.length,
                    itemBuilder: (context, index) {
                      final order = ordersList[index];

                      return Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Order ID + Button
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Order #${order['orderid']}",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF00401A),
                                    ),
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF00401A),
                                    ),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => OrderDetails(
                                            orderId: order['orderid'],
                                            uid: uid,
                                          ),
                                        ),
                                      );
                                    },
                                    child: const Text("Pick Up"),
                                  )
                                ],
                              ),

                              const SizedBox(height: 10),

                              Text("📍 ${order['address']}"),
                              Text("⚖ ${order['totalWeight']} kg"),
                              Text("📞 ${order['phoneNumber']}"),
                              Text("📅 ${order['orderDate']}"),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
      ),

      // Bottom Navigation
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        onTap: (index) {
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    Orders(uid: widget.uid, area: riderArea ?? ""),
              ),
            );
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => Profile(uid: uid),
              ),
            );
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: "Orders"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}