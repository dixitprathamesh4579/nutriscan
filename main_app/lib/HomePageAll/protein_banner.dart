import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProteinBanner extends StatelessWidget {
  final double protein;

  const ProteinBanner({super.key, required this.protein});

  String proteinStatus(double value) {
    if (value < 30) return "Low";
    if (value <= 60) return "Moderate";
    return "High";
  }

  Color proteinColor(double value) {
    if (value < 30) return Colors.red;
    if (value <= 60) return Colors.orange;
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;

    return Container(
      width: w * 0.9,
      height: h * 0.14,
      padding: EdgeInsets.all(w * 0.04),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE1F5FE), Color(0xFFB3E5FC)], // light blue theme
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(w * 0.04),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.2),
            blurRadius: w * 0.03,
            offset: Offset(0, h * 0.005),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Total Protein Intake",
            style: GoogleFonts.poppins(
              fontSize: w * 0.05,
              fontWeight: FontWeight.bold,
              color: Colors.blue[900],
            ),
          ),

          Text(
            "${protein.toStringAsFixed(1)} g",
            style: GoogleFonts.poppins(
              fontSize: w * 0.065,
              fontWeight: FontWeight.bold,
              color: proteinColor(protein),
            ),
          ),

          Text(
            proteinStatus(protein),
            style: GoogleFonts.poppins(
              fontSize: w * 0.04,
              fontWeight: FontWeight.w600,
              color: proteinColor(protein),
            ),
          ),
        ],
      ),
    );
  }
}
