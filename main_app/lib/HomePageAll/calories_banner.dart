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
    final screenheight = MediaQuery.of(context).size.height;
    return Container(
      width: screenWidth * 0.9,
      height: screenheight * 0.2,
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color.fromARGB(255, 39, 130, 203),
            const Color.fromARGB(255, 34, 110, 240),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),

      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Text(
            "Total Calories :",
            style: GoogleFonts.poppins(
              fontSize: 25,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),

          Text(
            '$totalCalories Kcal',
            style: GoogleFonts.poppins(
              fontSize: 30,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'Target-$target Kcal',
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontStyle: FontStyle.italic,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          LinearPercentIndicator(
            width: screenWidth * 0.83,
            lineHeight: 12,
            percent: totalCalories / target,
            animation: true,
            animateFromLastPercent: true,
            animationDuration: 1000,
            progressColor: Colors.white,
            barRadius: Radius.circular(10),
            backgroundColor: const Color.fromARGB(255, 137, 192, 238),
          ),
        ],
      ),
    );
  }
}
