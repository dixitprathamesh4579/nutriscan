import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:main_app/HomePageAll/HomePage.dart';
import 'package:main_app/Scanned_Output_page.dart/open_food_fact_api_call.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ScannerCamera extends StatefulWidget {
  const ScannerCamera({super.key});

  @override
  State<ScannerCamera> createState() => ScannerCamerastate();
}

class ScannerCamerastate extends State<ScannerCamera> {
  static String? scannedBarcode;
  Widget _buildUi() {
    final screenwidth = MediaQuery.of(context).size.width;
    final screenheight = MediaQuery.of(context).size.height;
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
                backgroundColor: Colors.red,
              ),
            );
          } else {
            setState(() {
              scannedBarcode = barcode.rawValue;
            });
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("No barcode found in the image!"),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        toolbarHeight: screenheight * 0.04,
        leading: IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
            );
          },
          icon: Icon(Icons.arrow_back_ios_new),
        ),
      ),
      body: SafeArea(
        child: SizedBox.expand(
          child: Container(
            width: screenwidth,
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: screenheight * 0.05),
                Text(
                  'Scanner',
                  style: TextStyle(
                    fontSize: screenwidth * 0.12,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: screenheight * 0.07),
                Text(
                  'Scan Barcode From Product',
                  style: GoogleFonts.poppins(
                    fontSize: screenwidth * 0.05,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: screenheight * 0.02),
                SizedBox(
                  height: screenheight * 0.25,
                  width: screenwidth * 0.9,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: MobileScanner(
                      controller: controller,
                      onDetect: (BarcodeCapture capture) {
                        final List<Barcode> barcodes = capture.barcodes;
                        for (final barcode in barcodes) {
                          setState(() {
                            scannedBarcode = barcode.rawValue;
                          });
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => OpenFood()),
                          );
                        }
                      },
                    ),
                  ),
                ),
                SizedBox(height: screenheight * 0.05),

                if (scannedBarcode != null)
                  Text(
                    "Scanned: $scannedBarcode",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),

                SizedBox(height: screenheight * 0.10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      horizontal: 100,
                      vertical: 15,
                    ),
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadiusGeometry.circular(20),
                    ),
                  ),
                  onPressed: () {
                    _pickimageandscan();
                  },
                  child: Text(
                    'Choose From Gallery',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
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
    final screenwidth = MediaQuery.of(context).size.width;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Container(
          width: screenwidth,
          color: Colors.white,
          child: _buildUi(),
        ),
      ),
    );
  }
}
