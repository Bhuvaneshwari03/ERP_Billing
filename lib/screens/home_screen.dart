import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'product_screen.dart';
import 'billing_screen.dart';
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("ERP Dashboard"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => FirebaseAuth.instance.signOut(),
          )
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(
                  builder: (context) => const ProductScreen(),
                ));
              },
              child: const Text("Go to Product Master"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(
                  builder: (context) => const BillingScreen(),
                ));
              },
              child: const Text("New Bill"),
            ),
            const SizedBox(height: 10),
            const Text("Welcome to the ERP App"),
          ],
        ),
      ),
    );
  }
}
