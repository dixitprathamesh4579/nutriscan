import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:google_fonts/google_fonts.dart';

class Calories extends StatefulWidget {
  final double totalCalories;
  final double target;

  const Calories({
    super.key,
    required this.totalCalories,
    this.target = 2000,
  });

  @override
  State<Calories> createState() => CaloriesState();
}

class CaloriesState extends State<Calories> {
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
           Color.fromARGB(255, 248, 187, 45),  
            Color.fromARGB(255, 252, 199, 85),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(screenWidth * 0.04),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.2),
            blurRadius: screenWidth * 0.03,
            offset: Offset(0, screenHeight * 0.005),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Total Calories",
            style: GoogleFonts.poppins(
              fontSize: screenWidth * 0.06 / textScale,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),

          Text(
            '${widget.totalCalories.toStringAsFixed(0)} Kcal',
            style: GoogleFonts.poppins(
              fontSize: screenWidth * 0.075 / textScale,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),

          Text(
            'Target - ${widget.target.toStringAsFixed(0)} Kcal',
            style: GoogleFonts.poppins(
              fontSize: screenWidth * 0.035 / textScale,
              color: Colors.white70,
              fontWeight: FontWeight.w600,
            ),
          ),

          SizedBox(height: screenHeight * 0.015),

          LinearPercentIndicator(
            width: screenWidth * 0.83,
            lineHeight: screenHeight * 0.015,
            percent: widget.totalCalories / widget.target,
            animation: true,
            animateFromLastPercent: true,
            animationDuration: 1000,
            progressColor: Colors.white,
            backgroundColor: Colors.white24,
            barRadius: Radius.circular(screenWidth * 0.03),
          ),
        ],
      ),
    );
  }
}
