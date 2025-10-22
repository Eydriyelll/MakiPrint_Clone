import 'package:flutter/material.dart';

/// PrintingSettingsPage
/// - No main() here (app entry is in main.dart)
/// - Returns the chosen settings to the caller via Navigator.pop(context, resultMap)
class PrintingSettingsPage extends StatefulWidget {
  final int initialCopies;
  final String initialPaperSize;
  final bool initialIsColor;

  const PrintingSettingsPage({
    super.key,
    this.initialCopies = 1,
    this.initialPaperSize = 'A4',
    this.initialIsColor = true,
  });

  @override
  State<PrintingSettingsPage> createState() => _PrintingSettingsPageState();
}

class _PrintingSettingsPageState extends State<PrintingSettingsPage> {
  // State variables to hold the settings
  late int _copies;
  late String _paperSize;
  late bool _isColor;

  // Options for the paper size dropdown (labels must match cost map keys)
  final List<String> _paperSizes = ['A4', 'Letter', 'Legal', 'A5'];

  // Base costs per paper size (per copy) — updated to match your requested values
  final Map<String, int> _baseCosts = {
    'A4': 1,
    'Letter': 2,
    'Legal': 3,
    'A5': 4,
  };

  // Cost additions
  final int _colorExtra = 3; // extra cost if color

  @override
  void initState() {
    super.initState();
    _copies = widget.initialCopies;
    _paperSize = widget.initialPaperSize;
    _isColor = widget.initialIsColor;
  }

  // Computed costs
  int get _perCopyCost => (_baseCosts[_paperSize] ?? 0) + (_isColor ? _colorExtra : 0);
  int get _totalCost => _perCopyCost * _copies;

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
                      if (_copies > 1) _copies--;
                    });
                  },
                ),
                SizedBox(
                  width: 60,
                  child: Center(
                    child: Text(
                      '$_copies',
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle),
                  onPressed: () {
                    setState(() {
                      _copies++;
                    });
                  },
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    initialValue: '$_copies',
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Set copies',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    onChanged: (val) {
                      final v = int.tryParse(val);
                      if (v != null && v > 0) {
                        setState(() => _copies = v);
                      }
                    },
                  ),
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
                contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
              ),
              value: _paperSize,
              items: _paperSizes.map((String size) {
                return DropdownMenuItem<String>(
                  value: size,
                  child: Text(size),
                );
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
              subtitle: Text(_isColor ? 'Color Printing' : 'Black and White (BnW)'),
              contentPadding: EdgeInsets.zero,
            ),

            const Divider(height: 24),

            Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Cost per copy', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        Text('PhP $_perCopyCost', style: const TextStyle(fontSize: 18)),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text('Total cost', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        Text('PhP $_totalCost', style: const TextStyle(fontSize: 18)),
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
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
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