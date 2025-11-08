import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Healthydf extends StatefulWidget {
  const Healthydf({super.key});
  @override
  State<Healthydf> createState() => healthydfState();
}

class healthydfState extends State<Healthydf> {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final textScale = MediaQuery.of(context).textScaleFactor;

    return Container(
      width: screenWidth * 0.9,
      height: screenHeight * 0.10,
      padding: EdgeInsets.all(screenWidth * 0.03),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color.fromARGB(255, 241, 142, 238),
            Color.fromARGB(255, 232, 166, 242),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(screenWidth * 0.04),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(0.2),
            blurRadius: screenWidth * 0.03,
            offset: Offset(0, screenHeight * 0.005),
          ),
        ],
      ),
      child: Center(
        child: Text(
          "Healthy Food/Drinks",
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: screenWidth * 0.065 / textScale, 
            color: const Color.fromARGB(255, 114, 57, 164),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
