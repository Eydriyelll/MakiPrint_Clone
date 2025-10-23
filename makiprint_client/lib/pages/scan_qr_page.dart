import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScanQRPage extends StatefulWidget {
  const ScanQRPage({super.key});

  @override
  State<ScanQRPage> createState() => _ScanQRPageState();
}

class _ScanQRPageState extends State<ScanQRPage> {
  late MobileScannerController cameraController;
  bool _isCameraInitialized = false;
  bool _hasError = false;
  String _errorMessage = '';
  String? _lastScanned; // For "Last Scanned" section

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      cameraController = MobileScannerController(
        facing: CameraFacing.back,
        formats: [BarcodeFormat.qrCode],
        autoStart: true,
        torchEnabled: false,
      );

      await cameraController.start();

      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
          _hasError = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = kIsWeb
              ? 'Camera access denied. Please allow camera access in your browser settings.'
              : 'Failed to initialize camera. Please check camera permissions.';
        });
      }
    }
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  void _retryCamera() {
    setState(() {
      _hasError = false;
      _errorMessage = '';
      _isCameraInitialized = false;
    });
    _initializeCamera();
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
        actions: [
          if (!kIsWeb && _isCameraInitialized)
            IconButton(
              icon: const Icon(Icons.flash_on),
              onPressed: () => cameraController.toggleTorch(),
              tooltip: 'Toggle Flash',
            ),
          if (_isCameraInitialized)
            IconButton(
              icon: const Icon(Icons.cameraswitch),
              onPressed: () => cameraController.switchCamera(),
              tooltip: 'Switch Camera',
            ),
        ],
      ),
      body: _buildScannerBody(primaryColor),
    );
  }

  // Main body containing How to Scan, Last Scanned, Camera/Error, Footer
  Widget _buildScannerBody(Color primaryColor) {
    return Column(
      children: [
        // ====== HOW TO SCAN SECTION ======
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  Icon(Icons.smartphone, size: 36, color: primaryColor),
                  const SizedBox(height: 8),
                  const Text(
                    'Hold your phone steady',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              Column(
                children: [
                  Icon(Icons.qr_code_scanner, size: 36, color: primaryColor),
                  const SizedBox(height: 8),
                  const Text(
                    'Align QR inside frame',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ],
          ),
        ),

        // ====== LAST SCANNED SECTION ======
        if (_lastScanned != null)
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Card(
              color: primaryColor.withOpacity(0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    const Icon(Icons.history, color: Colors.black54),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Last scanned: $_lastScanned',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

        // ====== CAMERA / ERROR AREA ======
        Expanded(
          child: _hasError
              ? _buildCameraErrorWidget(primaryColor)
              : _isCameraInitialized
              ? MobileScanner(
                  controller: cameraController,
                  onDetect: (capture) {
                    final List<Barcode> barcodes = capture.barcodes;
                    for (final barcode in barcodes) {
                      if (!mounted || barcode.rawValue == null) continue;

                      // Save last scanned value
                      setState(() {
                        _lastScanned = barcode.rawValue;
                      });

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'QR Code detected: ${barcode.rawValue}',
                          ),
                          duration: const Duration(seconds: 2),
                          backgroundColor: primaryColor,
                        ),
                      );

                      Navigator.of(context).pop(barcode.rawValue);
                      break;
                    }
                  },
                )
              : Center(child: CircularProgressIndicator(color: primaryColor)),
        ),

        // ====== FOOTER INSTRUCTIONS ======
        Container(
          color: Theme.of(context).colorScheme.surface,
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(
                'Position the QR code within the frame to scan',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: primaryColor,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                kIsWeb
                    ? 'Make sure your browser has camera permissions enabled'
                    : 'Ensure good lighting for better scanning',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Camera error widget only replaces scanner area
  Widget _buildCameraErrorWidget(Color primaryColor) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text('Camera Error', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              _errorMessage,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _retryCamera,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
