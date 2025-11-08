import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:google_fonts/google_fonts.dart';

class ProductImageCapturePage extends StatefulWidget {
   final VoidCallback? onSwitch;
  const ProductImageCapturePage({super.key, this.onSwitch});

  @override
  State<ProductImageCapturePage> createState() => _ProductImageCapturePageState();
}

class _ProductImageCapturePageState extends State<ProductImageCapturePage> {
  CameraController? _cameraController;
  bool isCameraReady = false;
   List<bool> isSelected = [true, false];

  @override
  void initState() {
    super.initState();
    _setupCamera();
  }

  Future<void> _setupCamera() async {
    final cameras = await availableCameras();
    final camera = cameras.first; 

    _cameraController = CameraController(camera, ResolutionPreset.high);
    await _cameraController!.initialize();

    if (!mounted) return;
    setState(() => isCameraReady = true);
  }

  Future<void> _captureImage() async {
    final XFile image = await _cameraController!.takePicture();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductImageDisplay(imagePath: image.path),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenwidth = MediaQuery.of(context).size.width;
    final screenheight = MediaQuery.of(context).size.height;
    return Scaffold(
      body: 
      SafeArea(
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

          if (index == 1) {
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
                  'Scan Product',
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
              child: isCameraReady
                  ? CameraPreview(_cameraController!)
                  : Center(child: CircularProgressIndicator()),
            ),
          ),
           SizedBox(height: screenheight * 0.02),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenwidth * 0.33,
                      vertical: screenheight * 0.0165,
                    ),
                    backgroundColor: const Color.fromARGB(255, 184, 120, 243),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadiusGeometry.circular(20),
                    ),
                  ),
                  onPressed:  _captureImage,
                  child: Text(
                    'Capture',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
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

class ProductImageDisplay extends StatelessWidget {
  final String imagePath;
  const ProductImageDisplay({required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Product Image")),
      body: Center(
        child: Image.file(File(imagePath)),
      ),
    );
  }
}
