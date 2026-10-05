import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/food_model.dart';
import '../services/firestore_service.dart';
import 'food_details_screen.dart';

class BrowseFoodScreen extends StatelessWidget {
  const BrowseFoodScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = FirestoreService();

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(body: Center(child: Text('Please login first')));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Browse Food'),
        backgroundColor: const Color(0xFF008F83),
        foregroundColor: Colors.white,
      ),

      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: service.getAvailableFoods(),

        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return const Center(child: Text('No food available.'));
          }

          final foods = snapshot.data!.docs;

          if (foods.isEmpty) {
            return const Center(
              child: Text('No food available.', style: TextStyle(fontSize: 18)),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),

            itemCount: foods.length,

            itemBuilder: (context, index) {
              final doc = foods[index];

              final food = FoodModel.fromMap(doc.id, doc.data());

              return Card(
                margin: const EdgeInsets.only(bottom: 15),

                elevation: 3,

                child: ListTile(
                  contentPadding: const EdgeInsets.all(15),

                  leading: CircleAvatar(
                    backgroundColor: Colors.green.shade100,

                    child: const Icon(Icons.restaurant, color: Colors.green),
                  ),

                  title: Text(
                    food.foodName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  subtitle: Text(
                    'Quantity: ${food.quantity}\n'
                    'Location: ${food.location}\n'
                    'Donor: ${food.donorName}',
                  ),

                  isThreeLine: true,

                  trailing: const Icon(Icons.arrow_forward_ios),

                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FoodDetailsScreen(food: food),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
