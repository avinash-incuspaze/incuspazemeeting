// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:mobile_scanner/mobile_scanner.dart';
// import '../../app/controllers/auth_controller.dart';
// import '../../app/data/services/api_service.dart';
// import '../../widgets/check_in_response_dialog.dart';
//
// class QRScannerTab extends StatefulWidget {
//   final String meetingRoomId;
//
//   const QRScannerTab({
//     super.key,
//     required this.meetingRoomId,
//   });
//
//   @override
//   State<QRScannerTab> createState() => _QRScannerTabState();
// }
//
// class _QRScannerTabState extends State<QRScannerTab> {
//   MobileScannerController? _scannerController;
//   bool _isScanning = false;
//   bool _isProcessing = false;
//   final TextEditingController _manualCodeController = TextEditingController();
//   final ApiService _apiService = Get.find<ApiService>();
//
//   @override
//   void dispose() {
//     _stopScanning();
//     _manualCodeController.dispose();
//     super.dispose();
//   }
//
//   Future<void> _startScanning() async {
//     try {
//       setState(() {
//         _isScanning = true;
//         _scannerController = MobileScannerController(
//           facing: CameraFacing.front,
//           detectionSpeed: DetectionSpeed.noDuplicates,
//         );
//       });
//       // Start the scanner
//       await _scannerController?.start();
//     } catch (e) {
//       setState(() {
//         _isScanning = false;
//         _scannerController?.dispose();
//         _scannerController = null;
//       });
//
//       String errorMessage = 'Failed to start camera';
//       if (e.toString().contains('MissingPluginException')) {
//         errorMessage = 'Camera plugin not available. Please stop the app and do a FULL REBUILD (not hot restart).';
//       } else {
//         errorMessage = 'Failed to start camera: ${e.toString()}';
//       }
//
//       Get.snackbar(
//         'Camera Error',
//         errorMessage,
//         snackPosition: SnackPosition.BOTTOM,
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//         duration: const Duration(seconds: 5),
//       );
//     }
//   }
//
//   Future<void> _stopScanning() async {
//     try {
//       await _scannerController?.stop();
//     } catch (e) {
//       // Ignore errors when stopping
//     } finally {
//       setState(() {
//         _isScanning = false;
//         _scannerController?.dispose();
//         _scannerController = null;
//       });
//     }
//   }
//
//   Future<void> _handleQRCode(String code) async {
//     if (_isProcessing) return; // Prevent multiple calls
//
//     _stopScanning();
//     setState(() {
//       _isProcessing = true;
//     });
//
//     try {
//       final authController = Get.find<AuthController>();
//       final token = authController.token.value;
//
//       if (token.isEmpty) {
//         Get.snackbar(
//           'Error',
//           'Please login first',
//           snackPosition: SnackPosition.BOTTOM,
//           backgroundColor: Colors.red,
//           colorText: Colors.white,
//           duration: const Duration(seconds: 3),
//         );
//         setState(() {
//           _isProcessing = false;
//         });
//         return;
//       }
//
//       // Call check-in API
//       final response = await _apiService.checkIn(
//         token: token,
//         qrKey: code,
//         meetingRoomId: widget.meetingRoomId,
//       );
//
//       setState(() {
//         _isProcessing = false;
//       });
//
//       // Show attractive popup with response
//       if (mounted) {
//         CheckInResponseDialog.show(
//           context,
//           response.status,
//           response.message,
//         );
//       }
//     } catch (e) {
//       setState(() {
//         _isProcessing = false;
//       });
//
//       // Show error in popup
//       if (mounted) {
//         CheckInResponseDialog.show(
//           context,
//           false,
//           'Error: ${e.toString().replaceAll('Exception: ', '')}',
//         );
//       }
//     }
//   }
//
//   Future<void> _handleManualCode() async {
//     if (_isProcessing) return; // Prevent multiple calls
//
//     final code = _manualCodeController.text.trim();
//     if (code.isEmpty) {
//       Get.snackbar(
//         'Error',
//         'Please enter a code',
//         snackPosition: SnackPosition.BOTTOM,
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//         duration: const Duration(seconds: 2),
//       );
//       return;
//     }
//
//     setState(() {
//       _isProcessing = true;
//     });
//
//     _manualCodeController.clear();
//
//     try {
//       final authController = Get.find<AuthController>();
//       final token = authController.token.value;
//
//       if (token.isEmpty) {
//         Get.snackbar(
//           'Error',
//           'Please login first',
//           snackPosition: SnackPosition.BOTTOM,
//           backgroundColor: Colors.red,
//           colorText: Colors.white,
//           duration: const Duration(seconds: 3),
//         );
//         setState(() {
//           _isProcessing = false;
//         });
//         return;
//       }
//
//       // Call check-in API
//       final response = await _apiService.checkIn(
//         token: token,
//         qrKey: code,
//         meetingRoomId: widget.meetingRoomId,
//       );
//
//       setState(() {
//         _isProcessing = false;
//       });
//
//       // Show attractive popup with response
//       if (mounted) {
//         CheckInResponseDialog.show(
//           context,
//           response.status,
//           response.message,
//         );
//       }
//     } catch (e) {
//       setState(() {
//         _isProcessing = false;
//       });
//
//       // Show error in popup
//       if (mounted) {
//         CheckInResponseDialog.show(
//           context,
//           false,
//           'Error: ${e.toString().replaceAll('Exception: ', '')}',
//         );
//       }
//     }
//   }
//
//   Widget _buildScannerView() {
//     return LayoutBuilder(
//       builder: (context, constraints) {
//         // Rotate the camera view to show landscape orientation
//         // Rotate 90 degrees counter-clockwise to display camera in landscape (correct orientation)
//         return Transform.rotate(
//           angle: 1.5708, // 90 degrees in radians (π/2) for proper portrait to landscape rotation
//           child: SizedBox(
//             width: constraints.maxHeight,
//             height: constraints.maxWidth,
//             child: MobileScanner(
//               controller: _scannerController!,
//               onDetect: (capture) {
//                 if (_isProcessing) return; // Prevent multiple scans
//                 final List<Barcode> barcodes = capture.barcodes;
//                 for (final barcode in barcodes) {
//                   if (barcode.rawValue != null) {
//                     _handleQRCode(barcode.rawValue!);
//                     break;
//                   }
//                 }
//               },
//             ),
//           ),
//         );
//       },
//     );
//   }
//
//   Widget _buildScannerPlaceholder() {
//     return Container(
//       color: Colors.black,
//       child: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               Icons.qr_code_scanner,
//               size: 80,
//               color: Colors.white.withOpacity(0.5),
//             ),
//             const SizedBox(height: 24),
//             Text(
//               'Tap to Start Scanning',
//               style: TextStyle(
//                 fontSize: 18,
//                 color: Colors.white.withOpacity(0.7),
//               ),
//             ),
//             const SizedBox(height: 12),
//             Text(
//               'Use front camera to scan QR code',
//               style: TextStyle(
//                 fontSize: 14,
//                 color: Colors.white.withOpacity(0.5),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return SizedBox.expand(
//       child: Container(
//         decoration: const BoxDecoration(
//           color: Colors.black,
//         ),
//         child: Stack(
//           fit: StackFit.expand,
//           children: [
//                 // Camera View or Placeholder
//                 if (_isScanning && _scannerController != null)
//                   _buildScannerView()
//                 else
//                   _buildScannerPlaceholder(),
//                 Positioned(
//                   bottom: 40,
//                   left: 0,
//                   right: 0,
//                   child: Center(
//                     child: FloatingActionButton.extended(
//                       onPressed: _isProcessing
//                           ? null
//                           : (_isScanning ? _stopScanning : _startScanning),
//                       backgroundColor: _isScanning
//                           ? Colors.red
//                           : (_isProcessing
//                               ? Colors.grey
//                               : const Color(0xFFF37F20)),
//                       icon: Icon(_isScanning
//                           ? Icons.stop
//                           : (_isProcessing
//                               ? Icons.hourglass_empty
//                               : Icons.qr_code_scanner)),
//                       label: Text(_isScanning
//                           ? 'Stop Scanning'
//                           : (_isProcessing
//                               ? 'Processing...'
//                               : 'Start Scanning')),
//                     ),
//                   ),
//                 ),
//                 if (_isScanning)
//                   Positioned(
//                     top: 40,
//                     left: 20,
//                     child: Container(
//                       padding: const EdgeInsets.all(12),
//                       decoration: BoxDecoration(
//                         color: Colors.black.withOpacity(0.6),
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       child: const Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             'Scanning QR Code',
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontSize: 16,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                           SizedBox(height: 4),
//                           Text(
//                             'Point camera at QR code',
//                             style: TextStyle(
//                               color: Colors.white70,
//                               fontSize: 12,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           );
//   }
// }
//




import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../app/controllers/auth_controller.dart';
import '../../app/data/services/api_service.dart';
import '../../widgets/check_in_response_dialog.dart';

class QRScannerTab extends StatefulWidget {
  final String meetingRoomId;

  const QRScannerTab({
    super.key,
    required this.meetingRoomId,
  });

  @override
  State<QRScannerTab> createState() => _QRScannerTabState();
}

class _QRScannerTabState extends State<QRScannerTab>
    with SingleTickerProviderStateMixin {
  MobileScannerController? _scannerController;
  bool _isScanning = false;
  bool _isProcessing = false;

  final TextEditingController _manualCodeController =
  TextEditingController();

  final ApiService _apiService = Get.find<ApiService>();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Stop scanner when switching tab
    _tabController.addListener(() {
      if (_tabController.index != 0 && _isScanning) {
        _stopScanning();
      }
    });
  }

  @override
  void dispose() {
    _stopScanning();
    _manualCodeController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  // ================= SCANNER CONTROL =================

  Future<void> _startScanning() async {
    try {
      setState(() {
        _isScanning = true;
        _scannerController = MobileScannerController(
          facing: CameraFacing.front,
          detectionSpeed: DetectionSpeed.noDuplicates,
        );
      });

      await _scannerController?.start();
    } catch (e) {
      setState(() {
        _isScanning = false;
        _scannerController?.dispose();
        _scannerController = null;
      });

      Get.snackbar(
        'Camera Error',
        'Failed to start camera',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _stopScanning() async {
    try {
      await _scannerController?.stop();
    } catch (_) {}

    setState(() {
      _isScanning = false;
      _scannerController?.dispose();
      _scannerController = null;
    });
  }

  // ================= API HANDLER =================

  // Future<void> _handleQRCode(String code) async {
  Future<void> _handleQRCode(String code, {bool isManual = false}) async {

    if (_isProcessing) return;

    await _stopScanning();
    setState(() => _isProcessing = true);

    try {
      final authController = Get.find<AuthController>();
      final token = authController.token.value;

      if (token.isEmpty) {
        Get.snackbar(
          'Error',
          'Please login first',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        setState(() => _isProcessing = false);
        return;
      }

      // 🔹 Print debug info
      print('handleQRCode called: code=$code, isManual=$isManual');
      print('Token: $token');
      print('MeetingRoomId: ${widget.meetingRoomId}');

      final response = isManual
          ? await _apiService.checkIn(
        token: token,
        accessCode: code,
        meetingRoomId: widget.meetingRoomId,
      )
          : await _apiService.checkIn(
        token: token,
        qrKey: code,
        meetingRoomId: widget.meetingRoomId,
      );
      // final response = await _apiService.checkIn(
      //   token: token,
      //   qrKey: code,
      //   meetingRoomId: widget.meetingRoomId,
      // );

      setState(() => _isProcessing = false);

      if (mounted) {
        CheckInResponseDialog.show(
          context,
          response.status,
          response.message,
        );
      }
      // 🔹 Print final payload for debug
      print('Final payload sent to API: '
          '{${isManual ? "access_code" : "qr_key"}: $code, meetingRoomId: ${widget.meetingRoomId}, token: $token}');
    } catch (e) {
      setState(() => _isProcessing = false);

      if (mounted) {
        CheckInResponseDialog.show(
          context,
          false,
          'Error: ${e.toString().replaceAll('Exception: ', '')}',
        );
      }
    }
  }

  Future<void> _handleManualCode() async {
    if (_isProcessing) return;

    final code = _manualCodeController.text.trim();

    if (code.isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter a code',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    _manualCodeController.clear();
    // await _handleQRCode(code);
    await _handleQRCode(code, isManual: true); // just for printing/debug

  }

  // ================= UI BUILDERS =================

  Widget _buildScannerView() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Transform.rotate(
          angle: 1.5708,
          child: SizedBox(
            width: constraints.maxHeight,
            height: constraints.maxWidth,
            child: MobileScanner(
              controller: _scannerController!,
              onDetect: (capture) {
                if (_isProcessing) return;

                for (final barcode in capture.barcodes) {
                  if (barcode.rawValue != null) {
                    _handleQRCode(barcode.rawValue!);
                    break;
                  }
                }
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildScannerPlaceholder() {
    return Container(
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.qr_code_scanner,
              size: 80,
              color: Colors.white.withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            Text(
              'Tap Start to Scan QR',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScannerTab() {
    return Stack(
      fit: StackFit.expand,
      children: [
        if (_isScanning && _scannerController != null)
          _buildScannerView()
        else
          _buildScannerPlaceholder(),

        Positioned(
          bottom: 40,
          left: 0,
          right: 0,
          child: Center(
            child: FloatingActionButton.extended(
              onPressed: _isProcessing
                  ? null
                  : (_isScanning ? _stopScanning : _startScanning),
              backgroundColor: _isScanning
                  ? Colors.red
                  : (_isProcessing
                  ? Colors.grey
                  : const Color(0xFFF37F20)),
              icon: Icon(
                _isScanning
                    ? Icons.stop
                    : (_isProcessing
                    ? Icons.hourglass_empty
                    : Icons.qr_code_scanner),
              ),
              label: Text(
                _isScanning
                    ? 'Stop Scanning'
                    : (_isProcessing
                    ? 'Processing...'
                    : 'Start Scanning'),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildManualTab() {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      behavior: HitTestBehavior.opaque,
      child: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height -
                  kToolbarHeight - // AppBar height
                  kTextTabBarHeight, // TabBar height
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.keyboard,
                  size: 80,
                  color: Color(0xFFF37F20),
                ),
                const SizedBox(height: 40),
                TextField(
                  controller: _manualCodeController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Enter Access Code',
                    hintStyle:
                    const TextStyle(color: Colors.white54),
                    filled: true,
                    fillColor: Colors.grey.shade900,
                    border: OutlineInputBorder(
                      borderRadius:
                      BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding:
                    const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed:
                    _isProcessing ? null : _handleManualCode,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                      const Color(0xFFF37F20),
                      padding:
                      const EdgeInsets.symmetric(
                          vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(12),
                      ),
                    ),
                    child: _isProcessing
                        ? const SizedBox(
                      height: 20,
                      width: 20,
                      child:
                      CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                        : const Text(
                      'Submit Code',
                      style:
                      TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        // title: const Text('Check In'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFFF37F20),
          labelColor: const Color(0xFFF37F20),
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(
              icon: Icon(Icons.qr_code_scanner),
              text: "Scan QR",
            ),
            Tab(
              icon: Icon(Icons.keyboard),
              text: "Access Code",
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildScannerTab(),
          _buildManualTab(),
        ],
      ),
    );
  }
}
