import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../services/firestore_service.dart';

class RequestsScreen extends StatelessWidget {
  const RequestsScreen({super.key});

  Color statusColor(String status) {
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
      return Colors.green;
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
      appBar: AppBar(
        title: const Text('Food Requests'),
        backgroundColor: const Color(0xFF008F83),
        foregroundColor: Colors.white,
      ),

      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: service.getRequests(),

        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return const Center(child: Text('No requests found.'));
          }

          return FutureBuilder<Map<String, dynamic>?>(
            future: service.getUser(user.uid),

            builder: (context, userSnapshot) {
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final role = userSnapshot.data?['role'] ?? '';

              final requests = snapshot.data!.docs.where((doc) {
                final data = doc.data();

                if (role == 'Donor') {
                  return data['donorId'] == user.uid;
                }

                if (role == 'Receiver') {
                  return data['receiverId'] == user.uid;
                }

                return false;
              }).toList();

              if (requests.isEmpty) {
                return Center(
                  child: Text(
                    role == 'Donor'
                        ? 'No food requests yet.'
                        : 'You have not requested any food.',
                    style: const TextStyle(fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),

                itemCount: requests.length,

                itemBuilder: (context, index) {
                  final doc = requests[index];

                  final data = doc.data();

                  final foodName = data['foodName'] ?? '';

                  final quantity = data['quantity'] ?? '';

                  final receiverName = data['receiverName'] ?? '';

                  final status = data['status'] ?? 'Requested';

                  final foodId = data['foodId'] ?? '';

                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),

                    elevation: 3,

                    child: Padding(
                      padding: const EdgeInsets.all(18),

                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          Row(
                            children: [
                              const CircleAvatar(
                                backgroundColor: Color(0xFFE0F2F1),

                                child: Icon(
                                  Icons.restaurant,
                                  color: Color(0xFF008F83),
                                ),
                              ),

                              const SizedBox(width: 12),

                              Expanded(
                                child: Text(
                                  foodName,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 15),

                          Text(
                            'Quantity: $quantity',
                            style: const TextStyle(fontSize: 16),
                          ),

                          const SizedBox(height: 5),

                          Text(
                            'Receiver: $receiverName',
                            style: const TextStyle(fontSize: 16),
                          ),

                          const SizedBox(height: 15),

                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),

                            decoration: BoxDecoration(
                              color: statusColor(status)
                                  .withValues(alpha: 0.12),

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

                          if (role == 'Donor' && status == 'Requested') ...[
                            const SizedBox(height: 18),

                            SizedBox(
                              width: double.infinity,

                              child: ElevatedButton(
                                onPressed: () {
                                  service.updateRequestStatus(
                                    requestId: doc.id,
                                    foodId: foodId,
                                    status: 'Reserved',
                                  );
                                },

                                child: const Text('Reserve Food'),
                              ),
                            ),
                          ],

                          if (role == 'Donor' && status == 'Reserved') ...[
                            const SizedBox(height: 18),

                            SizedBox(
                              width: double.infinity,

                              child: ElevatedButton(
                                onPressed: () {
                                  service.updateRequestStatus(
                                    requestId: doc.id,
                                    foodId: foodId,
                                    status: 'Collected',
                                  );
                                },

                                child: const Text('Mark as Collected'),
                              ),
                            ),
                          ],

                          if (role == 'Donor' && status == 'Collected') ...[
                            const SizedBox(height: 18),

                            SizedBox(
                              width: double.infinity,

                              child: ElevatedButton(
                                onPressed: () {
                                  service.updateRequestStatus(
                                    requestId: doc.id,
                                    foodId: foodId,
                                    status: 'Shared',
                                  );
                                },

                                child: const Text('Mark as Shared'),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
