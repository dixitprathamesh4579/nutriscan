import 'package:flutter/material.dart';

class scan_output extends StatefulWidget {
  @override
  const scan_output({super.key});
  State<scan_output> createState() => scan_outputState();
}

class scan_outputState extends State<scan_output> {
  @override
  Widget build(BuildContext context) {
    final screenheight = MediaQuery.of(context).size.height;
    final screenwidth = MediaQuery.of(context).size.width;
    return Scaffold(
      resizeToAvoidBottomInset: true,
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
      body: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Container(
          width: screenwidth,
          height: screenheight,
          color: Colors.white,
          child: Center(
            child: Column(
              children: [
                SizedBox(height: screenheight * 0.05),
                ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.asset(
                    'assets/images/cola.jpg',
                    height: screenheight * 0.30,
                    width: screenwidth * 0.70,
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
