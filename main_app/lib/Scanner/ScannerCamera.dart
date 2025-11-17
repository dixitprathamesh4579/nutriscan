import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:main_app/Scanned_Output_page.dart/open_food_fact_api_call.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScannerCamera extends StatefulWidget {
  final VoidCallback? onSwitch;
  const ScannerCamera({super.key, this.onSwitch});

  @override
  State<ScannerCamera> createState() => ScannerCamerastate();
}

class ScannerCamerastate extends State<ScannerCamera> {
  static String? scannedBarcode;
  bool cameraPaused = false;
  List<bool> isSelected = [false, true];

  final MobileScannerController controller = MobileScannerController(
    formats: [
      BarcodeFormat.code128,
      BarcodeFormat.ean13,
      BarcodeFormat.ean8,
      BarcodeFormat.upcA,
      BarcodeFormat.upcE,
      BarcodeFormat.code39,
      BarcodeFormat.itf,
    ],
  );

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> _pickimageandscan() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedfile = await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedfile != null) {
      final File imagefile = File(pickedfile.path);
      final result = await controller.analyzeImage(imagefile.path);

      if (result != null && result.barcodes.isNotEmpty) {
        final barcode = result.barcodes.first;

        if (barcode.format == BarcodeFormat.qrCode) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("QR Codes are not allowed!"),
              backgroundColor: Colors.redAccent,
            ),
          );
        } else {
          setState(() => scannedBarcode = barcode.rawValue);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const OpenFood()),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("No barcode found in the image!"),
            backgroundColor: Colors.orangeAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final textScale = MediaQuery.of(context).textScaleFactor;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.05,
                  vertical: screenHeight * 0.02,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ToggleButtons(
                      isSelected: isSelected,
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.black87,
                      selectedColor: Colors.white,
                      fillColor: Colors.blueAccent,
                      constraints: BoxConstraints(
                        minWidth: screenWidth * 0.25,
                        minHeight: screenHeight * 0.05,
                      ),
                      onPressed: (index) {
                        setState(() {
                          for (int i = 0; i < isSelected.length; i++) {
                            isSelected[i] = (i == index);
                          }
                        });
                        if (index == 0) widget.onSwitch?.call();
                      },
                      children: [
                        Text(
                          "Product",
                          style: GoogleFonts.poppins(
                            fontSize: screenWidth * 0.04 / textScale,
                          ),
                        ),
                        Text(
                          "Barcode",
                          style: GoogleFonts.poppins(
                            fontSize: screenWidth * 0.04 / textScale,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: screenHeight * 0.02),

                    Text(
                      'Scanner',
                      style: GoogleFonts.poppins(
                        fontSize: screenWidth * 0.1 / textScale,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      'Scan Barcode',
                      style: GoogleFonts.poppins(
                        fontSize: screenWidth * 0.045 / textScale,
                        color: Colors.grey.shade600,
                      ),
                    ),

                    SizedBox(height: screenHeight * 0.02),

                    AspectRatio(
                      aspectRatio: 1,
                      child: Container(
                        width: screenWidth * 0.9,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: Colors.blueAccent,
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blueAccent.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: MobileScanner(
                            controller: controller,
                            onDetect: (BarcodeCapture capture) {
                              final List<Barcode> barcodes = capture.barcodes;
                              for (final barcode in barcodes) {
                                setState(
                                  () => scannedBarcode = barcode.rawValue,
                                );
                                controller.stop();
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const OpenFood(),
                                  ),
                                );
                              }
                            },
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: screenHeight * 0.03),

                    Container(
                      width: screenWidth * 0.80,
                      padding: EdgeInsets.symmetric(
                        vertical: screenHeight * 0.015,
                        horizontal: screenWidth * 0.02,
                      ),
                      decoration: BoxDecoration(
                        color: Color.fromARGB(255, 166, 106, 234),

                        borderRadius: BorderRadius.circular(15),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'Align the barcode inside the frame',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: screenWidth * 0.035 / textScale,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),

                    SizedBox(height: screenHeight * 0.03),

                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          vertical: screenHeight * 0.018,
                          horizontal: screenWidth * 0.18,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 3,
                      ),
                      onPressed: _pickimageandscan,
                      icon: const Icon(Icons.photo_library_rounded),
                      label: Text(
                        'Choose From Gallery',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: screenWidth * 0.042 / textScale,
                        ),
                      ),
                    ),

                    SizedBox(height: screenHeight * 0.03),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
