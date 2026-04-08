import 'package:flutter/material.dart';
import 'package:main_app/Scanner/Product_Image.dart';
import 'package:main_app/Scanner/ScannerCamera.dart';

class ScanPageSwitcher extends StatefulWidget {
  const ScanPageSwitcher({super.key});

  @override
  State<ScanPageSwitcher> createState() => _ScanPageSwitcherState();
}

class _ScanPageSwitcherState extends State<ScanPageSwitcher> {
  bool showBarcodeScanner = true;

  void switchPage(bool barcodeMode) {
    setState(() {
      showBarcodeScanner = barcodeMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return showBarcodeScanner
        ? ScannerCamera(onSwitch: () => switchPage(false))
        : ProductImageCapturePage(onSwitch: () => switchPage(true));
  }
}
