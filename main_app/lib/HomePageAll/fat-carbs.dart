import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class fatcarbs extends StatefulWidget {
  const fatcarbs({super.key});

  @override
  State<fatcarbs> createState() => fatcarbs_state();
}

class fatcarbs_state extends State<fatcarbs> {
  int Fat = 100, carbs = 200;

  String fatstat() {
    if (Fat < 44) {
      return 'Good';
    } else if (Fat < 65) {
      return 'Bad';
    } else if (Fat > 78) {
      return 'Too Much';
    } else {
      return 'Average';
    }
  }

  String Carbstat() {
    if (carbs < 225) {
      return 'Low';
    } else if (carbs <= 280) {
      return 'Medium';
    } else if (carbs > 325) {
      return 'High';
    } else {
      return 'Average';
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final textScale = MediaQuery.of(context).textScaleFactor;

    final double boxWidth = screenWidth * 0.435;
    final double boxHeight = screenHeight * 0.175;
    final double padding = screenWidth * 0.025;
    final double fontSmall = screenWidth * 0.045 / textScale;
    final double fontMedium = screenWidth * 0.055 / textScale;
    final double fontLarge = screenWidth * 0.07 / textScale;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: boxWidth,
          height: boxHeight,
          padding: EdgeInsets.all(padding),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFFE3C2), Color(0xFFFFD6A0)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(screenWidth * 0.03),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(
                'Fat',
                style: GoogleFonts.poppins(
                  fontSize: fontMedium,
                  fontWeight: FontWeight.bold,
                  color: Colors.brown,
                ),
              ),
              Text(
                '$Fat g',
                style: GoogleFonts.poppins(
                  fontSize: fontLarge,
                  fontWeight: FontWeight.bold,
                  color: Colors.brown,
                ),
              ),
              Text(
                fatstat(),
                style: GoogleFonts.poppins(
                  fontSize: fontSmall,
                  fontWeight: FontWeight.bold,
                  color: Colors.brown,
                ),
              ),
            ],
          ),
        ),

        SizedBox(width: screenWidth * 0.025),

        Container(
          width: boxWidth,
          height: boxHeight,
          padding: EdgeInsets.all(padding),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFFE3C2), Color(0xFFFFD6A0)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(screenWidth * 0.03),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(
                'Carbs',
                style: GoogleFonts.poppins(
                  fontSize: fontMedium,
                  fontWeight: FontWeight.bold,
                  color: Colors.brown,
                ),
              ),
              Text(
                '$carbs g',
                style: GoogleFonts.poppins(
                  fontSize: fontLarge,
                  fontWeight: FontWeight.bold,
                  color: Colors.brown,
                ),
              ),
              Text(
                Carbstat(),
                style: GoogleFonts.poppins(
                  fontSize: fontSmall,
                  fontWeight: FontWeight.bold,
                  color: Colors.brown,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
