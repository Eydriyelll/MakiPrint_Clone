import 'dart:convert';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:archive/archive.dart';
import 'package:xml/xml.dart' as xml;

import 'models/document.dart';
import 'pages/home.dart';
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
      title: 'MakiPrint',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
      ),
      initialRoute: '/home',
      routes: {
        '/home': (context) => const HomePage(),
        '/app': (context) => const MyHomePage(title: 'MakiPrint'),
        '/print': (context) => const MyHomePage(title: 'MakiPrint'),
      },
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
    try {
      showTutorialModal(context);
    } catch (e) {
      print('Error showing tutorial: $e');
    }
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
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              doc.fileName,
                                              style: Theme.of(
                                                context,
                                              ).textTheme.titleMedium,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'Pages: ${doc.pageCount}',
                                              style: Theme.of(
                                                context,
                                              ).textTheme.bodySmall,
                                            ),
                                          ],
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
                                                    builder: (context) => PrintingSettingsPage(
                                                      initialCopies:
                                                          _documents[idx]
                                                              .copies,
                                                      initialPaperSize:
                                                          _documents[idx]
                                                              .paperSize,
                                                      initialIsColor:
                                                          _documents[idx]
                                                              .isColor,
                                                      pageCount: _documents[idx]
                                                          .pageCount,
                                                      initialPageSizePts:
                                                          (_documents[idx]
                                                                      .pageWidthPts !=
                                                                  null &&
                                                              _documents[idx]
                                                                      .pageHeightPts !=
                                                                  null)
                                                          ? Size(
                                                              _documents[idx]
                                                                  .pageWidthPts!,
                                                              _documents[idx]
                                                                  .pageHeightPts!,
                                                            )
                                                          : null,
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

              // Read page count based on file type
              int pageCount = 1;
              Size? firstPageSizePts;
              try {
                final fileName = file.name.toLowerCase();
                final fileBytes = file.bytes;

                if (fileBytes != null) {
                  if (fileName.endsWith('.pdf')) {
                    pageCount = await _getPageCountPDF(fileBytes);
                    firstPageSizePts = _getFirstPageSizeFromPdfBytes(fileBytes);
                  } else if (fileName.endsWith('.docx')) {
                    pageCount = await _getPageCountDOCX(fileBytes);
                    // Try to extract page size from DOCX document.xml
                    final docxSize = _getPageSizeFromDocxBytes(fileBytes);
                    if (docxSize != null) {
                      firstPageSizePts = docxSize;
                    }
                  } else if (fileName.endsWith('.doc')) {
                    pageCount = await _getPageCountDOC(fileBytes);
                    // .doc (binary) page-size extraction not supported reliably here.
                    // Prompt user to re-save as PDF/DOCX or proceed with default A4.
                    final proceed = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Unsupported DOC format'),
                        content: const Text(
                          'Could not reliably extract page size from .doc files.\nPlease save the document as PDF or DOCX for accurate sizing.\nDo you want to proceed with default A4 sizing?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(ctx).pop(false),
                            child: const Text('Cancel Upload'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(ctx).pop(true),
                            child: const Text('Proceed (A4)'),
                          ),
                        ],
                      ),
                    );
                    if (proceed != true) {
                      hideLoadingIndicator();
                      messenger.showSnackBar(
                        const SnackBar(
                          content: Text('Upload cancelled for .doc file'),
                        ),
                      );
                      return;
                    }
                  }
                }
              } catch (e) {
                print('Error reading page count: $e');
                pageCount = 1;
              }

              // Determine paper size from detected first-page dimensions (if any)
              String detectedPaper = 'A4';
              if (firstPageSizePts != null) {
                final det = _detectPaperSizeFromPoints(firstPageSizePts);
                if (det != null) detectedPaper = det;
              }

              final computedCost = _computePrintingCost(
                paperSize: detectedPaper,
                isColor: true,
                pageCount: pageCount,
                copies: 1,
              );

              final newDoc = Document(
                fileName: file.name,
                copies: 1, // Default values
                paperSize: detectedPaper,
                isColor: true,
                pageCount: pageCount,
                pageWidthPts: firstPageSizePts?.width,
                pageHeightPts: firstPageSizePts?.height,
              );

              // Set initial printing cost so UI shows computed price immediately
              newDoc.printingCost = computedCost;

              setState(() {
                _documents.add(newDoc);
              });
              await _saveDocuments();
              hideLoadingIndicator();

              messenger.showSnackBar(
                SnackBar(
                  content: Text(
                    'File uploaded successfully - $pageCount pages detected',
                  ),
                ),
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

  // Get page count from PDF file
  Future<int> _getPageCountPDF(List<int> fileBytes) async {
    try {
      if (fileBytes.isEmpty) return 1;

      // Parse PDF to find page count more accurately
      String pdfString = utf8.decode(fileBytes, allowMalformed: true);

      // Count /Type /Page patterns (but filter duplicates from object definitions)
      // More precise: look for page dictionary entries
      int pageCount = 0;
      final pagePattern = RegExp(r'/Type\s*/Page(?!s)');
      pageCount = pagePattern.allMatches(pdfString).length;

      if (pageCount > 0) {
        print('PDF page count (from content): $pageCount');
        return pageCount;
      }

      // Fallback: use conservative file size heuristic
      // Each page in a typical PDF is approximately 5000-6000 bytes
      final estimatedPages = (fileBytes.length / 5500).ceil();
      print('PDF page count (estimated from size): $estimatedPages');
      return estimatedPages > 0 ? estimatedPages : 1;
    } catch (e) {
      print('Error reading PDF: $e');
      return 1;
    }
  }

  // Try to extract the first page's MediaBox or CropBox from raw PDF bytes.
  // Returns a Size in PDF points (72 pts = 1 inch) or null if not found.
  Size? _getFirstPageSizeFromPdfBytes(List<int> fileBytes) {
    try {
      if (fileBytes.isEmpty) return null;
      final pdfString = utf8.decode(fileBytes, allowMalformed: true);

      // Look for MediaBox array: /MediaBox [ llx lly urx ury ]
      final mediaBoxPattern = RegExp(
        r'/MediaBox\s*\[\s*([0-9.+-]+)\s+([0-9.+-]+)\s+([0-9.+-]+)\s+([0-9.+-]+)\s*\]',
      );
      final cropBoxPattern = RegExp(
        r'/CropBox\s*\[\s*([0-9.+-]+)\s+([0-9.+-]+)\s+([0-9.+-]+)\s+([0-9.+-]+)\s*\]',
      );

      final mediaMatch = mediaBoxPattern.firstMatch(pdfString);
      RegExpMatch? match = mediaMatch;
      if (match == null) {
        match = cropBoxPattern.firstMatch(pdfString);
      }

      if (match != null) {
        final double llx = double.tryParse(match.group(1) ?? '') ?? 0.0;
        final double lly = double.tryParse(match.group(2) ?? '') ?? 0.0;
        final double urx = double.tryParse(match.group(3) ?? '') ?? 0.0;
        final double ury = double.tryParse(match.group(4) ?? '') ?? 0.0;
        final double width = (urx - llx).abs();
        final double height = (ury - lly).abs();
        if (width > 0 && height > 0) {
          return Size(width, height);
        }
      }

      return null;
    } catch (e) {
      print('Error extracting PDF page size: $e');
      return null;
    }
  }

  // Get page count from DOCX file
  Future<int> _getPageCountDOCX(List<int> fileBytes) async {
    try {
      if (fileBytes.isEmpty) return 1;

      // DOCX is a ZIP file, extract the document.xml to count pages
      final archive = ZipDecoder().decodeBytes(fileBytes);

      // Find and read document.xml
      for (var file in archive) {
        if (file.name == 'word/document.xml' && file.content is List<int>) {
          try {
            final xmlContent = String.fromCharCodes(file.content as List<int>);
            final document = xml.XmlDocument.parse(xmlContent);

            // First, try to find page breaks (w:br with w:type="page")
            final pageBreaks = xmlContent.contains('w:type="page"')
                ? xmlContent.split('w:type="page"').length - 1
                : 0;

            if (pageBreaks > 0) {
              int pageCount = pageBreaks + 1; // Add 1 for the last page
              print('DOCX page count (from page breaks): $pageCount');
              return pageCount;
            }

            // Alternative: count paragraphs
            final paragraphs = document.findAllElements('w:p');
            int paragraphCount = paragraphs.length;

            // More conservative estimation: 55-60 paragraphs per page for typical documents
            // Most documents have around 250-300 words per page, which is roughly 50-60 short paragraphs
            int estimationDivisor = 60;
            if (xmlContent.contains('w:tbl')) {
              // If document has tables, they take more space but fewer paragraphs
              estimationDivisor = 50;
            }

            int pageCount = (paragraphCount / estimationDivisor).ceil();
            print(
              'DOCX page count (from paragraphs): $pageCount (paragraphs: $paragraphCount)',
            );
            return pageCount > 0 ? pageCount : 1;
          } catch (e) {
            print('Error parsing DOCX XML: $e');
            return 1;
          }
        }
      }

      return 1;
    } catch (e) {
      print('Error reading DOCX: $e');
      return 1;
    }
  }

  // Try to read page size (w/h) from DOCX document.xml (values are in twentieths of a point)
  // Returns Size in PDF points (1 pt = 1/72 inch) or null if not found.
  Size? _getPageSizeFromDocxBytes(List<int> fileBytes) {
    try {
      if (fileBytes.isEmpty) return null;
      final archive = ZipDecoder().decodeBytes(fileBytes);
      for (var file in archive) {
        if (file.name == 'word/document.xml' && file.content is List<int>) {
          final xmlContent = String.fromCharCodes(file.content as List<int>);
          // Look for <w:pgSz w:w="NNNN" w:h="MMMM"/>
          final reg = RegExp(
            r'<w:pgSz[^>]*w:w="([0-9]+)"[^>]*w:h="([0-9]+)"',
            caseSensitive: false,
          );
          final m = reg.firstMatch(xmlContent);
          if (m != null) {
            final wTwips =
                int.tryParse(m.group(1) ?? '0') ?? 0; // twentieths of a point
            final hTwips = int.tryParse(m.group(2) ?? '0') ?? 0;
            if (wTwips > 0 && hTwips > 0) {
              // Convert twentieths of a point to points: pts = twips / 20
              final double wPts = wTwips / 20.0;
              final double hPts = hTwips / 20.0;
              return Size(wPts, hPts);
            }
          }
        }
      }
      return null;
    } catch (e) {
      print('Error extracting DOCX page size: $e');
      return null;
    }
  }

  // Detect paper size name from a Size in PDF points (72 pts = 1 inch)
  String? _detectPaperSizeFromPoints(Size pts) {
    const double ptsPerInch = 72.0;
    final double wIn = pts.width / ptsPerInch;
    final double hIn = pts.height / ptsPerInch;
    final double w = wIn < hIn ? wIn : hIn;
    final double h = hIn > wIn ? hIn : wIn;

    final Map<String, Size> standardsInches = {
      'A4': const Size(8.27, 11.69),
      'Short Bond Paper': const Size(8.5, 11.0),
      'Long Bond Paper': const Size(8.5, 13.0),
    };

    String? bestKey;
    double bestError = double.infinity;
    standardsInches.forEach((key, sz) {
      final double sw = sz.width < sz.height ? sz.width : sz.height;
      final double sh = sz.height > sz.width ? sz.height : sz.width;
      final double err = (sw - w).abs() + (sh - h).abs();
      if (err < bestError) {
        bestError = err;
        bestKey = key;
      }
    });
    if (bestError != double.infinity && bestError <= 0.8) {
      return bestKey;
    }
    return null;
  }

  // Compute printing cost using same rates as PrintingSettingsPage
  double _computePrintingCost({
    required String paperSize,
    required bool isColor,
    required int pageCount,
    required int copies,
  }) {
    final Map<String, int> baseCosts = {
      'A4': 1,
      'Short Bond Paper': 2,
      'Long Bond Paper': 3,
    };
    const int colorExtra = 3;
    final perCopy = (baseCosts[paperSize] ?? 0) + (isColor ? colorExtra : 0);
    return perCopy * pageCount * copies.toDouble();
  }

  // Get page count from DOC file
  Future<int> _getPageCountDOC(List<int> fileBytes) async {
    try {
      if (fileBytes.isEmpty) return 1;

      // DOC files are binary; use improved heuristics
      // Try to find page break indicators in the binary data
      int pageBreakCount = 0;

      // Common page break signatures in DOC format
      // 0x0C is the form feed character often used for page breaks
      for (int i = 0; i < fileBytes.length; i++) {
        if (fileBytes[i] == 0x0C) {
          pageBreakCount++;
        }
      }

      if (pageBreakCount > 0) {
        int pageCount = pageBreakCount + 1; // +1 for the first page
        print('DOC page count (from page breaks): $pageCount');
        return pageCount;
      }

      // Fallback: use more conservative file size heuristic
      // Typical DOC file has 5000-6000 bytes per page
      final estimatedPages = (fileBytes.length / 5500).ceil();
      print('DOC page count (estimated from size): $estimatedPages');
      return estimatedPages > 0 ? estimatedPages : 1;
    } catch (e) {
      print('Error reading DOC: $e');
      return 1;
    }
  }
}
