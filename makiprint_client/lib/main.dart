import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(

        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
      ),
      home: const MyHomePage(title: 'MakiPrint'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final List<String> _documents = [];

  static const String _prefsKey = 'uploaded_documents';

  @override
  void initState() {
    super.initState();
    _loadDocuments();
  }

  Future<void> _loadDocuments() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_prefsKey);
    if (jsonStr != null && jsonStr.isNotEmpty) {
      try {
        final List<dynamic> decoded = json.decode(jsonStr);
        setState(() {
          _documents.clear();
          _documents.addAll(decoded.map((e) => e.toString()));
        });
      } catch (_) {
        // ignore malformed saved data
      }
    }
  }

  Future<void> _saveDocuments() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = json.encode(_documents);
    await prefs.setString(_prefsKey, jsonStr);
  }

  void addDocument() {
    // Keep a simple alert for the Top-up button (separate from file upload)
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add file'),
        content: const Text('Add file coming soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: SafeArea(
        
        
        // this allows the rest of the screen to be scrollable
        child: SingleChildScrollView(
          
          
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              
              // Account Balance card pinned at top
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Balance info
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Account Balance',
                              style: Theme.of(context).textTheme.labelLarge,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Php 0.00',
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        // Top-up button with + icon at left
                        ElevatedButton.icon(
                          onPressed: addDocument,
                          icon: const Icon(Icons.add),
                          label: const Text('Top-up'),
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // allows a bit of spacing between the balance card and the documents
              const SizedBox(height: 24),

              // Documents list (each file displayed in a Card with actions)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: _documents.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text('No documents uploaded yet.'),
                      )
                    : Column(
                        children: _documents
                            .asMap()
                            .entries
                            .map((entry) {
                              final idx = entry.key;
                              final doc = entry.value;
                              return Card(
                                margin: const EdgeInsets.symmetric(vertical: 8.0),
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              doc,
                                              style: Theme.of(context).textTheme.titleMedium,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete),
                                            tooltip: 'Delete',
                                            onPressed: () async {
                                              final confirmed = await showDialog<bool>(
                                                context: context,
                                                builder: (ctx) => AlertDialog(
                                                  title: const Text('Delete file'),
                                                  content: const Text('Are you sure you want to delete this file?'),
                                                  actions: [
                                                    TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
                                                    TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Delete')),
                                                  ],
                                                ),
                                              );
                                              if (!mounted) return;
                                              if (confirmed == true) {
                                                setState(() {
                                                  _documents.removeAt(idx);
                                                });
                                                await _saveDocuments();
                                              }
                                            },
                                          )
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          ElevatedButton(
                                            onPressed: () {
                                              // Placeholder for Printing Settings
                                            },
                                            child: const Text('Printing Settings'),
                                          ),
                                          const SizedBox(width: 12),
                                          ElevatedButton(
                                            onPressed: () {
                                              // Placeholder for Scan
                                            },
                                            child: const Text('Scan'),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            })
                            .toList(),
                      ),
              ),




            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Use FilePicker to select a file and persist it
          final messenger = ScaffoldMessenger.of(context);
          try {
            final result = await FilePicker.platform.pickFiles(allowMultiple: false);
            if (!mounted) return;
            if (result != null && result.files.isNotEmpty) {
              final fileName = result.files.single.name;
              setState(() {
                _documents.add(fileName);
              });
              await _saveDocuments();
            }
          } catch (e) {
            // show simple error using captured messenger (avoids using context after await)
            messenger.showSnackBar(SnackBar(content: Text('File pick failed: $e')));
          }
        },
        tooltip: 'Add document',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class AddDocumentPage extends StatefulWidget {
  const AddDocumentPage({super.key});

  @override
  State<AddDocumentPage> createState() => _AddDocumentPageState();
}

class _AddDocumentPageState extends State<AddDocumentPage> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Upload File')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Simulate file upload by entering a filename:'),
            const SizedBox(height: 12),
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Filename',
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(_controller.text.trim());
              },
              child: const Text('Upload'),
            ),
          ],
        ),
      ),
    );
  }
}
