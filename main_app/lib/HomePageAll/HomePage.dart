import 'package:flutter/material.dart';
import 'package:main_app/HomePageAll/Calender.dart';
import 'package:main_app/HomePageAll/calories_banner.dart';
import 'package:main_app/HomePageAll/fat-carbs.dart';
import 'package:main_app/HomePageAll/healthy-drink-food.dart';
import 'package:main_app/Profile/user_profile.dart';
import 'package:main_app/Scanner/ScanPageSwitcher.dart';
import 'package:main_app/Scanner/ScannerCamera.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final textScale = MediaQuery.of(context).textScaleFactor;

    final List<Widget> _pages = [
      SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.03),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: screenHeight * 0.01),
              Calender(),
              SizedBox(height: screenHeight * 0.015),
              Calories(),
              SizedBox(height: screenHeight * 0.02),
              fatcarbs(),
              SizedBox(height: screenHeight * 0.02),
              Healthydf(),
              SizedBox(height: screenHeight * 0.03),
            ],
          ),
        ),
      ),
      Center(
        child: Text(
          "Progress Page",
          style: TextStyle(
            fontSize: screenWidth * 0.06 / textScale,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      ScanPageSwitcher(),
      Center(
        child: Text(
          "History Page",
          style: TextStyle(
            fontSize: screenWidth * 0.06 / textScale,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      UserProfile(),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        toolbarHeight: screenHeight * 0.07,
        elevation: 0,
        leading: Padding(
          padding: EdgeInsets.all(screenWidth * 0.015),
          child: Image.asset(
            'assets/images/appbarlogo.png',
            height: screenHeight * 0.05,
          ),
        ),
        title: Text(
          'NutriScan',
          style: TextStyle(
            fontSize: screenWidth * 0.05 / textScale,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ),

      body: SafeArea(
        child: IndexedStack(index: _currentIndex, children: _pages),
      ),

      bottomNavigationBar: SizedBox(
        height: screenHeight * 0.11,
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          selectedItemColor: Colors.blue,
          unselectedItemColor: Colors.grey,
          showUnselectedLabels: true,
          backgroundColor: Colors.white,
          elevation: 0,
          iconSize: screenHeight * 0.033,
          selectedFontSize: screenWidth * 0.03,
          unselectedFontSize: screenWidth * 0.03,

          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home, size: screenWidth * 0.065),
              activeIcon: Icon(Icons.home, size: screenWidth * 0.065),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.text_increase, size: screenWidth * 0.065),
              activeIcon: Icon(Icons.text_increase, size: screenWidth * 0.065),
              label: 'Progress',
            ),
            BottomNavigationBarItem(
              icon: Image.asset(
                'assets/images/scan.png',
                height: screenHeight * 0.045,
              ),
              activeIcon: Image.asset(
                'assets/images/scan.png',
                height: screenHeight * 0.045,
              ),
              label: 'Scan',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history, size: screenWidth * 0.065),
              activeIcon: Icon(Icons.history, size: screenWidth * 0.065),
              label: 'History',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person, size: screenWidth * 0.065),
              activeIcon: Icon(Icons.person, size: screenWidth * 0.065),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
