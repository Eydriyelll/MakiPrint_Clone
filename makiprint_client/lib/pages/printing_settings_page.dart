import 'package:flutter/material.dart';

class PrintingSettingsPage extends StatelessWidget {
  const PrintingSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Printing Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: const Center(
        child: Text('Printing Settings - Coming Soon'),
      ),
    );
  }
}