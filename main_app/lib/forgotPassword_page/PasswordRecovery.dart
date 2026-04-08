import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:main_app/SignUp_and_Login/SignIn.dart';
import 'package:main_app/forgotPassword_page/forgotpass.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Passwordrecovery extends StatefulWidget {
  const Passwordrecovery({super.key});

  @override
  State<Passwordrecovery> createState() => _PasswordrecoveryState();
}

class _PasswordrecoveryState extends State<Passwordrecovery> {
  final _recoverKey = GlobalKey<FormState>();

  final TextEditingController otpController = TextEditingController();
  final TextEditingController newPassController = TextEditingController();
  final TextEditingController confirmPassController = TextEditingController();

  bool _obscureNewPass = true;
  bool _obscureConfirmPass = true;

  @override
  void dispose() {
    otpController.dispose();
    newPassController.dispose();
    confirmPassController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final textScale = MediaQuery.of(context).textScaleFactor;

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: screenHeight * 0.05,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const ForgotPass()),
            );
          },
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.08,
                  vertical: screenHeight * 0.03,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/passrecovery.png',
                      height: screenHeight * 0.22,
                    ),
                    SizedBox(height: screenHeight * 0.04),

                    Text(
                      'Password Recovery',
                      style: GoogleFonts.poppins(
                        fontSize: screenWidth * 0.065,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.015),

                    Text(
                      'create a new password.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: screenWidth * 0.037 / textScale,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.05),

                    Form(
                      key: _recoverKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: newPassController,
                            obscureText: _obscureNewPass,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return "Password is required";
                              } else if (value.length < 6) {
                                return "Password must be at least 6 characters";
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              hintText: 'Enter New Password',
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureNewPass
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscureNewPass = !_obscureNewPass;
                                  });
                                },
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                          ),

                          SizedBox(height: screenHeight * 0.03),

                          TextFormField(
                            controller: confirmPassController,
                            obscureText: _obscureConfirmPass,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please re-enter your password';
                              } else if (value != newPassController.text) {
                                return 'Passwords do not match';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              hintText: 'Re-enter Password',
                              prefixIcon: const Icon(Icons.lock_reset),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureConfirmPass
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscureConfirmPass = !_obscureConfirmPass;
                                  });
                                },
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.06),

                    SizedBox(
                      width: double.infinity,
                      height: screenHeight * 0.06,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),

                        onPressed: () async {
                          if (_recoverKey.currentState!.validate()) {
                            final newPassword = newPassController.text.trim();

                            try {
                              await Supabase.instance.client.auth.updateUser(
                                UserAttributes(password: newPassword),
                              );

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "Password updated successfully!",
                                  ),
                                ),
                              );

                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const Signin(),
                                ),
                              );
                            } on AuthException catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(e.message)),
                              );
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    "Something went wrong. Please try again.",
                                  ),
                                ),
                              );
                            }
                          }
                        },
                        child: Text(
                          'Continue',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: screenWidth * 0.045 / textScale,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: screenHeight * 0.04),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Go back to ",
                          style: GoogleFonts.poppins(fontSize: 13),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (_) => const Signin()),
                            );
                          },
                          child: Text(
                            "Sign In",
                            style: GoogleFonts.poppins(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: screenHeight * 0.02),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
