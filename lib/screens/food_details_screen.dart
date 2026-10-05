import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/food_model.dart';
import '../services/firestore_service.dart';

class FoodDetailsScreen extends StatefulWidget {
  final FoodModel food;

  const FoodDetailsScreen({super.key, required this.food});

  @override
  State<FoodDetailsScreen> createState() => _FoodDetailsScreenState();
}

class _FoodDetailsScreenState extends State<FoodDetailsScreen> {
  final service = FirestoreService();

  bool loading = false;
  bool checkingRole = true;

  String role = '';

  @override
  void initState() {
    super.initState();
    checkRole();
  }

  Future<void> checkRole() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      if (!mounted) return;

      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);

      return;
    }

    final data = await service.getUser(user.uid);

    if (!mounted) return;

    setState(() {
      role = data?['role'] ?? '';
      checkingRole = false;
    });
  }

  Future<void> requestFood() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return;
    }

    if (role != 'Receiver') {
      return;
    }

    setState(() {
      loading = true;
    });

    try {
      final userData = await service.getUser(user.uid);

      final receiverName = userData?['name'] ?? 'Receiver';

      await service.createRequest(
        foodId: widget.food.id,
        foodName: widget.food.foodName,
        donorId: widget.food.donorId,
        receiverId: user.uid,
        receiverName: receiverName,
        quantity: widget.food.quantity,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Food requested successfully'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }

    if (mounted) {
      setState(() {
        loading = false;
      });
    }
  }

  Widget detail(IconData icon, String title, String value) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF008F83)),

      title: Text(title, style: const TextStyle(color: Colors.grey)),

      subtitle: Text(
        value,
        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (checkingRole) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Food Details'),
        backgroundColor: const Color(0xFF008F83),
        foregroundColor: Colors.white,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [
            const Icon(Icons.restaurant, size: 90, color: Color(0xFF008F83)),

            const SizedBox(height: 20),

            Text(
              widget.food.foodName,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            Card(
              child: Column(
                children: [
                  detail(
                    Icons.description,
                    'Description',
                    widget.food.description,
                  ),

                  detail(Icons.scale, 'Quantity', widget.food.quantity),

                  detail(Icons.location_on, 'Location', widget.food.location),

                  detail(Icons.person, 'Donor', widget.food.donorName),

                  detail(Icons.info, 'Status', widget.food.status),
                ],
              ),
            ),

            const SizedBox(height: 25),

            if (role == 'Receiver' && widget.food.status == 'Available')
              SizedBox(
                width: double.infinity,
                height: 55,

                child: ElevatedButton(
                  onPressed: loading ? null : requestFood,

                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF008F83),
                    foregroundColor: Colors.white,
                  ),

                  child: loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Request Food',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
