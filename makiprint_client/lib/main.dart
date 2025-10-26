import 'dart:convert';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models/document.dart';
import 'pages/printing_settings_page.dart';
import 'pages/scan_qr_page.dart';
import 'pages/tutorial_modal.dart';

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
  final List<Document> _documents = [];
  Timer? _expiryTimer;

  static const String _prefsKey = 'uploaded_documents';

  @override
  void initState() {
    super.initState();
    showTutorialModal(context);
    _loadDocuments();
    _startExpiryTimer();
  }

  @override
  void dispose() {
    _expiryTimer?.cancel();
    super.dispose();
  }

  void _startExpiryTimer() {
    _expiryTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      bool hasExpired = false;

      for (var doc in List.from(_documents)) {
        if (doc.isExpired) {
          _documents.remove(doc);
          hasExpired = true;
        }
      }

      // Update UI every second for countdown timer
      setState(() {});

      if (hasExpired) {
        _saveDocuments();
      }
    });
  }

  Future<void> _loadDocuments() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_prefsKey);
    if (jsonStr != null && jsonStr.isNotEmpty) {
      try {
        final List<dynamic> decoded = json.decode(jsonStr);
        setState(() {
          _documents.clear();
          _documents.addAll(
            decoded.map((e) => Document.fromJson(Map<String, dynamic>.from(e))),
          );
        });
      } catch (_) {
        // ignore malformed saved data
      }
    }
  }

  Future<void> _saveDocuments() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = json.encode(_documents.map((doc) => doc.toJson()).toList());
    await prefs.setString(_prefsKey, jsonStr);
  }

  void addDocument() {
    // Keep a simple alert for the Top-up button (separate from file upload)
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Top-up'),
        content: const Text('Top-up coming soon!'),
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
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
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        // Top-up button with + icon at left
                        ElevatedButton.icon(
                          onPressed: addDocument,
                          icon: const Icon(Icons.add),
                          label: const Text('Top-up'),
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
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
                        children: _documents.asMap().entries.map((entry) {
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
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          doc.fileName,
                                          style: Theme.of(
                                            context,
                                          ).textTheme.titleMedium,
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
                                              content: const Text(
                                                'Are you sure you want to delete this file?',
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed: () => Navigator.of(
                                                    ctx,
                                                  ).pop(false),
                                                  child: const Text('Cancel'),
                                                ),
                                                TextButton(
                                                  onPressed: () => Navigator.of(
                                                    ctx,
                                                  ).pop(true),
                                                  child: const Text('Delete'),
                                                ),
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
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Text(
                                        'Php ${doc.printingCost.toStringAsFixed(2)}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: Theme.of(
                                                context,
                                              ).colorScheme.primary,
                                            ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Expires in: ${doc.formattedTimeRemaining}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color:
                                              doc.timeRemaining.inMinutes < 10
                                              ? Colors.red
                                              : null,
                                          fontWeight:
                                              doc.timeRemaining.inMinutes < 10
                                              ? FontWeight.bold
                                              : null,
                                        ),
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: ElevatedButton.icon(
                                          onPressed: () async {
                                            // Navigate to PrintingSettingsPage and wait for returned settings
                                            final result =
                                                await Navigator.push<
                                                  Map<String, dynamic>
                                                >(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        PrintingSettingsPage(
                                                          initialCopies:
                                                              _documents[idx]
                                                                  .copies,
                                                          initialPaperSize:
                                                              _documents[idx]
                                                                  .paperSize,
                                                          initialIsColor:
                                                              _documents[idx]
                                                                  .isColor,
                                                        ),
                                                  ),
                                                );

                                            if (!mounted) return;

                                            if (result != null) {
                                              setState(() {
                                                _documents[idx].copies =
                                                    result['copies'] as int;
                                                _documents[idx].paperSize =
                                                    result['paperSize']
                                                        as String;
                                                _documents[idx].isColor =
                                                    result['isColor'] as bool;
                                                _documents[idx].printingCost =
                                                    (result['totalCost'] as num)
                                                        .toDouble();
                                              });
                                              _saveDocuments(); // Save changes to persistent storage
                                            }
                                          },
                                          icon: const Icon(Icons.settings),
                                          label: const Text(
                                            'Printing Settings',
                                          ),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.green,
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 12,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: ElevatedButton.icon(
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    const ScanQRPage(),
                                              ),
                                            );
                                          },
                                          icon: const Icon(
                                            Icons.qr_code_scanner,
                                          ),
                                          label: const Text('Print'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.green,
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 12,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final messenger = ScaffoldMessenger.of(context);
          bool isLoading = false;

          void showLoadingIndicator() {
            if (!mounted) return;
            isLoading = true;
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (BuildContext context) => WillPopScope(
                onWillPop: () async => false,
                child: const Center(child: CircularProgressIndicator()),
              ),
            );
          }

          void hideLoadingIndicator() {
            if (!mounted || !isLoading) return;
            isLoading = false;
            Navigator.of(context, rootNavigator: true).pop();
          }

          try {
            // Configure file picker for PDF and Word documents
            final result = await FilePicker.platform.pickFiles(
              type: FileType.custom,
              allowedExtensions: ['pdf', 'doc', 'docx'],
              allowMultiple: false,
              withData: true, // Load file into memory for preview/validation
            );

            if (!mounted) return;

            if (result != null && result.files.isNotEmpty) {
              showLoadingIndicator();

              final file = result.files.single;

              // Validate file size (max 10MB for mobile optimization)
              if (file.size > 10 * 1024 * 1024) {
                hideLoadingIndicator();
                messenger.showSnackBar(
                  const SnackBar(
                    content: Text('File too large. Maximum size is 10MB.'),
                  ),
                );
                return;
              }

              // Add a small delay to show loading indicator
              await Future.delayed(const Duration(milliseconds: 500));

              final newDoc = Document(
                fileName: file.name,
                copies: 1, // Default values
                paperSize: 'A4',
                isColor: true,
              );

              setState(() {
                _documents.add(newDoc);
              });
              await _saveDocuments();
              hideLoadingIndicator();

              messenger.showSnackBar(
                const SnackBar(content: Text('File uploaded successfully')),
              );
            }
          } catch (e) {
            if (isLoading) {
              hideLoadingIndicator();
            }
            messenger.showSnackBar(
              SnackBar(
                content: Text('Could not upload file: ${e.toString()}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        label: const Text('UPLOAD FILE'),
        tooltip: 'Add document',
        icon: const Icon(Icons.add),
      ),
    );
  }
}
