import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OwnerPage extends StatefulWidget {
  const OwnerPage({super.key});

  @override
  State<OwnerPage> createState() => _OwnerPageState();
}

class _OwnerPageState extends State<OwnerPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  User? _currentUser;

  // Pricing constants fetched from your project logic
  final Map<String, int> _baseCosts = {
    'A4': 1,
    'Short Bond Paper': 2,
    'Long Bond Paper': 3,
  };
  final int _colorExtra = 3;

  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser;
  }

  Future<void> _login() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      setState(() => _currentUser = FirebaseAuth.instance.currentUser);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Login Failed: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUser == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Owner Login')),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: _login, child: const Text('Login')),
            ],
          ),
        ),
      );
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('owners')
          .doc(_currentUser!.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return const Center(child: CircularProgressIndicator());

        double totalSales = (snapshot.data!['totalSales'] as num).toDouble();
        double ownerCut = totalSales * 0.5; // 50% Cut
        double ceoCut = totalSales * 0.5; // 50% Cut

        return Scaffold(
          appBar: AppBar(title: Text('Dashboard: ${snapshot.data!['name']}')),
          body: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                _buildStatCard(
                  "Total Revenue",
                  "PhP ${totalSales.toStringAsFixed(2)}",
                  Colors.green,
                ),
                const SizedBox(height: 10),
                _buildStatCard(
                  "Your Cut (50%)",
                  "PhP ${ownerCut.toStringAsFixed(2)}",
                  Colors.blue,
                ),
                const SizedBox(height: 10),
                _buildStatCard(
                  "CEO Cut (50%)",
                  "PhP ${ceoCut.toStringAsFixed(2)}",
                  Colors.orange,
                ),
                const Divider(height: 40),
                const Text(
                  "Pricing Reference (from MakiPrint logic):",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  "A4: PhP ${_baseCosts['A4']} | Color: +PhP $_colorExtra",
                ), // Citing pricing constants
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Card(
      child: ListTile(
        title: Text(label),
        trailing: Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: color,
          ),
        ),
      ),
    );
  }
}
