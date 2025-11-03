import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  List<String> riskyIngredients = [];

  @override
  void initState() {
    super.initState();
    fetchproducts();
  }

  String getProcessedLevel() {
    final nova = product?["nova_group"];

    if (nova == null) {
      return "Unknown (not available)";
    }

    switch (nova) {
      case 1:
        return "- Unprocessed / Minimally Processed";
      case 2:
        return "- Processed Culinary Ingredients";
      case 3:
        return "- Processed Food";
      case 4:
        return "- Ultra-Processed Food";
      default:
        return "Unknown";
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
    final uri = Uri.parse(
      "https://world.openfoodfacts.org/api/v2/product/8901595862962.json",
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
      analyzeIngredients();
      fetchAlternatives();
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

  String? rawCategory = product?["categories_tags"] != null &&
          product!["categories_tags"].isNotEmpty
      ? product!["categories_tags"][0] as String
      : null;

  if (rawCategory == null) return;

  String category = rawCategory.replaceFirst(RegExp(r'^[a-z]{2}:'), '')
      .replaceAll('_', ' ')
      .trim();

  String? currentGrade = product?["nutrition_grades"] ?? product?["nutriscore_grade"];

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

  final uri = Uri.https('world.openfoodfacts.org', '/cgi/search.pl', searchParams);

  setState(() => loadingAlternatives = true);

  try {
    final response = await http.get(uri, headers: {
      'User-Agent': 'MyApp/1.0 (support@yourapp.com)'
    });

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      List<dynamic> products = (data['products'] as List<dynamic>?) ?? [];

      List<dynamic> filtered;
      if (currentGrade == null || currentGrade.isEmpty) {
        filtered = products;
      } else {
        final int currentRank = gradeRank(currentGrade);
        filtered = products.where((p) {
          final String? g = (p['nutrition_grades'] ?? p['nutriscore_grade']) as String?;
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

    final harmfulData = await rootBundle.loadString(
      "assets/harmful_ingredients.json",
    );
    final Map<String, dynamic> harmfulMap = jsonDecode(harmfulData);

    List<String> detected = [];

    harmfulMap.forEach((category, items) {
      for (var ing in items) {
        if (ingredientText.contains(ing.toLowerCase())) {
          detected.add(ing);
        }
      }
    });

    setState(() {
      riskyIngredients = detected.toSet().toList();
    });
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

  Widget harmfulIngredientsWidget() {
    final screenwidth = MediaQuery.of(context).size.width;
    if (riskyIngredients.isEmpty) {
      return Text(
        "No harmful ingredients detected ",
        style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
      );
    }

    return Container(
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
          SizedBox(height: 6, width: screenwidth * 0.9),
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
                      Row(
                        children: [
                          Text(
                            "Processed Level: ",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            getProcessedLevel(),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color:
                                  getProcessedLevel().contains("Ultra") ||
                                      getProcessedLevel().contains("Processed")
                                  ? Colors.red
                                  : Colors.green,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            "Sugar Level: ",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            getSugarLevel(),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: getLevelColor(getSugarLevel()),
                            ),
                          ),
                        ],
                      ),

                      Row(
                        children: [
                          Text(
                            "Fat Level: ",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            getFatLevel(),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: getLevelColor(getFatLevel()),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: screenheight * 0.01),
                     
                      harmfulIngredientsWidget(),
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
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
