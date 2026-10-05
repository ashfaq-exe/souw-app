import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../services/auth_service.dart';
import '../services/firestore_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final service = FirestoreService();
  final authService = AuthService();

  Map<String, dynamic>? userData;

  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Future<void> loadProfile() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      if (!mounted) return;

      setState(() {
        loading = false;
      });

      return;
    }

    final data = await service.getUser(user.uid);

    if (!mounted) return;

    setState(() {
      userData = data;
      loading = false;
    });
  }

  Future<void> logout() async {
    await authService.logout();

    if (!mounted) return;

    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final role = userData?['role'] ?? 'User';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F9F8),

      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: const Color(0xFF008F83),
        foregroundColor: Colors.white,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [
            const SizedBox(height: 10),

            Container(
              width: 100,
              height: 100,

              decoration: const BoxDecoration(
                color: Color(0xFF008F83),
                shape: BoxShape.circle,
              ),

              child: const Icon(Icons.person, size: 60, color: Colors.white),
            ),

            const SizedBox(height: 18),

            Text(
              userData?['name'] ?? 'User',

              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 5),

            Text(
              userData?['email'] ?? '',

              style: const TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 25),

            Card(
              elevation: 2,

              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),

              child: Column(
                children: [
                  profileRow(Icons.phone, 'Phone', userData?['phone'] ?? ''),

                  const Divider(height: 1),

                  profileRow(Icons.people, 'Role', role),
                ],
              ),
            ),

            const SizedBox(height: 25),

            SizedBox(
              width: double.infinity,
              height: 55,

              child: ElevatedButton.icon(
                onPressed: logout,

                icon: const Icon(Icons.logout),

                label: const Text(
                  'Logout',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                ),

                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,

                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget profileRow(IconData icon, String title, String value) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),

      leading: Icon(icon, color: const Color(0xFF008F83)),

      title: Text(title, style: const TextStyle(color: Colors.grey)),

      subtitle: Text(
        value,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }
}
