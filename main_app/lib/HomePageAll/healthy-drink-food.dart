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
    final screenwidth = MediaQuery.of(context).size.width;
    final screenheight = MediaQuery.of(context).size.height;
    return Container(
      width: screenwidth * 0.9,
      height: screenheight * 0.12,
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color.fromARGB(255, 241, 142, 238),
            const Color.fromARGB(255, 232, 166, 242),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "Healthy Food/Drinks",
            style: GoogleFonts.poppins(
              fontSize: 25,
              color: const Color.fromARGB(255, 114, 57, 164),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
