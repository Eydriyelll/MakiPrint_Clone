import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_web_bluetooth/flutter_web_bluetooth.dart';

class ScanQRPage extends StatefulWidget {
  const ScanQRPage({super.key});

  @override
  State<ScanQRPage> createState() => _ScanQRPageState();
}

class _ScanQRPageState extends State<ScanQRPage>
    with SingleTickerProviderStateMixin {
  final List<String> _scanHistory = [];
  bool _isProcessing = false;
  String? _lastScannedPrinter;
  final MobileScannerController _scannerController = MobileScannerController();
  late AnimationController _animationController;
  final String _makiServiceUuid = "0000180d-0000-1000-8000-00805f9b34fb";

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _scannerController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) async {
    if (_isProcessing) return;
    _isProcessing = true;

    final barcodes = capture.barcodes;
    if (barcodes.isNotEmpty) {
      final value = barcodes.first.rawValue ?? 'Unknown QR';

      setState(() {
        _lastScannedPrinter = value;
        if (!_scanHistory.contains(value)) {
          _scanHistory.insert(0, value);
          if (_scanHistory.length > 10) _scanHistory.removeLast();
        }
      });

      if (!kIsWeb) {
        await _handleNativeBluetooth(value);
      }

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

  Future<void> _handleWebBluetooth() async {
    if (!FlutterWebBluetooth.instance.isBluetoothApiSupported) {
      _showDetectedAlert("Browser Bluetooth not supported. Please use Chrome.");
      return;
    }
    try {
      final options = RequestOptionsBuilder.acceptAllDevices(
        optionalServices: [_makiServiceUuid],
      );
      final device = await FlutterWebBluetooth.instance.requestDevice(options);
      await device.connect();
      _showDetectedAlert("Connected to MakiPrint via Web!");
    } catch (e) {
      _showDetectedAlert("Connection failed: $e");
    }
  }

  Future<void> _handleNativeBluetooth(String name) async {
    if (await FlutterBluePlus.isSupported) {
      await FlutterBluePlus.turnOn();
      FlutterBluePlus.startScan(timeout: const Duration(seconds: 5));
      FlutterBluePlus.scanResults.listen((results) {
        for (var r in results) {
          if (r.device.platformName == name) {
            r.device.connect();
            _showDetectedAlert("Connected to $name");
            FlutterBluePlus.stopScan();
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
          const Spacer(flex: 1),

          Expanded(
            flex: 6,
            child: Center(
              child: AspectRatio(
                aspectRatio: 1,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: MobileScanner(
                          fit: BoxFit.cover,
                          controller: _scannerController,
                          onDetect: _onDetect,
                        ),
                      ),
                      // Animated scanning line fixed within QR bounds
                      AnimatedBuilder(
                        animation: _animationController,
                        builder: (context, child) {
                          return LayoutBuilder(
                            builder: (context, constraints) {
                              return CustomPaint(
                                size: Size(
                                  constraints.maxWidth,
                                  constraints.maxHeight,
                                ),
                                painter: _ScannerOverlayPainter(
                                  _animationController.value,
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),
          const Text(
            "Align QR code within the frame to scan",
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),

          const SizedBox(height: 24),

          if (_lastScannedPrinter != null)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton.icon(
                onPressed: kIsWeb
                    ? _handleWebBluetooth
                    : () => _handleNativeBluetooth(_lastScannedPrinter!),
                icon: const Icon(Icons.bluetooth),
                label: Text("Connect to $_lastScannedPrinter"),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
            ),

          const Spacer(flex: 2),
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
  bool shouldRepaint(covariant _ScannerOverlayPainter oldDelegate) => true;
}
