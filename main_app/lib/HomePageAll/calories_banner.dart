import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:google_fonts/google_fonts.dart';

class Calories extends StatefulWidget {
  const Calories({super.key});
  @override
  State<Calories> createState() => Calories_state();
}

class Calories_state extends State<Calories> {
  int totalCalories = 1200;
  int target = 2000;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final textScale = MediaQuery.of(context).textScaleFactor;

    return Container(
      width: screenWidth * 0.9,
      height: screenHeight * 0.22,
      padding: EdgeInsets.all(screenWidth * 0.03),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color.fromARGB(255, 39, 130, 203),
            Color.fromARGB(255, 34, 110, 240),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(screenWidth * 0.04),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.2),
            blurRadius: screenWidth * 0.03,
            offset: Offset(0, screenHeight * 0.005),
          ),
        ],
      ),

      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Total Calories :",
            style: GoogleFonts.poppins(
              fontSize: screenWidth * 0.06 / textScale,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),

          Text(
            '$totalCalories Kcal',
            style: GoogleFonts.poppins(
              fontSize: screenWidth * 0.075 / textScale,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),

          Text(
            'Target - $target Kcal',
            style: GoogleFonts.poppins(
              fontSize: screenWidth * 0.035 / textScale,
              fontStyle: FontStyle.italic,
              color: Colors.white.withOpacity(0.9),
              fontWeight: FontWeight.w600,
            ),
          ),

          SizedBox(height: screenHeight * 0.015),

          LinearPercentIndicator(
            width: screenWidth * 0.83,
            lineHeight: screenHeight * 0.015,
            percent: totalCalories / target,
            animation: true,
            animateFromLastPercent: true,
            animationDuration: 1000,
            progressColor: Colors.white,
            backgroundColor: const Color.fromARGB(255, 137, 192, 238),
            barRadius: Radius.circular(screenWidth * 0.03),
          ),
        ],
      ),
    );
  }
}
