import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScanQRPage extends StatefulWidget {
  const ScanQRPage({Key? key}) : super(key: key);

  @override
  State<ScanQRPage> createState() => _ScanQRPageState();
}

class _ScanQRPageState extends State<ScanQRPage> {
  String? scannedData;
  double userBalance = 0.0; // simulated balance
  final double printCost = 10.0;
  String balanceMessage = "";
  bool isProcessing = false;

  void _handleScan(String? code) {
    if (isProcessing || code == null || code.isEmpty) return;

    setState(() {
      isProcessing = true;
      scannedData = code;
    });

    _checkBalance();
  }

  void _checkBalance() async {
    await Future.delayed(const Duration(milliseconds: 700));

    if (userBalance >= printCost) {
      setState(() {
        userBalance -= printCost;
        balanceMessage =
            "✅ Sufficient balance. Deducting ₱$printCost and proceeding to print...";
      });
    } else {
      setState(() {
        balanceMessage =
            "❌ Insufficient balance. Please top-up before printing.";
      });
    }

    setState(() => isProcessing = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f5f5),
      appBar: AppBar(
        title: const Text("Scan QR Code"),
        centerTitle: true,
        backgroundColor: const Color(0xffb07d62),
      ),
      body: Column(
        children: [
          // Camera area
          Expanded(
            flex: 6,
            child: Container(
              color: Colors.black,
              child: MobileScanner(
                onDetect: (capture) {
                  final barcode = capture.barcodes.first;
                  _handleScan(barcode.rawValue);
                },
              ),
            ),
          ),

          // Info & action area
          Expanded(
            flex: 4,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, -4),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    scannedData != null
                        ? "Scanned QR: $scannedData"
                        : "No QR scanned yet",
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 20),

                  Text(
                    balanceMessage.isEmpty
                        ? "Printing cost: ₱$printCost · Your balance: ₱${userBalance.toStringAsFixed(2)}"
                        : balanceMessage,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: balanceMessage.contains("Insufficient")
                          ? Colors.red
                          : Colors.green,
                    ),
                  ),
                  const SizedBox(height: 30),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        icon: const Icon(Icons.refresh),
                        label: const Text("Scan Again"),
                        onPressed: () {
                          setState(() {
                            scannedData = null;
                            balanceMessage = "";
                            isProcessing = false;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xffc38e70),
                          foregroundColor: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 14),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.add),
                        label: const Text("Top-up ₱20"),
                        onPressed: () {
                          setState(() {
                            userBalance += 20.0;
                            balanceMessage =
                                "💰 Top-up successful. New balance: ₱${userBalance.toStringAsFixed(2)}";
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff74a12e),
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
