import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:main_app/SignUp_and_Login/SignIn.dart';
import 'package:main_app/forgotPassword_page/forgotpass.dart';

class Passwordrecovery extends StatefulWidget {
  State<Passwordrecovery> createState() => Passwordrecoverystate();
}

class Passwordrecoverystate extends State<Passwordrecovery> {
  final recover_key = GlobalKey<FormState>();

  final TextEditingController otpController = TextEditingController();
  final TextEditingController newPassController = TextEditingController();
  final TextEditingController checkpass_con = TextEditingController();

  @override
  void dispose() {
    otpController.dispose();
    newPassController.dispose();
    checkpass_con.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenwidth = MediaQuery.of(context).size.width;
    final screenheight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,

      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => forgotpass()),
              );
            },
            icon: Icon(Icons.arrow_back_ios_new),
          ),
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Container(
            padding: EdgeInsets.all(20),
            width: screenwidth,
            child: Column(
              children: [
                Image.asset(
                  'assets/images/passrecovery.png',
                  height: screenheight * 0.15,
                ),
                SizedBox(height: screenheight * 0.05),
                Text(
                  'Password Recovery',
                  style: GoogleFonts.roboto(
                    fontSize: screenheight * 0.03,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: screenheight * 0.04),
                Text(
                  'Enter Recieved OTP And New PassWord',
                  style: GoogleFonts.poppins(
                    fontSize: screenheight * 0.02,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: screenheight * 0.05),
                Form(
                  key: recover_key,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: otpController,
                        obscureText: false,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'OTP is required';
                          } else if (value.length != 6) {
                            return 'OTP must be 6 digits';
                          } else if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                            return 'OTP must contain only numbers';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          hintText: 'Enter OTP',
                          border: OutlineInputBorder(),
                        ),
                      ),

                      SizedBox(height: screenheight * 0.05),

                      TextFormField(
                        controller: newPassController,
                        obscureText: true, 
                        decoration: InputDecoration(
                          hintText: 'Enter New Password',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return "Password is required";
                          } else if (value.length < 6) {
                            return "Password must be at least 6 characters";
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: screenheight * 0.03),

                      TextFormField(
                        controller: checkpass_con,
                        obscureText: true, 
                        decoration: InputDecoration(
                          hintText: 'Re-Enter PassWord',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please re-enter your password';
                          } else if (value != newPassController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                SizedBox(height: screenheight * 0.05),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: EdgeInsets.symmetric(
                      vertical: 15,
                      horizontal: 100,
                    ),
                  ),
                  onPressed: () {
                    if (recover_key.currentState!.validate()) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Signin()),
                      );
                    }
                  },
                  child: Text(
                    'Continue',
                    style: GoogleFonts.poppins(
                      fontSize: screenheight * 0.02,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
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
