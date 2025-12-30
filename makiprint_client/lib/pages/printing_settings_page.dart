import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// PrintingSettingsPage
/// - No main() here (app entry is in main.dart)
/// - Returns the chosen settings to the caller via Navigator.pop(context, resultMap)
class PrintingSettingsPage extends StatefulWidget {
  final int initialCopies;
  final String initialPaperSize;
  final bool initialIsColor;
  final int pageCount;
  // Optional: first page size in PDF points (72 points = 1 inch).
  // If provided, the page dimensions are used to auto-detect paper size.
  final Size? initialPageSizePts;

  const PrintingSettingsPage({
    super.key,
    this.initialCopies = 1,
    this.initialPaperSize = 'A4',
    this.initialIsColor = true,
    this.pageCount = 1,
    this.initialPageSizePts,
  });

  @override
  State<PrintingSettingsPage> createState() => _PrintingSettingsPageState();
}

class _PrintingSettingsPageState extends State<PrintingSettingsPage> {
  // State variables to hold the settings
  late int _copies;
  late String _paperSize;
  late bool _isColor;

  // Controller & focus for copies input
  late final TextEditingController _copiesController;
  late final FocusNode _copiesFocusNode;

  // Options for the paper size dropdown (labels must match cost map keys)
  final List<String> _paperSizes = [
    'A4',
    'Short Bond Paper',
    'Long Bond Paper',
  ];

  // Base costs per paper size (per copy) — updated to match your requested values
  final Map<String, int> _baseCosts = {
    'A4': 1,
    'Short Bond Paper': 2,
    'Long Bond Paper': 3,
  };

  // Cost additions
  final int _colorExtra = 3; // extra cost if color

  @override
  void initState() {
    super.initState();
    _copies = widget.initialCopies;
    _paperSize = widget.initialPaperSize;
    _isColor = widget.initialIsColor;

    _copiesController = TextEditingController(text: _copies.toString());
    _copiesFocusNode = FocusNode();

    _copiesFocusNode.addListener(() {
      if (!_copiesFocusNode.hasFocus) {
        // When focus is lost, ensure a valid value (reset to 1 if empty/invalid)
        final text = _copiesController.text;
        final parsed = int.tryParse(text);
        if (parsed == null || parsed < 1) {
          _copies = 1;
          _copiesController.text = '1';
          _copiesController.selection = TextSelection.collapsed(offset: 1);
        } else {
          // keep parsed valid value
          _copies = parsed;
        }
        setState(() {});
      }
    });

    // If caller provided the first page dimensions, detect paper size immediately
    if (widget.initialPageSizePts != null) {
      final detected = _detectPaperSizeFromPoints(widget.initialPageSizePts!);
      if (detected != null) {
        _paperSize = detected;
      }
    }
  }

  @override
  void didUpdateWidget(covariant PrintingSettingsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If page count or first-page size changed in the parent, update displayed values
    if (oldWidget.pageCount != widget.pageCount) {
      setState(() {
        // just trigger rebuild to refresh derived calculations
      });
    }

    if (oldWidget.initialPageSizePts != widget.initialPageSizePts &&
        widget.initialPageSizePts != null) {
      final detected = _detectPaperSizeFromPoints(widget.initialPageSizePts!);
      if (detected != null && detected != _paperSize) {
        setState(() {
          _paperSize = detected;
        });
      }
    }
  }

  @override
  void dispose() {
    _copiesController.dispose();
    _copiesFocusNode.dispose();
    super.dispose();
  }

  // Computed costs
  int get _perCopyCost =>
      (_baseCosts[_paperSize] ?? 0) + (_isColor ? _colorExtra : 0);
  int get _totalCost => _perCopyCost * _copies * widget.pageCount;

  // Attempts to detect a paper size name from a page Size in points (72 pts = 1 inch).
  // Returns the matching key from _paperSizes/_baseCosts or null if no good match.
  String? _detectPaperSizeFromPoints(Size pts) {
    const double ptsPerInch = 72.0;
    final double wIn = pts.width / ptsPerInch;
    final double hIn = pts.height / ptsPerInch;

    // Normalize so width <= height (portrait)
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

    // Accept match only if error is reasonably small (0.8 inch total)
    if (bestError != double.infinity && bestError <= 0.8) {
      return bestKey;
    }
    return null;
  }

  // Build a result map to return to the caller
  Map<String, Object> get _resultMap => {
    'copies': _copies,
    'paperSize': _paperSize,
    'isColor': _isColor,
    'perCopyCost': _perCopyCost,
    'totalCost': _totalCost,
  };

  // pops and returns current settings to caller
  void _returnToCaller() {
    Navigator.of(context).pop(_resultMap);
  }

  // Optional: confirm-and-return (used by Print button)
  void _confirmAndReturn() {
    // You can add validation or submit logic here before returning
    _returnToCaller();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Back button now returns the current selection to the caller
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Back',
          onPressed: _returnToCaller,
        ),
        title: const Text('Printer Settings'),
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              'Number of Copies',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: <Widget>[
                IconButton(
                  icon: const Icon(Icons.remove_circle),
                  onPressed: () {
                    setState(() {
                      if (_copies > 1) {
                        _copies--;
                        _copiesController.text = _copies.toString();
                        _copiesController.selection = TextSelection.collapsed(
                          offset: _copiesController.text.length,
                        );
                      }
                    });
                  },
                ),
                Expanded(
                  child: TextFormField(
                    controller: _copiesController,
                    focusNode: _copiesFocusNode,
                    keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.digitsOnly, // blocks letters
                    ],
                    textAlign: TextAlign.center,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 8,
                      ),
                    ),
                    onChanged: (value) {
                      if (value.isEmpty) {
                        // allow empty while focused; do not change _copies until focus lost
                        return;
                      }
                      final parsed = int.tryParse(value);
                      if (parsed != null && parsed > 0) {
                        setState(() {
                          _copies = parsed;
                        });
                      } else {
                        // If non-numeric somehow gets through, reset immediately
                        _copies = 1;
                        _copiesController.text = '1';
                        _copiesController.selection = TextSelection.collapsed(
                          offset: 1,
                        );
                        setState(() {});
                      }
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle),
                  onPressed: () {
                    setState(() {
                      _copies++;
                      _copiesController.text = _copies.toString();
                      _copiesController.selection = TextSelection.collapsed(
                        offset: _copiesController.text.length,
                      );
                    });
                  },
                ),
              ],
            ),

            const Divider(height: 40),

            const Text(
              'Paper Size',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 12,
                ),
              ),
              initialValue: _paperSize,
              items: _paperSizes.map((String size) {
                return DropdownMenuItem<String>(value: size, child: Text(size));
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue == null) return;
                setState(() {
                  _paperSize = newValue;
                });
              },
            ),

            const Divider(height: 40),

            const Text(
              'Print Mode',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ListTile(
              title: const Text('Color'),
              trailing: Switch(
                value: _isColor,
                onChanged: (bool value) {
                  setState(() {
                    _isColor = value;
                  });
                },
              ),
              subtitle: Text(
                _isColor ? 'Color Printing' : 'Black and White (BnW)',
              ),
              contentPadding: EdgeInsets.zero,
            ),

            const Divider(height: 24),

            Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Total Pages Display
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Pages',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '${widget.pageCount}',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Cost Breakdown
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Cost Calculation:',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[700],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'PhP $_perCopyCost/page × ${widget.pageCount} pages × $_copies copies = PhP $_totalCost',
                            style: const TextStyle(fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Cost per unit breakdown
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Cost per page',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'PhP $_perCopyCost',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text(
                              'Pages × Copies',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${widget.pageCount} × $_copies',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text(
                              'Total cost',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'PhP $_totalCost',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const Divider(height: 40),

            Center(
              child: ElevatedButton.icon(
                onPressed: _confirmAndReturn,
                icon: const Icon(Icons.print),
                label: const Text('Confirm & Return'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 15,
                  ),
                  textStyle: const TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
