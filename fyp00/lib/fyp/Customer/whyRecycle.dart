
import 'package:flutter/material.dart';
import 'Orders.dart';
import 'Profile.dart';

class WhyRecycle extends StatefulWidget {
  final String uid;

  const WhyRecycle({Key? key, required this.uid}) : super(key: key);

  @override
  State<WhyRecycle> createState() => _WhyRecycleState();
}

class _WhyRecycleState extends State<WhyRecycle> {
  final List<Map<String, String>> tips = [
    {
      "title": "Save Environment",
      "description":
          "Recycling helps keep our environment clean and reduces pollution."
    },
    {
      "title": "Save Energy",
      "description":
          "Making products from recycled materials uses less energy."
    },
    {
      "title": "Reduce Waste",
      "description":
          "Recycling reduces the amount of garbage sent to landfills."
    },
    {
      "title": "Protect Nature",
      "description":
          "Less waste means more trees, water, and natural resources are saved."
    },
    {
      "title": "Better Future",
      "description":
          "Recycling helps create a cleaner and safer future for everyone."
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),

      appBar: AppBar(
        backgroundColor: const Color(0xFF00401A),
        title: const Text("Why Recycle"),
      ),

      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: tips.length,
              itemBuilder: (context, index) {
                final tip = tips[index];

                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    title: Text(
                      tip['title']!,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(tip['description']!),
                  ),
                );
              },
            ),
          ),

          Container(
            height: 60,
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  icon: const Icon(Icons.home),
                  onPressed: () => Navigator.pop(context),
                ),
                IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => Orders(uid: widget.uid),
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.person),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => Profile(uid: widget.uid),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}