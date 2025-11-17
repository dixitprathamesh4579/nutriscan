import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProductOutput extends StatelessWidget {
  final String productName;
  final String? productImageUrl;
  final String nutritionScore;
  final List<String> harmfulIngredients;
  final Map<String, dynamic> nutritionFacts;

  const ProductOutput({
    super.key,
    required this.productName,
    required this.productImageUrl,
    required this.nutritionScore,
    required this.harmfulIngredients,
    required this.nutritionFacts,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(productName, style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (productImageUrl != null)
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(productImageUrl!, height: 180),
                ),
              ),
            const SizedBox(height: 20),

            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.blue.shade50,
              ),
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Nutrition Score", style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Text("Based on product composition", style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey)),
                    ],
                  ),
                  Text(
                    nutritionScore,
                    style: GoogleFonts.poppins(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.blue),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Text("Nutrition Facts (per 100g)", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ...nutritionFacts.entries.map((e) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(e.key, style: GoogleFonts.poppins(fontSize: 15)),
                  Text(e.value.toString(), style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w500)),
                ],
              ),
            )),

            const SizedBox(height: 20),

            Text("Harmful Ingredients", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            if (harmfulIngredients.isEmpty)
              Text("No harmful ingredients detected ", style: GoogleFonts.poppins(fontSize: 15, color: Colors.green))
            else
              Column(
                children: harmfulIngredients.map((item) => Container(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning, color: Colors.red, size: 20),
                      const SizedBox(width: 8),
                      Text(item, style: GoogleFonts.poppins(fontSize: 15, color: Colors.red.shade700)),
                    ],
                  ),
                )).toList(),
              ),
          ],
        ),
      ),
    );
  }
}
