import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

class ProductImageDisplay extends StatefulWidget {
  final String imagePath;

  const ProductImageDisplay({super.key, required this.imagePath});

  @override
  State<ProductImageDisplay> createState() => _ProductImageDisplayState();
}

class _ProductImageDisplayState extends State<ProductImageDisplay> {
  late Interpreter _interpreter;
  List<String> labels = [];

  Map<String, dynamic>? productData;
  Map<String, dynamic>? predictionResult;

  bool isLoading = true;
  String error = "";

  @override
  void initState() {
    super.initState();
    runPrediction();
  }

  // 🔹 Load Model + Labels
  Future<void> loadModel() async {
    _interpreter = await Interpreter.fromAsset('assets/food_model.tflite');

    final labelData = await rootBundle.loadString('assets/labels.txt');

    labels = labelData
        .split('\n')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  // 🔹 Prediction Logic
  Future<Map<String, dynamic>> predict(String imagePath) async {
    final imageFile = File(imagePath);
    img.Image? image = img.decodeImage(imageFile.readAsBytesSync());

    if (image == null) {
      return {"error": "Image not readable"};
    }

    img.Image resized = img.copyResize(image, width: 224, height: 224);

    var input = List.generate(
      1,
      (i) => List.generate(
        224,
        (y) => List.generate(224, (x) {
          final pixel = resized.getPixel(x, y);
          return [pixel.r / 255.0, pixel.g / 255.0, pixel.b / 255.0];
        }),
      ),
    );

    var output = List.generate(1, (i) => List.filled(labels.length, 0.0));

    _interpreter.run(input, output);

    int maxIndex = 0;
    double maxConfidence = 0;

    for (int i = 0; i < output[0].length; i++) {
      if (output[0][i] > maxConfidence) {
        maxConfidence = output[0][i];
        maxIndex = i;
      }
    }

    return {"label": labels[maxIndex], "confidence": maxConfidence * 100};
  }

  // 🔹 Load JSON Data
  Future<Map<String, dynamic>> loadProducts() async {
    final jsonString = await rootBundle.loadString(
      'assets/food_product_details.json',
    );
    return json.decode(jsonString);
  }

  // 🔹 Run Everything
  Future<void> runPrediction() async {
    try {
      await loadModel();

      final result = await predict(widget.imagePath);
      predictionResult = result;

      if (result.containsKey("error")) {
        error = result["error"];
        setState(() => isLoading = false);
        return;
      }

      String label = result["label"]
          .toString()
          .toLowerCase()
          .replaceAll(" ", "_")
          .trim();

      final allProducts = await loadProducts();

      if (result["confidence"] < 40) {
        error = "⚠️ Low confidence. Try another image.";
      } else if (allProducts.containsKey(label)) {
        productData = allProducts[label];
      } else {
        error = "❌ No data found for: $label";
      }

      setState(() => isLoading = false);
    } catch (e) {
      setState(() {
        error = " Error: $e";
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenheight = MediaQuery.of(context).size.height;
    final screenwidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
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
          : error.isNotEmpty
          ? Center(
              child: Text(
                error,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                        child: Image.file(
                          File(widget.imagePath),
                          fit: BoxFit.contain,
                          alignment: Alignment.center,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.broken_image,
                            size: 60,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Row(
                    children: [
                      SizedBox(width: screenwidth * 0.03),
                      Expanded(
                        child: Text(
                          productData?["name"] ?? "Unknown",
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(width: screenwidth * 0.02),
                      Text(
                        "Brand :${productData?["brand"] ?? "Unknown"}",
                        style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),

                  const SizedBox(height: 5),

                  Text(
                    "Confidence: ${predictionResult?["confidence"]?.toStringAsFixed(2) ?? "0"}%",
                    style: TextStyle(color: Colors.grey.shade600),
                  ),

                  const SizedBox(height: 5),

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
                          infoRow(
                            "Vegan Status",
                            productData?["vegan"] ?? "-",
                            Colors.green,
                          ),
                          infoRow(
                            "Processed Level",
                            productData?["processed"] ?? "-",
                            Colors.orange,
                          ),
                          infoRow(
                            "Sugar Level",
                            productData?["sugar"] ?? "-",
                            Colors.green,
                          ),
                          infoRow(
                            "Fat Level",
                            productData?["fat"] ?? "-",
                            Colors.red,
                          ),
                          infoRow(
                            "Health",
                            productData?["health_tag"] ?? "-",
                            Colors.green,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Text(
                    "Ingradients Used",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                  ingredientsWidget(),

                  const SizedBox(height: 20),
                  Text(
                    "Health Advice",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                  healthAdviceWidget(),

                  const SizedBox(height: 10),

                  if (productData?["allergens"] != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: sectionBox(
                        title: "Allergens",
                        color: Colors.red,
                        child: Builder(
                          builder: (context) {
                            var raw = productData?["allergens"];
                            List allergensList = [];

                            if (raw is List) {
                              allergensList = raw;
                            } else if (raw is String) {
                              allergensList = raw.split(",");
                            }

                            if (allergensList.isEmpty) {
                              return const Text("No allergens info");
                            }

                            return Container(
                              width: screenwidth,
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Colors.red,
                                  width: 1.2,
                                ),
                                color: Colors.red.withOpacity(0.05),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: allergensList.map<Widget>((e) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 2,
                                    ),
                                    child: Text(
                                      "${e.toString().trim()}",
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.red,
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            );
                          },
                        ),
                      ),
                    ),

                  const SizedBox(height: 20),

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
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        "SCAN AGAIN",
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: screenwidth * 0.045,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  // 🔹 UI Helpers
  Widget infoRow(String title, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title),
          Text(
            value,
            style: TextStyle(fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }

  Widget sectionBox({
    required String title,
    required Color color,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border.all(color: color.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold, color: color),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }

  Widget ingredientsWidget() {
    final screenwidth = MediaQuery.of(context).size.width;
    final screenheight = MediaQuery.of(context).size.height;

    var raw = productData?["ingredients"];
    List ingredientsList = [];

    if (raw is List) {
      ingredientsList = raw;
    } else if (raw is String) {
      ingredientsList = raw.split(",");
    }

    if (ingredientsList.isEmpty) {
      return const Text("No ingredients available");
    }

    return Container(
      width: screenwidth * 0.9,
      height: screenheight * 0.1,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color.fromARGB(255, 116, 116, 116)),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: ingredientsList
              .map<Widget>(
                (e) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Text(
                    "• ${e.toString().trim()}",
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  Widget healthAdviceWidget() {
    final screenwidth = MediaQuery.of(context).size.width;
    final screenheight = MediaQuery.of(context).size.height;

    String advice = productData?["advice"] ?? "";

    if (advice.isEmpty) {
      return const Text("No health advice available");
    }

    return Container(
      width: screenwidth * 0.9,
      height: screenheight * 0.1,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.green, // ✅ health theme color
          width: 1.2,
        ),
      ),
      child: SingleChildScrollView(
        child: Text(
          advice,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}
