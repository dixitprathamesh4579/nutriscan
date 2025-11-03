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
  State<HomePage> createState() => Homepagestate();
}

class Homepagestate extends State<HomePage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final Screenheight = MediaQuery.of(context).size.height;
    final List<Widget> _pages = [
      SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Column(
          children: [
            Calender(),
            Calories(),
            SizedBox(height: Screenheight * 0.02),
            fatcarbs(),
            SizedBox(height: Screenheight * 0.02),
            Healthydf(),
          ],
        ),
      ),
      Center(child: Text("Progress Page", style: TextStyle(fontSize: 24))),
      ScanPageSwitcher(),
      Center(child: Text("History Page", style: TextStyle(fontSize: 24))),
      UserProfile(),
    ];
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: Image.asset('assets/images/appbarlogo.png'),
        title: Text('NutriScan'),
      ),
      body: IndexedStack(index: _currentIndex, children: _pages),

      bottomNavigationBar:SizedBox(height: 85,child:  BottomNavigationBar(
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
        iconSize: 25,
        

        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.text_increase),
            activeIcon: Icon(Icons.text_increase),
            label: 'Progress',
          ),

          BottomNavigationBarItem(
            icon: Image.asset('assets/images/scan.png', height: 36),
            activeIcon: Image.asset('assets/images/scan.png', height: 36),
            label: 'Scan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            activeIcon: Icon(Icons.history),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
      ),
    );
  }
}
