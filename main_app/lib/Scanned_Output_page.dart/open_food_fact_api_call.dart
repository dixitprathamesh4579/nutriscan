import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:main_app/Scanner/ScannerCamera.dart';

class OpenFood extends StatefulWidget {
  const OpenFood({super.key});

  @override
  State<OpenFood> createState() => _OpenFoodState();
}

class _OpenFoodState extends State<OpenFood> {
  Map<String, dynamic>? product;
  bool isLoading = true;
  String? code = ScannerCamerastate.scannedBarcode;
  String veganStatus = "Unknown";
  @override
  void initState() {
    super.initState();
    fetchproducts();
  }

  Future<void> fetchproducts() async {
    print("Fetching Product...");
    final uri = Uri.parse(
      "https://world.openfoodfacts.org/api/v2/product/$code.json",
    );
    final response = await http.get(
      uri,
      headers: {"User-Agent": "NutriScan - Flutter - Version 1.0"},
    );

    print(" Status code: ${response.statusCode}");

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data["status"] == 1) {
        print("Product found ");
        setState(() {
          product = data["product"];
          isLoading = false;
        });
      } else {
        print("Product not found ");
        setState(() {
          product = null;
          isLoading = false;
        });
      }
    } else {
      print("Error: ${response.statusCode}");
      setState(() {
        Text(response.statusCode.toString());
        isLoading = false;
      });
    }
  }

  Widget vegStatus() {
    if (product != null && product!["ingredients_analysis_tags"] != null) {
      List<dynamic> tags = product!["ingredients_analysis_tags"];
      if (tags.contains("en:vegetarian")) {
        veganStatus = "Vegetarian";
        return Text(veganStatus, style: TextStyle(color: Colors.green));
      } else if (tags.contains("en:non-vegetarian")) {
        veganStatus = "Non Vegetarian";
        return Text(veganStatus, style: TextStyle(color: Colors.red));
      }
    }
    return Text("Unknown", style: TextStyle(color: Colors.grey));
  }

  Widget ingredientsWidget() {
    final screenwidth = MediaQuery.of(context).size.width;

    if (product != null && product!["ingredients_text"] != null) {
      return SizedBox(
        width: screenwidth * 0.71,
        child: Text(
          "${product!["ingredients_text"] ?? "Unknown"}",
          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
        ),
      );
    } else {
      return Text('Unlnown');
    }
  }

  Widget NutritionalItemsWidget() {
    final screenwidth = MediaQuery.of(context).size.width;
    final screenheight = MediaQuery.of(context).size.height;
    final nutriments = product?["nutriments"];

    if (product != null && nutriments != null) {
      return Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
        color: Colors.white,
        margin: EdgeInsets.all(8),
        child: Padding(
          padding: EdgeInsets.all(screenwidth * 0.02),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Nutritional Level Per 100g'),
              SizedBox(height: screenheight * 0.02),
              _rowItem(
                "Energy :",
                "${nutriments["energy-kcal_100g"] ?? "N/A"} kcal",
              ),
              _rowItem("Fat", "${nutriments["fat_100g"] ?? "N/A"} g"),
              _rowItem(
                "Saturated Fat :",
                "${nutriments["saturated-fat_100g"] ?? "N/A"} g",
              ),
              _rowItem(
                "Carbohydrates :",
                "${nutriments["carbohydrates_100g"] ?? "N/A"} g",
              ),
              _rowItem("Sugars :", "${nutriments["sugars_100g"] ?? "N/A"} g"),
              _rowItem("Fiber :", "${nutriments["fiber_100g"] ?? "N/A"} g"),
              _rowItem(
                "Protein :",
                "${nutriments["proteins_100g"] ?? "N/A"} g",
              ),
              _rowItem("Salt :", "${nutriments["salt_100g"] ?? "N/A"} g"),
            ],
          ),
        ),
      );
    }

    return Text("No nutritional info available");
  }

  Widget _rowItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 10)),
          Text(
            value,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenheight = MediaQuery.of(context).size.height;
    final screenwidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : product == null
            ? const Center(child: Text('Product Not Found'))
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (product!["image_url"] != null)
                        SizedBox(
                          height: screenheight * 0.25,
                          width: screenwidth * 0.9,
                          child: Align(
                            alignment: AlignmentGeometry.center,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: Image.network(
                                product!['image_url'],
                                height: 150,
                              ),
                            ),
                          ),
                        ),
                      SizedBox(height: screenheight * 0.01),
                      Row(children: [Text("Veganstatus : "), vegStatus()]),
                      SizedBox(height: screenheight * 0.02),
                      Text(
                        product!["product_name"] ?? "No Name",
                        style: GoogleFonts.poppins(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "Brand : ${product!["brands"] ?? "Unknown"}",
                        style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                      ),
                      Row(
                        children: [Text("Ingrediants : "), ingredientsWidget()],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text("Nutritions : "),
                          NutritionalItemsWidget(),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
