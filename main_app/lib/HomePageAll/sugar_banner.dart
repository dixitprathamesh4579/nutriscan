import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SugarBanner extends StatelessWidget {
  final double sugar;

  const SugarBanner({super.key, required this.sugar});

  String sugarStatus(double s) {
    if (s < 24) return "Good";         
    if (s <= 36) return "Moderate";
    return "High";
  }

  Color sugarColor(double s) {
    if (s < 24) return Colors.green;
    if (s <= 36) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;

    return Container(
      width: w * 0.9,
      height: h * 0.16,
      padding: EdgeInsets.all(w * 0.04),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE3F2FD), Color(0xFFBBDEFB)],
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
            "Total Sugar Intake",
            style: GoogleFonts.poppins(
              fontSize: w * 0.05,
              fontWeight: FontWeight.bold,
              color: Colors.blueGrey[900],
            ),
          ),

          Text(
            "${sugar.toStringAsFixed(1)} g",
            style: GoogleFonts.poppins(
              fontSize: w * 0.065,
              fontWeight: FontWeight.bold,
              color: sugarColor(sugar),
            ),
          ),

          Text(
            sugarStatus(sugar),
            style: GoogleFonts.poppins(
              fontSize: w * 0.04,
              fontWeight: FontWeight.w600,
              color: sugarColor(sugar),
            ),
          ),
        ],
      ),
    );
  }
}
