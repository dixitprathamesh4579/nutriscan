import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:main_app/HomePageAll/HomePage.dart';
import 'dart:convert';
import 'package:main_app/Scanner/ScannerCamera.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';


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
  List<String> riskyIngredients = [];
  List<dynamic> alternativeProducts = [];
  bool loadingAlternatives = true;
  List<String> additivesList = [];
  List<String> allergensList = [];
  Map<String, dynamic> eCodeMap = {};

  @override
  void initState() {
    super.initState();
    loadECodes();
    fetchproducts();
  }

  Future<void> loadECodes() async {
    try {
      final String raw = await rootBundle.loadString("assets/e_codes.json");
      final Map<String, dynamic> decoded = jsonDecode(raw);
      final normalized = <String, dynamic>{};
      decoded.forEach((k, v) {
        normalized[k.toString().toUpperCase()] = v;
      });
      setState(() {
        eCodeMap = normalized;
      });
    } catch (e) {
      print("Failed to load e_codes.json: $e");
    }
  }

  String getProcessedLevel() {
    final nova = product?["nova_group"];

    if (nova == null) {
      return "Unknown (not available)";
    }

    switch (nova) {
      case 1:
        return " Unprocessed / Minimally Processed";
      case 2:
        return " Processed Culinary Ingredients";
      case 3:
        return " Processed Food";
      case 4:
        return " Ultra-Processed Food";
      default:
        return " Unknown";
    }
  }

  String getSugarLevel() {
    final sugar = product?["nutriments"]?["sugars_100g"];
    if (sugar == null) return "Unknown";

    double val = double.tryParse(sugar.toString()) ?? 0;

    if (val < 5) return "Low Sugar";
    if (val <= 22.5) return "Medium Sugar";
    return "High Sugar";
  }

  String getFatLevel() {
    final fat = product?["nutriments"]?["fat_100g"];
    if (fat == null) return "Unknown";

    double val = double.tryParse(fat.toString()) ?? 0;

    if (val < 3) return "Low Fat";
    if (val <= 17.5) return "Medium Fat";
    return "High Fat";
  }

  Color getLevelColor(String level) {
    if (level.contains("High")) return Colors.red;
    if (level.contains("Medium")) return Colors.orange;
    if (level.contains("Low")) return Colors.green;
    return Colors.grey;
  }

  Future<void> fetchproducts() async {
    print("Fetching Product...");
    await dotenv.load(fileName: ".env");

    final uri = Uri.parse(
      dotenv.env['OPEN_FOOD']!,
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

          additivesList = List<String>.from(
            (product?["additives_tags"] as List<dynamic>?)
                    ?.map(
                      (e) => e
                          .toString()
                          .replaceFirst(RegExp(r'^[a-z]{2}:'), '')
                          .toUpperCase(),
                    )
                    .toList() ??
                [],
          );

          allergensList = List<String>.from(
            (product?["allergens_tags"] as List<dynamic>?)
                    ?.map(
                      (e) =>
                          e.toString().replaceFirst(RegExp(r'^[a-z]{2}:'), ''),
                    )
                    .toList() ??
                [],
          );
        });
      } else {
        print("Product not found ");
        setState(() {
          product = null;
          isLoading = false;
        });
      }
      analyzeIngredients();
      fetchAlternatives();
    } else {
      print("Error: ${response.statusCode}");
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchAlternatives() async {
    if (product == null) return;

    String? rawCategory =
        product?["categories_tags"] != null &&
            product!["categories_tags"].isNotEmpty
        ? product!["categories_tags"][0] as String
        : null;

    if (rawCategory == null) return;

    String category = rawCategory
        .replaceFirst(RegExp(r'^[a-z]{2}:'), '')
        .replaceAll('_', ' ')
        .trim();

    String? currentGrade =
        product?["nutrition_grades"] ?? product?["nutriscore_grade"];

    int gradeRank(String g) {
      final map = {'a': 1, 'b': 2, 'c': 3, 'd': 4, 'e': 5};
      return map[g.toLowerCase()] ?? 999;
    }

    final searchParams = {
      'action': 'process',
      'tagtype_0': 'categories',
      'tag_contains_0': 'contains',
      'tag_0': category,
      'tagtype_1': 'countries',
      'tag_contains_1': 'contains',
      'tag_1': 'india',
      'page_size': '60',
      'sort_by': 'unique_scans_n',
      'fields':
          'product_name,image_url,nutrition_grades,nutriscore_grade,brands,code,countries_tags',
      'json': '1',
      'nocache': '1',
    };

    final uri = Uri.https(
      'world.openfoodfacts.org',
      '/cgi/search.pl',
      searchParams,
    );

    setState(() => loadingAlternatives = true);

    try {
      final response = await http.get(
        uri,
        headers: {'User-Agent': 'MyApp/1.0 (support@yourapp.com)'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List<dynamic> products = (data['products'] as List<dynamic>?) ?? [];

        List<dynamic> filtered;
        if (currentGrade == null || currentGrade.isEmpty) {
          filtered = products;
        } else {
          final int currentRank = gradeRank(currentGrade);
          filtered = products.where((p) {
            final String? g =
                (p['nutrition_grades'] ?? p['nutriscore_grade']) as String?;
            if (g == null || g.isEmpty) return false;
            return gradeRank(g) < currentRank;
          }).toList();
        }

        final String? thisCode = product?['code'] as String?;
        filtered.removeWhere((p) => p['code'] == thisCode);

        final alternatives = filtered.take(5).toList();

        setState(() {
          alternativeProducts = alternatives;
          loadingAlternatives = false;
        });
      } else {
        setState(() => loadingAlternatives = false);
      }
    } catch (e) {
      setState(() => loadingAlternatives = false);
    }
  }

  Future<void> analyzeIngredients() async {
    final String ingredientText =
        product?["ingredients_text"]?.toString().toLowerCase() ?? "";
    if (ingredientText.isEmpty) return;

    try {
      final harmfulData = await rootBundle.loadString(
        "assets/harmful_ingredients.json",
      );
      final Map<String, dynamic> harmfulMap = jsonDecode(harmfulData);

      List<String> detected = [];

      harmfulMap.forEach((category, items) {
        for (var ing in items) {
          if (ingredientText.contains(ing.toString().toLowerCase())) {
            detected.add(ing.toString());
          }
        }
      });

      setState(() {
        riskyIngredients = detected.toSet().toList();
      });
    } catch (e) {
      print("Failed to analyze ingredients: $e");
    }
  }

  Map<String, String> getECodeInfo(String eCode) {
    final key = eCode.toUpperCase();
    if (eCodeMap.containsKey(key)) {
      final item = eCodeMap[key] as Map<String, dynamic>;
      return {
        "code": key,
        "name": item["name"]?.toString() ?? "Unknown",
        "type": item["type"]?.toString() ?? "Additive",
        "risk": item["risk"]?.toString() ?? "Unknown",
        "warning": item["warning"]?.toString() ?? "",
      };
    }
    return {
      "code": key,
      "name": "Unknown additive",
      "type": "Additive",
      "risk": "Unknown",
      "warning": "",
    };
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
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : product == null
          ? const Center(
              child: Text(
                'Product Not Found',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            )
          : LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (product!["image_url"] != null)
                        Container(
                          width: double.infinity,
                          height: screenheight * 0.28,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 8,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Center(
                            child: AspectRatio(
                              aspectRatio: 1.2,
                              child: Image.network(
                                product!['image_url'],
                                fit: BoxFit.contain,
                                alignment: Alignment.center,
                                loadingBuilder:
                                    (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return const Center(
                                        child: CircularProgressIndicator(),
                                      );
                                    },
                                errorBuilder: (_, __, ___) => const Icon(
                                  Icons.broken_image,
                                  size: 60,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ),
                        ),

                      SizedBox(height: screenheight * 0.01),
                      Row(
                        children: [
                          SizedBox(width: screenwidth * 0.03),
                          Expanded(
                            child: Text(
                              product!["product_name"] ?? "No Name",
                              style: GoogleFonts.poppins(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          SizedBox(width: screenwidth * 0.02),
                          Text(
                            "Brand :  ${product!["brands"] ?? "Unknown"}",
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),

                      Card(
                        elevation: 0,
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _infoRow("Vegan Status", vegStatus()),
                              _infoRow(
                                "Processed Level",
                                getProcessedLevel(),
                                color: getProcessedLevel().contains("Processed")
                                    ? Colors.red
                                    : Colors.green,
                              ),
                              _infoRow(
                                "Sugar Level",
                                getSugarLevel(),
                                color: getLevelColor(getSugarLevel()),
                              ),
                              _infoRow(
                                "Fat Level",
                                getFatLevel(),
                                color: getLevelColor(getFatLevel()),
                              ),
                            ],
                          ),
                        ),
                      ),

                      harmfulIngredientsWidget(),
                      additivesWidget(),
                      allergensWidget(),

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
                      SizedBox(height: 0.1),
                      SizedBox(
                        width: double.infinity,
                        height: screenheight * 0.06,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          onPressed: () {},
                          child: Text(
                            'SAVE',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              fontSize: screenwidth * 0.045,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Widget _infoRow(String title, dynamic value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
          value is Widget
              ? value
              : Text(
                  value.toString(),
                  style: GoogleFonts.poppins(
                    color: color ?? Colors.black87,
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
        ],
      ),
    );
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

  Widget harmfulIngredientsWidget() {
    final screenwidth = MediaQuery.of(context).size.width;
    if (riskyIngredients.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(
          "No harmful ingredients detected ",
          style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
        ),
      );
    }

    return Container(
      width: screenwidth * 0.9,
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.red),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Harmful Ingredients Found:",
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
          ),
          ...riskyIngredients.map(
            (ing) => Text(
              "• $ing",
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget additivesWidget() {
    final screenwidth = MediaQuery.of(context).size.width;
    final screenheight = MediaQuery.of(context).size.height;
    if (additivesList.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(
          "No additives detected",
          style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
        ),
      );
    }

    return Container(
      width: screenwidth * 0.9,
      height: screenheight * 0.2,
      padding: EdgeInsets.all(8),
      margin: EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Additives (E-codes):",
              style: TextStyle(
                color: Colors.orange,
                fontWeight: FontWeight.bold,
              ),
            ),

            ...additivesList.map((code) {
              final info = getECodeInfo(code);
              return Container(
                margin: EdgeInsets.symmetric(vertical: 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "• ${info['code']} - ${info['name']}",
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "  Type: ${info['type']}    Risk: ${info['risk']}",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (info['warning'] != null && info['warning']!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          "  ⚠ ${info['warning']}",
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.red[800],
                          ),
                        ),
                      ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget allergensWidget() {
    final screenwidth = MediaQuery.of(context).size.width;
    if (allergensList.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(
          "No allergens detected",
          style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
        ),
      );
    }

    return Container(
      width: screenwidth * 0.9,
      padding: EdgeInsets.all(8),
      margin: EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Allergens:",
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),

            ...allergensList.map(
              (item) => Text(
                "• $item",
                style: TextStyle(
                  color: Colors.red[800],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
