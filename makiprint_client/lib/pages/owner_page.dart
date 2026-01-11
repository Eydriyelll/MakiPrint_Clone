import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';

class OwnerPage extends StatefulWidget {
  const OwnerPage({super.key});

  @override
  State<OwnerPage> createState() => _OwnerPageState();
}

class _OwnerPageState extends State<OwnerPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  User? _currentUser;
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage; // State for the inline error

  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser;
  }

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (mounted) {
        setState(() {
          _currentUser = FirebaseAuth.instance.currentUser;
        });
      }
    } on FirebaseAuthException catch (_) {
      if (mounted) {
        setState(() => _errorMessage = "Incorrect email or password.");
      }
    } catch (e) {
      if (mounted) {
        setState(() => _errorMessage = "An unexpected error occurred.");
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUser == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Owner Login')),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.lock_person,
                    size: 80,
                    color: Color(0xFFa1d39a),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    "Owner Access Only",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),

                  // Shifted Error Banner below "Owner Access Only"
                  if (_errorMessage != null)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      margin: const EdgeInsets.only(top: 16, bottom: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFEBEE),
                        border: Border.all(color: const Color(0xFFFFCDD2)),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: const TextStyle(
                                color: Color(0xFFB71C1C),
                                fontSize: 14,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => setState(() => _errorMessage = null),
                            child: const Icon(
                              Icons.close,
                              size: 16,
                              color: Color(0xFFB71C1C),
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 24),
                  TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.email),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.key),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () => setState(
                          () => _obscurePassword = !_obscurePassword,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _isLoading
                      ? const CircularProgressIndicator()
                      : SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFa1d39a),
                              foregroundColor: Colors.black87,
                            ),
                            onPressed: _login,
                            child: const Text('Sign In'),
                          ),
                        ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return _buildDashboard();
  }

  Widget _buildDashboard() {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('owners')
          .doc(_currentUser!.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Scaffold(
            body: Center(child: Text("Error: Owner data not found.")),
          );
        }

        final data = snapshot.data!.data() as Map<String, dynamic>;
        double totalSales = (data['totalSales'] as num).toDouble();
        double ownerShare = totalSales * 0.5;
        double ceoShare = totalSales * 0.5;

        return Scaffold(
          appBar: AppBar(
            title: Text('Welcome, ${data['name']}'),
            actions: [
              IconButton(
                icon: const Icon(Icons.account_circle, size: 30),
                onPressed: () => context.push('/profile'),
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                _buildStatCard(
                  "Total Revenue",
                  "PhP ${totalSales.toStringAsFixed(2)}",
                  Colors.green,
                ),
                const SizedBox(height: 12),
                _buildStatCard(
                  "Owner Share (50%)",
                  "PhP ${ownerShare.toStringAsFixed(2)}",
                  Colors.blue,
                ),
                const SizedBox(height: 12),
                _buildStatCard(
                  "CEO Share (50%)",
                  "PhP ${ceoShare.toStringAsFixed(2)}",
                  Colors.orange,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Card(
      elevation: 4,
      child: ListTile(
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
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
