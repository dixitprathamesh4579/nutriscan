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
      return 'high';
    } else {
      return 'Average';
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenheight = MediaQuery.of(context).size.height;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,

      children: [
        Container(
          width: screenWidth * 0.44,
          height: screenheight * 0.175,
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [const Color(0xFFFFE3C2), const Color(0xFFFFD6A0)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Fat',
                style: GoogleFonts.poppins(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: Colors.brown,
                ),
              ),
              Text(
                '$Fat g',
                style: GoogleFonts.poppins(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.brown,
                ),
              ),
              Text(
                fatstat(),
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.brown,
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 10),
        Container(
          width: screenWidth * 0.44,
          height: screenheight * 0.175,
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [const Color(0xFFFFE3C2), const Color(0xFFFFD6A0)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Carbs',
                style: GoogleFonts.poppins(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: Colors.brown,
                ),
              ),
              Text(
                '$carbs g',
                style: GoogleFonts.poppins(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.brown,
                ),
              ),
              Text(
                Carbstat(),
                style: GoogleFonts.poppins(
                  fontSize: 20,
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
