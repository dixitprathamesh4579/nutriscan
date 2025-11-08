import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:main_app/Scanned_Output_page.dart/open_food_fact_api_call.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:async';
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
void initState() {
  super.initState();
}


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


  Widget build(BuildContext context) {
    final screenwidth = MediaQuery.of(context).size.width;
        final screenheight = MediaQuery.of(context).size.height;
    return Scaffold(
       resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SizedBox.expand(
          child: Container(
            width: screenwidth,
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                    ToggleButtons(
        isSelected: isSelected,
        borderRadius: BorderRadius.circular(12),
        color: Colors.black,
        selectedColor: Colors.white,
        fillColor: Colors.blue[300],
        constraints: BoxConstraints(minWidth: 70, minHeight: 35),
        onPressed: (index) {
          setState(() {
            for (int i = 0; i < isSelected.length; i++) {
              isSelected[i] = (i == index);
            }
          });

          if (index == 0) {
             widget.onSwitch?.call();
          }
        },
        children: const [
          Text("Product"),
          Text("Barcode"),
        ],
      ),
                Text(
                  'Scanner',
                  style: TextStyle(
                    fontSize: screenwidth * 0.13,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Text(
                  'Scan Barcode',
                  style: GoogleFonts.poppins(
                    fontSize: screenwidth * 0.05,
                    color: Colors.grey,
                  ),
                ),
                                SizedBox(height:screenheight* 0.01),

               
                SizedBox(
                  height: screenheight * 0.45,
                  width: screenwidth * 0.90,
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
                SizedBox(height: screenheight * 0.02),
               Container(
          width: screenwidth * 0.81,
          height: screenheight * 0.055,
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [const Color.fromARGB(255, 187, 131, 239), const Color.fromARGB(255, 166, 106, 234)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
           alignment: Alignment.center,
          child:
              Text(
                'Align the barcode inside the frame',
                 textAlign: TextAlign.center, 
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
               ),
                SizedBox(height: screenheight * 0.01),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenwidth*0.3,
                      vertical: screenheight*0.02,
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

}
