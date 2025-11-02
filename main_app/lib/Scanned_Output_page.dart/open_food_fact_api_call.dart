import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:main_app/HomePageAll/HomePage.dart';
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
      fetchAlternatives();
  
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

  List<dynamic> alternativeProducts = [];
  bool loadingAlternatives = true;

  Future<void> fetchAlternatives() async {
    if (product == null) return;

    String? category =
        product?["categories_tags"] != null &&
            product!["categories_tags"].isNotEmpty
        ? product!["categories_tags"][0].replaceAll("en:", "")
        : null;

    if (category == null) return;

    final uri = Uri.parse(
      "https://world.openfoodfacts.org/category/$category.json?fields=product_name,image_url,nutriscore_grade,brands&nutrition_grades=a&sort_by=popularity&page_size=5",
    );

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        alternativeProducts = data["products"] ?? [];
        loadingAlternatives = false;
      });
    } else {
      setState(() => loadingAlternatives = false);
    }
  }

  Widget vegStatus() {
    if (product != null && product!["ingredients_analysis_tags"] != null) {
      List tags = product!["ingredients_analysis_tags"];

      if (tags.contains("en:vegan")) {
        return Text(
          "Vegan",
          style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
        );
      }
      if (tags.contains("en:vegetarian")) {
        return Text(
          "Vegetarian",
          style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
        );
      }
      if (tags.contains("en:non-vegetarian")) {
        return Text(
          "Non-Vegetarian",
          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
        );
      }
      if (tags.contains("en:non-vegan")) {
        return Text(
          "Non-Vegan",
          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
        );
      }
    }

    return Text("Unknown", style: TextStyle(color: Colors.grey));
  }

  Widget ingredientsWidget() {
    final screenwidth = MediaQuery.of(context).size.width;
    final screenheight = MediaQuery.of(context).size.height;

    if (product != null && product!["ingredients_text"] != null) {
      return Container(
        width: screenwidth * 0.9,
        height: screenheight * 0.1,
        padding: EdgeInsets.all(4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color.fromARGB(255, 116, 116, 116)),
        ),
        child: SingleChildScrollView(
          child: Text(
            "${product!["ingredients_text"] ?? "Unknown"}",
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
          ),
        ),
      );
    } else {
      return Text('Unknown');
    }
  }

  Widget NutritionalItemsWidget() {
    final screenwidth = MediaQuery.of(context).size.width;
    final screenheight = MediaQuery.of(context).size.height;
    final nutriments = product?["nutriments"];
    String formatValue(dynamic value) {
      if (value == null) return "N/A";

      try {
        double numValue = double.parse(value.toString());
        return numValue.toStringAsFixed(2);
      } catch (e) {
        return value.toString();
      }
    }

    if (product != null && nutriments != null) {
      return Container(
        width: screenwidth * 0.9,
        height: screenheight * 0.1,
        padding: EdgeInsets.all(4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color.fromARGB(255, 116, 116, 116)),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              _rowItem(
                "Energy :",
                "${formatValue(nutriments["energy-kcal_100g"])} kcal",
              ),
              _rowItem("Fat :", "${formatValue(nutriments["fat_100g"])} g"),
              _rowItem(
                "Saturated Fat :",
                "${formatValue(nutriments["saturated-fat_100g"])} g",
              ),
              _rowItem(
                "Carbohydrates :",
                "${formatValue(nutriments["carbohydrates_100g"])} g",
              ),
              _rowItem(
                "Sugars :",
                "${formatValue(nutriments["sugars_100g"])} g",
              ),
              _rowItem("Fiber :", "${formatValue(nutriments["fiber_100g"])} g"),
              _rowItem(
                "Protein :",
                "${formatValue(nutriments["proteins_100g"])} g",
              ),
              _rowItem("Salt :", "${formatValue(nutriments["salt_100g"])} g"),
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

  Widget alternativeProductsWidget() {
    final screenwidth = MediaQuery.of(context).size.width;
    final screenheight = MediaQuery.of(context).size.height;
    if (loadingAlternatives) {
      return Center(child: CircularProgressIndicator());
    }

    if (alternativeProducts.isEmpty) {
      return Text("No healthier alternatives found.");
    }

    return Container(
      width: screenwidth * 0.9,
      height: screenheight * 0.17,
      padding: EdgeInsets.all(4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color.fromARGB(255, 116, 116, 116)),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: alternativeProducts.map((item) {
            return ListTile(
              leading: item["image_url"] != null
                  ? Image.network(item["image_url"], width: 50)
                  : Icon(Icons.image_not_supported),
              title: Text(item["product_name"] ?? "Unknown"),
              subtitle: Text("Brand: ${item["brands"] ?? "Unknown"}"),
            );
          }).toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenheight = MediaQuery.of(context).size.height;
    final screenwidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
            );
          },
          icon: Icon(Icons.arrow_back_ios_new),
        ),
        backgroundColor: Colors.white,
        toolbarHeight: 30,
      ),
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: isLoading
              ? Center(child: CircularProgressIndicator())
              : product == null
              ? const Center(child: Text('Product Not Found'))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (product!["image_url"] != null)
                        Container(
                          width: screenwidth * 0.9,
                          height: screenheight * 0.2,
                          padding: EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: const Color.fromARGB(255, 116, 116, 116),
                            ),
                          ),
                          child: Image.network(
                            product!['image_url'],
                            height: 150,
                          ),
                        ),
                      SizedBox(height: screenheight * 0.01),
                      Row(
                        children: [
                          Text(
                            "Veganstatus : ",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          vegStatus(),
                        ],
                      ),
                      SizedBox(height: screenheight * 0.01),
                      Text(
                        product!["product_name"] ?? "No Name",
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "Brand : ${product!["brands"] ?? "Unknown"}",
                        style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: screenheight * 0.01),
                      Text(
                        "Ingradients Used",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),

                      ingredientsWidget(),

                      SizedBox(height: screenheight * 0.01),

                      Text(
                        "Nutritional Level Per 100g",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      NutritionalItemsWidget(),
                      SizedBox(height: screenheight * 0.01),
                      Text(
                        "Alternatives",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      alternativeProductsWidget(),
                      SizedBox(height: screenheight*0.01),
                       ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      horizontal: 100,
                      vertical: 15,
                    ),
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadiusGeometry.circular(20),
                    ),
                  ),
                  onPressed: () {
                  },
                  child: Text(
                    'ADD',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                  ),
                ),
                    ],
                  ),
                  
                ),
        ),
      ),
    );
  }
}
