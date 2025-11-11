import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:main_app/HomePageAll/HomePage.dart';
import 'package:main_app/SignUp_and_Login/Signup.dart';
import 'package:main_app/SignUp_and_Login/googleauth.dart';
import 'package:main_app/forgotPassword_page/forgotpass.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Signin extends StatefulWidget {
  const Signin({super.key});

  @override
  State<Signin> createState() => _SigninState();
}

class _SigninState extends State<Signin> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController passCtrl = TextEditingController();

  final supabase = Supabase.instance.client;

  bool obscurePassword = true;
  bool rememberMe = false;
  bool isLoading = false;

  Future<void> _signIn() async {
    final email = emailCtrl.text.trim();
    final password = passCtrl.text.trim();

    setState(() => isLoading = true);
    try {
      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null && mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Login successful!')));
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomePage()),
        );
      } else {
        _showError('Invalid email or password');
      }
    } on AuthException catch (e) {
      _showError(e.message);
    } catch (e) {
      _showError('Unexpected error: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Login Failed'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final textScale = MediaQuery.of(context).textScaleFactor;

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.07,
                  vertical: screenHeight * 0.03,
                ),
                child: Column(
                  children: [
                    Image.asset(
                      'assets/images/appbarlogo.png',
                      height: screenHeight * 0.12,
                    ),
                    SizedBox(height: screenHeight * 0.015),

                    Text(
                      'NUTRISCAN',
                      style: GoogleFonts.roboto(
                        fontWeight: FontWeight.bold,
                        fontSize: screenWidth * 0.065,
                      ),
                    ),
                    Text(
                      'Health & Wellness',
                      style: GoogleFonts.poppins(
                        fontSize: screenWidth * 0.035,
                        color: Colors.grey.shade700,
                      ),
                    ),

                    SizedBox(height: screenHeight * 0.03),

                    Text(
                      'Welcome Back!',
                      style: GoogleFonts.poppins(
                        color: Colors.black,
                        fontSize: screenWidth * 0.055,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.005),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Enter your login information',
                        style: GoogleFonts.poppins(
                          fontSize: screenWidth * 0.035,
                          color: Colors.grey,
                        ),
                      ),
                    ),

                    SizedBox(height: screenHeight * 0.03),

                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: emailCtrl,
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return "Email is required";
                              } else if (!RegExp(
                                r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                              ).hasMatch(value.trim())) {
                                return "Enter a valid email";
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              hintText: 'Email Address',
                              prefixIcon: const Icon(Icons.email_outlined),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.025),

                          TextFormField(
                            controller: passCtrl,
                            obscureText: obscurePassword,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return "Password is required";
                              } else if (value.length < 6) {
                                return "Password must be at least 6 characters";
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              hintText: 'Password',
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  obscurePassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                ),
                                onPressed: () {
                                  setState(
                                    () => obscurePassword = !obscurePassword,
                                  );
                                },
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                          ),

                          SizedBox(height: screenHeight * 0.015),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Checkbox(
                                    value: rememberMe,
                                    onChanged: (v) =>
                                        setState(() => rememberMe = v!),
                                    activeColor: Colors.blue,
                                  ),
                                  Text(
                                    "Remember me",
                                    style: GoogleFonts.poppins(fontSize: 13),
                                  ),
                                ],
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ForgotPass(),
                                    ),
                                  );
                                },
                                child: Text(
                                  "Forgot Password?",
                                  style: GoogleFonts.poppins(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: screenHeight * 0.05),

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
                              onPressed: isLoading
                                  ? null
                                  : () {
                                      if (_formKey.currentState!.validate()) {
                                        _signIn();
                                      }
                                    },
                              child: isLoading
                                  ? const CircularProgressIndicator(
                                      color: Colors.white,
                                    )
                                  : Text(
                                      'Sign In',
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.bold,
                                        fontSize:
                                            screenWidth * 0.045 / textScale,
                                        color: Colors.white,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: screenHeight * 0.04),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Expanded(
                          child: Divider(thickness: 1, color: Colors.grey),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Text(
                            'Or Use',
                            style: GoogleFonts.poppins(
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                        const Expanded(
                          child: Divider(thickness: 1, color: Colors.grey),
                        ),
                      ],
                    ),

                    SizedBox(height: screenHeight * 0.03),

                    SizedBox(
                      width: double.infinity,
                      height: screenHeight * 0.055,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          side: const BorderSide(color: Colors.grey),
                        ),
                        onPressed: () async {
                          try {
                            await loginWithGoogleAndroid(context);
                          } catch (error) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Error: $error")),
                            );
                          }
                        },
                        icon: Image.asset(
                          'assets/images/google.png',
                          height: 18,
                        ),
                        label: Text(
                          'Continue with Google',
                          style: GoogleFonts.poppins(
                            fontSize: screenWidth * 0.04,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: screenHeight * 0.04),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account? ",
                          style: GoogleFonts.poppins(fontSize: 13),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const Signup()),
                            );
                          },
                          child: Text(
                            "Sign Up",
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
