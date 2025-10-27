import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:url_launcher/url_launcher.dart';

class ScanQRPage extends StatefulWidget {
  const ScanQRPage({super.key});

  @override
  State<ScanQRPage> createState() => _ScanQRPageState();
}

class _ScanQRPageState extends State<ScanQRPage> {
  String? _lastScanned;
  final List<String> _scanHistory = [];
  bool _isProcessing = false;

  void _onDetect(BarcodeCapture capture) async {
    if (_isProcessing) return;
    _isProcessing = true;

    final barcodes = capture.barcodes;
    if (barcodes.isNotEmpty) {
      final value = barcodes.first.rawValue ?? 'Unknown QR';

      setState(() {
        _lastScanned = value;
        if (!_scanHistory.contains(value)) {
          _scanHistory.insert(0, value);
          if (_scanHistory.length > 10) _scanHistory.removeLast();
        }
      });

      // Try to launch if it's a URL
      if (Uri.tryParse(value)?.hasAbsolutePath ?? false) {
        final uri = Uri.parse(value);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          _showDetectedAlert(value);
        }
      } else {
        _showDetectedAlert(value);
      }
    }

    await Future.delayed(const Duration(seconds: 2));
    _isProcessing = false;
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan MakiPrint QR'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          // ===== HOW TO SCAN SECTION =====
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    Icon(Icons.smartphone, size: 36, color: primaryColor),
                    const SizedBox(height: 8),
                    const Text('Hold your phone steady'),
                  ],
                ),
                Column(
                  children: [
                    Icon(Icons.qr_code_scanner, size: 36, color: primaryColor),
                    const SizedBox(height: 8),
                    const Text('Align QR inside frame'),
                  ],
                ),
              ],
            ),
          ),

          // ===== QR SCANNER SECTION =====
          Expanded(
            flex: 3,
            child: Stack(
              alignment: Alignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: MobileScanner(
                      fit: BoxFit.cover,
                      onDetect: _onDetect,
                    ),
                  ),
                ),
                // Animated scanning line
                Positioned.fill(
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: 1),
                    duration: const Duration(seconds: 2),
                    curve: Curves.easeInOut,
                    builder: (context, value, child) {
                      return CustomPaint(
                        painter: _ScannerOverlayPainter(value),
                      );
                    },
                    onEnd: () => setState(() {}),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // ===== SCAN HISTORY SECTION =====
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Scan History',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: _scanHistory.isEmpty
                            ? const Center(
                                child: Text(
                                  'No scans yet — scan a QR to get started!',
                                  style: TextStyle(color: Colors.grey),
                                  textAlign: TextAlign.center,
                                ),
                              )
                            : ListView.builder(
                                itemCount: _scanHistory.length,
                                itemBuilder: (context, index) {
                                  final item = _scanHistory[index];
                                  return ListTile(
                                    leading: const Icon(Icons.history),
                                    title: Text(
                                      item,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    onTap: () async {
                                      final uri = Uri.tryParse(item);
                                      if (uri != null &&
                                          await canLaunchUrl(uri)) {
                                        await launchUrl(
                                          uri,
                                          mode: LaunchMode.externalApplication,
                                        );
                                      }
                                    },
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDetectedAlert(String value) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('QR Code Detected'),
        content: Text(value),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

// ===== Overlay Painter for Scan Animation =====
class _ScannerOverlayPainter extends CustomPainter {
  final double animationValue;
  _ScannerOverlayPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.redAccent.withOpacity(0.8)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final lineY = size.height * animationValue;
    canvas.drawLine(Offset(0, lineY), Offset(size.width, lineY), paint);
  }

  @override
  bool shouldRepaint(covariant _ScannerOverlayPainter oldDelegate) =>
      oldDelegate.animationValue != animationValue;
}
