import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../services/firestore_service.dart';

class MyFoodScreen extends StatelessWidget {
  const MyFoodScreen({super.key});

  Color statusColor(String status) {
    if (status == 'Available') {
      return Colors.green;
    }

    if (status == 'Requested') {
      return Colors.orange;
    }

    if (status == 'Reserved') {
      return Colors.blue;
    }

    if (status == 'Collected') {
      return Colors.purple;
    }

    if (status == 'Shared') {
      return Colors.green.shade700;
    }

    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    final service = FirestoreService();

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(body: Center(child: Text('Please login first')));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F9F8),

      appBar: AppBar(
        title: const Text('My Food'),
        backgroundColor: const Color(0xFF008F83),
        foregroundColor: Colors.white,
      ),

      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: service.getMyFoods(user.uid),

        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,

                children: [
                  Icon(Icons.restaurant, size: 70, color: Colors.grey),

                  SizedBox(height: 15),

                  Text(
                    'You have not shared food yet.',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          final foods = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),

            itemCount: foods.length,

            itemBuilder: (context, index) {
              final data = foods[index].data();

              final foodName = data['foodName'] ?? '';

              final quantity = data['quantity'] ?? '';

              final location = data['location'] ?? '';

              final status = data['status'] ?? 'Available';

              return Card(
                margin: const EdgeInsets.only(bottom: 15),

                elevation: 3,

                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),

                child: Padding(
                  padding: const EdgeInsets.all(18),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      Row(
                        children: [
                          Container(
                            width: 50,
                            height: 50,

                            decoration: BoxDecoration(
                              color: const Color(0xFFE0F2F1),

                              borderRadius: BorderRadius.circular(14),
                            ),

                            child: const Icon(
                              Icons.restaurant,
                              color: Color(0xFF008F83),
                            ),
                          ),

                          const SizedBox(width: 15),

                          Expanded(
                            child: Text(
                              foodName,
                              style: const TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 15),

                      Text(
                        'Quantity: $quantity',
                        style: const TextStyle(fontSize: 15),
                      ),

                      const SizedBox(height: 6),

                      Text(
                        'Location: $location',
                        style: const TextStyle(fontSize: 15),
                      ),

                      const SizedBox(height: 15),

                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),

                        decoration: BoxDecoration(
                          color: statusColor(status).withValues(alpha: 0.12),

                          borderRadius: BorderRadius.circular(20),
                        ),

                        child: Text(
                          status,

                          style: TextStyle(
                            color: statusColor(status),

                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
