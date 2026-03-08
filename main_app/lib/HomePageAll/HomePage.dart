import 'package:flutter/material.dart';
import 'package:main_app/History/ScanHistoryPage.dart';
import 'package:main_app/HomePageAll/Calender.dart';
import 'package:main_app/HomePageAll/calories_banner.dart';
import 'package:main_app/HomePageAll/fat-carbs.dart';
import 'package:main_app/HomePageAll/healthy-drink-food.dart';
import 'package:main_app/HomePageAll/sugar_banner.dart';
import 'package:main_app/HomePageAll/protein_banner.dart';
import 'package:main_app/Profile/user_profile.dart';
import 'package:main_app/Progress/ProgressPage.dart';
import 'package:main_app/Scanner/ScanPageSwitcher.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  String selectedDate = DateTime.now().toString().split(" ")[0];

  double totalCalories = 0;
  double totalFat = 0;
  double totalCarbs = 0;
  double totalSugar = 0;
  double totalProtein = 0;

  @override
  void initState() {
    super.initState();
    loadDailyTotals(selectedDate);
  }

  Future<void> loadDailyTotals(String date) async {
    final supabase = Supabase.instance.client;
    final uid = supabase.auth.currentUser?.id;
    if (uid == null) return;

    final result = await supabase
        .from("daily_nutrition")
        .select()
        .eq("profile_id", uid)
        .eq("date", date)
        .maybeSingle();

    setState(() {
      totalCalories = result?["total_calories"] ?? 0.0;
      totalFat = result?["total_fat"] ?? 0.0;
      totalCarbs = result?["total_carbs"] ?? 0.0;
      totalSugar = result?["total_sugar"] ?? 0.0;
      totalProtein = result?["total_protein"] ?? 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;
    final scale = MediaQuery.of(context).textScaleFactor;

    final List<Widget> _pages = [
      SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: w * 0.03),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: h * 0.01),

            Calender(
              onDateChange: (date) {
                selectedDate = date;
                loadDailyTotals(date);
              },
            ),

            SizedBox(height: h * 0.015),

            Calories(totalCalories: totalCalories),

            SizedBox(height: h * 0.02),

            FatCarbs(fat: totalFat, carbs: totalCarbs),

            SizedBox(height: h * 0.02),

            ProteinBanner(protein: totalProtein),

            SizedBox(height: h * 0.02),

            SugarBanner(sugar: totalSugar),

            SizedBox(height: h * 0.02),

            Healthydf(),

            SizedBox(height: h * 0.03),
          ],
        ),
      ),

      ProgressPage(),
      ScanPageSwitcher(),
      ScanHistoryPage(),
      UserProfile(),
    ];

    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        toolbarHeight: h * 0.07,
        elevation: 0,
        leading: Padding(
          padding: EdgeInsets.all(w * 0.015),
          child: Image.asset(
            'assets/images/appbarlogo.png',
            height: h * 0.05,
          ),
        ),
        title: Text(
          'NutriScan',
          style: TextStyle(
            fontSize: w * 0.05 / scale,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ),

      body: SafeArea(
        child: IndexedStack(index: _currentIndex, children: _pages),
      ),

      bottomNavigationBar: SizedBox(
        height: h * 0.11,
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() => _currentIndex = index);
          },
          selectedItemColor: Colors.blue,
          unselectedItemColor: Colors.grey,
          backgroundColor: Colors.white,
          elevation: 0,

          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home, size: w * 0.065),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.text_increase, size: w * 0.065),
              label: 'Progress',
            ),
            BottomNavigationBarItem(
              icon: Image.asset(
                'assets/images/scan.png',
                height: h * 0.045,
              ),
              label: 'Scan',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history, size: w * 0.065),
              label: 'History',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person, size: w * 0.065),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
