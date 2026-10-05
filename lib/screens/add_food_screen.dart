import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../services/firestore_service.dart';

class AddFoodScreen extends StatefulWidget {
  const AddFoodScreen({super.key});

  @override
  State<AddFoodScreen> createState() => _AddFoodScreenState();
}

class _AddFoodScreenState extends State<AddFoodScreen> {
  final foodNameController = TextEditingController();

  final descriptionController = TextEditingController();

  final quantityController = TextEditingController();

  final locationController = TextEditingController();

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

  Future<void> addFood() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return;
    }

    if (role != 'Donor') {
      return;
    }

    if (foodNameController.text.trim().isEmpty ||
        quantityController.text.trim().isEmpty ||
        locationController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );

      return;
    }

    setState(() {
      loading = true;
    });

    try {
      final data = await service.getUser(user.uid);

      final donorName = data?['name'] ?? 'Donor';

      await service.addFood(
        foodName: foodNameController.text.trim(),

        description: descriptionController.text.trim(),

        quantity: quantityController.text.trim(),

        location: locationController.text.trim(),

        donorId: user.uid,

        donorName: donorName,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Food added successfully'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    }

    if (mounted) {
      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (checkingRole) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (role != 'Donor') {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Add Food'),
          backgroundColor: const Color(0xFF008F83),
          foregroundColor: Colors.white,
        ),

        body: const Center(
          child: Text(
            'Only Donors can add food.',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Food'),
        backgroundColor: const Color(0xFF008F83),
        foregroundColor: Colors.white,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [
            TextField(
              controller: foodNameController,
              decoration: const InputDecoration(
                labelText: 'Food Name',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: quantityController,
              decoration: const InputDecoration(
                labelText: 'Quantity',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: locationController,
              decoration: const InputDecoration(
                labelText: 'Location',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 25),

            SizedBox(
              width: double.infinity,
              height: 55,

              child: ElevatedButton(
                onPressed: loading ? null : addFood,

                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF008F83),
                  foregroundColor: Colors.white,
                ),

                child: loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Add Food',
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
