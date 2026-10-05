import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../services/firestore_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final service = FirestoreService();

  String role = '';
  String name = '';
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  Future<void> loadUser() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      if (!mounted) return;

      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);

      return;
    }

    final data = await service.getUser(user.uid);

    if (!mounted) return;

    setState(() {
      name = data?['name'] ?? 'User';
      role = data?['role'] ?? '';
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F9F8),

      appBar: AppBar(
        backgroundColor: const Color(0xFF008F83),
        foregroundColor: Colors.white,
        elevation: 0,

        title: const Text(
          'SOUW',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),

        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.pushNamed(context, '/profile');
            },
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            const SizedBox(height: 5),

            Text(
              'Hello, $name 👋',
              style: const TextStyle(fontSize: 27, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 6),

            Text(
              role == 'Donor'
                  ? 'Thank you for sharing food.'
                  : 'Find food and help reduce waste.',
              style: const TextStyle(fontSize: 15, color: Colors.grey),
            ),

            const SizedBox(height: 25),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),

              decoration: BoxDecoration(
                color: const Color(0xFF008F83),

                borderRadius: BorderRadius.circular(22),
              ),

              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(15),

                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),

                      shape: BoxShape.circle,
                    ),

                    child: const Icon(
                      Icons.restaurant,
                      color: Colors.white,
                      size: 35,
                    ),
                  ),

                  const SizedBox(width: 18),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        Text(
                          role,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 21,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 5),

                        Text(
                          role == 'Donor'
                              ? 'Share surplus food with people who need it.'
                              : 'Discover available food near you.',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            const Text(
              'What would you like to do?',
              style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 15),

            if (role == 'Donor') ...[
              actionCard(
                context,
                'Add Food',
                'Share your unused food',
                Icons.add_circle,
                '/add-food',
              ),

              actionCard(
                context,
                'My Food',
                'Manage your shared food',
                Icons.restaurant_menu,
                '/my-food',
              ),

              actionCard(
                context,
                'Food Requests',
                'Manage receiver requests',
                Icons.notifications,
                '/requests',
              ),
            ],

            if (role == 'Receiver') ...[
              actionCard(
                context,
                'Browse Food',
                'Find available food',
                Icons.search,
                '/browse-food',
              ),

              actionCard(
                context,
                'My Requests',
                'Track your food requests',
                Icons.shopping_bag,
                '/requests',
              ),
            ],

            const SizedBox(height: 15),

            actionCard(
              context,
              'Profile',
              'View your account',
              Icons.person,
              '/profile',
            ),
          ],
        ),
      ),
    );
  }

  Widget actionCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    String route,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),

      child: Material(
        color: Colors.white,

        borderRadius: BorderRadius.circular(18),

        child: InkWell(
          borderRadius: BorderRadius.circular(18),

          onTap: () {
            Navigator.pushNamed(context, route);
          },

          child: Padding(
            padding: const EdgeInsets.all(18),

            child: Row(
              children: [
                Container(
                  width: 55,
                  height: 55,

                  decoration: BoxDecoration(
                    color: const Color(0xFFE0F2F1),

                    borderRadius: BorderRadius.circular(15),
                  ),

                  child: Icon(icon, color: const Color(0xFF008F83), size: 28),
                ),

                const SizedBox(width: 16),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),

                const Icon(
                  Icons.arrow_forward_ios,
                  size: 18,
                  color: Colors.grey,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
