import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Healthydf extends StatelessWidget {
  const Healthydf({super.key});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;
    final t = MediaQuery.of(context).textScaleFactor;

    return Container(
      width: w * 0.9,
      height: h * 0.10,
      padding: EdgeInsets.all(w * 0.03),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
              Color(0xFF66BB6A), 
            Color(0xFF81C784),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(w * 0.04),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.25),
            blurRadius: w * 0.03,
            offset: Offset(0, h * 0.005),
          ),
        ],
      ),

      child: Center(
        child: Text(
          "Healthy Food / Drinks",
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: w * 0.06 / t,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
