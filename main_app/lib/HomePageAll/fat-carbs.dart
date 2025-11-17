import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FatCarbs extends StatelessWidget {
  final double fat;
  final double carbs;

  const FatCarbs({
    super.key,
    required this.fat,
    required this.carbs,
  });

  String fatStat(double fat) {
    if (fat < 44) return "Good";
    if (fat < 65) return "Moderate";
    if (fat > 78) return "High";
    return "Average";
  }

  String carbStat(double carbs) {
    if (carbs < 225) return "Low";
    if (carbs <= 280) return "Medium";
    if (carbs > 325) return "High";
    return "Average";
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;
    final t = MediaQuery.of(context).textScaleFactor;

    final double boxW = w * 0.435;
    final double boxH = h * 0.15;
    final double pad = w * 0.025;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // ---------------- FAT ----------------
        Container(
          width: boxW,
          height: boxH,
          padding: EdgeInsets.all(pad),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFF7043), Color(0xFFFF8A65)], // Orange-Red
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(w * 0.03),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Fat',
                style: GoogleFonts.poppins(
                  fontSize: w * 0.055 / t,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                '${fat.toStringAsFixed(1)} g',
                style: GoogleFonts.poppins(
                  fontSize: w * 0.07 / t,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                fatStat(fat),
                style: GoogleFonts.poppins(
                  fontSize: w * 0.045 / t,
                  fontWeight: FontWeight.bold,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),

        SizedBox(width: w * 0.025),

        // ---------------- CARBS ----------------
        Container(
          width: boxW,
          height: boxH,
          padding: EdgeInsets.all(pad),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF29B6F6), Color(0xFF4FC3F7)], // Blue-Cyan
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(w * 0.03),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Carbs',
                style: GoogleFonts.poppins(
                  fontSize: w * 0.055 / t,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                '${carbs.toStringAsFixed(1)} g',
                style: GoogleFonts.poppins(
                  fontSize: w * 0.07 / t,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                carbStat(carbs),
                style: GoogleFonts.poppins(
                  fontSize: w * 0.045 / t,
                  fontWeight: FontWeight.bold,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
