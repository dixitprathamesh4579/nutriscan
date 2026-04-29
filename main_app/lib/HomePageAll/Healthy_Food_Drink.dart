import 'package:flutter/material.dart';
import 'package:main_app/HomePageAll/HomePage.dart';

void main() {
  runApp(const HealthyFoodbanner());
}

class HealthyFoodbanner extends StatelessWidget {
  const HealthyFoodbanner({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Healthy Food',
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: const Color(0xFFF4F9F4),
      ),
      home: const HealthyFoodPage(),
    );
  }
}

final List<Map<String, dynamic>> _foodItems = [
  {
    'name': 'Milk',
    'image': 'assets/images/milk.jpg',
    'richIn': 'Protein, Calcium, Vitamin D',
    'benefits': 'Strong bones, Muscle growth, Better recovery',
    'time': 'Morning or Before Sleep',
    'consume': '1 glass warm milk with almonds or turmeric',
  },
  {
    'name': 'Eggs',
    'image': 'assets/images/eggs.jpg',
    'richIn': 'High Protein, Healthy Fat, Vitamin B12',
    'benefits': 'Muscle building, Brain health, Energy',
    'time': 'Breakfast or Post Workout',
    'consume': '2–4 boiled eggs preferred',
  },
  {
    'name': 'Banana',
    'image': 'assets/images/banana.jpg',
    'richIn': 'Carbs, Potassium, Natural Sugar',
    'benefits': 'Instant energy, Digestion, Recovery',
    'time': 'Morning or Before Workout',
    'consume': 'Eat raw or in smoothie/milkshake',
  },
  {
    'name': 'Dry Fruits',
    'image': 'assets/images/Dry_fruit.jpg',
    'richIn': 'Healthy Fat, Fiber, Iron',
    'benefits': 'Heart health, Brain health, Immunity',
    'time': 'Morning',
    'consume': '5 almonds + 2 walnuts + raisins',
  },
  {
    'name': 'Paneer',
    'image': 'assets/images/paneer.jpg',
    'richIn': 'Protein, Calcium, Healthy Fat',
    'benefits': 'Muscle growth, Bone strength',
    'time': 'Lunch or Dinner',
    'consume': 'Paneer curry, grilled paneer or salad',
  },
];

class HealthyFoodPage extends StatelessWidget {
  const HealthyFoodPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Healthy Food / Drinks"),
        backgroundColor: Colors.white,
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
            );
          },
          icon: Icon(Icons.arrow_back_ios_new),
        ),
       
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _foodItems.length,
        itemBuilder: (context, index) {
          final item = _foodItems[index];

          return Container(
            margin: const EdgeInsets.only(bottom: 18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.07),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  child: Image.asset(
                    item['image'],
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['name'],
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),

                      infoTile("Rich In", item['richIn']),
                      infoTile("Benefits", item['benefits']),
                      infoTile("Best Time", item['time']),
                      infoTile("How to Consume", item['consume']),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget infoTile(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$title: ",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}