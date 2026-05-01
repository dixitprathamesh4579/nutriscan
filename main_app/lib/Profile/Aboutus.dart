import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:main_app/HomePageAll/HomePage.dart';
import 'package:main_app/Profile/user_profile.dart';

class AboutNutriScanPage extends StatelessWidget {
  const AboutNutriScanPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => HomePage()),
            );
          },
          icon: Icon(Icons.arrow_back_ios_new),
        ),
        title: const Text("About NutriScan"),
        centerTitle: true,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🌿 App Header
            Center(
              child: Column(
                children: [
                  Image.asset("assets/images/appbarlogo.png", height: 100),

                  const SizedBox(height: 10),
                  Text(
                    "NutriScan",
                    style: GoogleFonts.poppins(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Scan. Eat Smart. Live Healthy.",
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 🧠 About Section
            _buildCard(
              context: context,
              title: "What is NutriScan?",
              content:
                  "NutriScan is a smart AI-powered app that identifies food from images and provides detailed nutritional insights instantly.",
            ),

            // 🎯 Mission
            _buildCard(
              context: context,
              title: "Our Mission",
              content:
                  "To make healthy eating simple and accessible by using ML to guide better food choices.",
            ),

            const SizedBox(height: 10),

            // ⚙️ Features
            Text(
              "Key Features",
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),

            _buildFeature(Icons.camera_alt, "Scan Food Instantly"),
            _buildFeature(Icons.restaurant, "Get Nutrition Insights"),
            _buildFeature(Icons.lightbulb, "Smart Suggestions"),
            _buildFeature(Icons.bar_chart, "Track Your Diet"),
            _buildFeature(Icons.smart_toy, "ML Powered"),

            const SizedBox(height: 20),

            // 🚀 How it Works
            Text(
              "How It Works",
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),

            _buildStep("1", "Capture or upload food image"),
            _buildStep("2", "ML detects the food"),
            _buildStep("3", "Nutrition is analyzed"),
            _buildStep("4", "Get instant results"),

            const SizedBox(height: 20),

            // 👨‍💻 Developer Info
            _buildCard(
              context: context,
              title: "Developer",
              content:
                  "Developed by Prathamesh Dixit and Team\n\nFeel free to connect or give feedback!\n\nEmail: nutriscan08@gmail.com",
            ),

            const SizedBox(height: 20),

            // ❤️ Footer
            Center(
              child: Text(
                "Made with ❤️ for a healthier future",
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🔹 Reusable Card Widget
  Widget _buildCard({
    required BuildContext context,
    required String title,
    required String content,
  }) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: Colors.white,
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(content, style: GoogleFonts.poppins(fontSize: 14)),
            ],
          ),
        ),
      ),
    );
  }

  // 🔹 Feature Row
  Widget _buildFeature(IconData icon, String text) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.green.shade100,
        child: Icon(icon, color: Colors.green),
      ),
      title: Text(text, style: GoogleFonts.poppins(fontSize: 14)),
    );
  }

  // 🔹 Step Widget
  Widget _buildStep(String number, String text) {
    return Row(
      children: [
        CircleAvatar(
          radius: 14,
          backgroundColor: Colors.green,
          child: Text(
            number,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(child: Text(text, style: GoogleFonts.poppins(fontSize: 14))),
      ],
    );
  }
}
