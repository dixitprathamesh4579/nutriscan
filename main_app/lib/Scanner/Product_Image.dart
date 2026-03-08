import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:google_fonts/google_fonts.dart';

class ProductImageCapturePage extends StatefulWidget {
  final VoidCallback? onSwitch;
  const ProductImageCapturePage({super.key, this.onSwitch});

  @override
  State<ProductImageCapturePage> createState() =>
      _ProductImageCapturePageState();
}

class _ProductImageCapturePageState extends State<ProductImageCapturePage>
    with SingleTickerProviderStateMixin {
  CameraController? _cameraController;
  bool isCameraReady = false;
  List<bool> isSelected = [true, false];
  bool showCamera = true;

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
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    final XFile image = await _cameraController!.takePicture();
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductImageDisplay(imagePath: image.path),
      ),
    );
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final textScale = MediaQuery.of(context).textScaleFactor;

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.05,
                    vertical: screenHeight * 0.02),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeInOut,
                      child: ToggleButtons(
                        isSelected: isSelected,
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.black,
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
                            showCamera = (index == 0);
                            if (index == 1) {
                              widget.onSwitch?.call();
                            }
                          });
                        },
                        children: [
                          Text(
                            "Product",
                            style: GoogleFonts.poppins(
                                fontSize: screenWidth * 0.04 / textScale),
                          ),
                          Text(
                            "Barcode",
                            style: GoogleFonts.poppins(
                                fontSize: screenWidth * 0.04 / textScale),
                          ),
                        ],
                      ),
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
                      'Scan Product',
                      style: GoogleFonts.poppins(
                        fontSize: screenWidth * 0.045 / textScale,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.02),

                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 400),
                      switchInCurve: Curves.easeIn,
                      switchOutCurve: Curves.easeOut,
                      child: showCamera
                          ? AspectRatio(
                              key: const ValueKey('camera'),
                              aspectRatio: 1,
                              child: Container(
                                width: screenWidth * 0.9,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(
                                      color:Colors.blueAccent,),
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
                                  child: isCameraReady
                                      ? CameraPreview(_cameraController!)
                                      : const Center(
                                          child: CircularProgressIndicator()),
                                ),
                              ),
                            )
                          : Container(
                              key: const ValueKey('placeholder'),
                              width: screenWidth * 0.9,
                              height: screenWidth * 0.9,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(
                                    color: Colors.grey.shade400, width: 1),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.qr_code_scanner,
                                      size: 70, color: Colors.blueGrey),
                                  Text(
                                    "Barcode Mode",
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w600,
                                      fontSize: screenWidth * 0.045 / textScale,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                    ),

                    SizedBox(height: screenHeight * 0.03),

                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                           Color.fromARGB(255, 166, 106, 234),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          vertical: screenHeight * 0.012,
                          horizontal: screenWidth * 0.27,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      onPressed: _captureImage,
                      icon: const Icon(Icons.camera_alt_rounded),
                      label: Text(
                        'Capture',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: screenWidth * 0.045 / textScale,
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
                      onPressed: (){},
                      icon: const Icon(Icons.photo_library_rounded),
                      label: Text(
                        'Choose From Gallery',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: screenWidth * 0.042 / textScale,
                        ),
                      ),
                    ),
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

class ProductImageDisplay extends StatelessWidget {
  final String imagePath;
  const ProductImageDisplay({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Product Image"),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Image.file(File(imagePath), fit: BoxFit.contain),
          ),
        ),
      ),
    );
  }
}
