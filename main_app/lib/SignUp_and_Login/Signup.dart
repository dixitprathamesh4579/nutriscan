import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:main_app/SignUp_and_Login/Authservice_email.dart';
import 'SignIn.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:main_app/SignUp_and_Login/googleauth.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});
  @override
  State<Signup> createState() => SignupState();
}

class SignupState extends State<Signup> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController fnameCtrl = TextEditingController();
  final TextEditingController lnameCtrl = TextEditingController();
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController passCtrl = TextEditingController();

  bool obscurePassword = true;
  bool agreeTerms = false;
  bool isLoading = false;

  final supabase = Supabase.instance.client;

  void clearFields() {
    fnameCtrl.clear();
    lnameCtrl.clear();
    emailCtrl.clear();
    passCtrl.clear();
  }

  final AuthService _authService = AuthService();

  Future<void> _signUp() async {
    final firstName = fnameCtrl.text.trim();
    final lastName = lnameCtrl.text.trim();
    final email = emailCtrl.text.trim();
    final password = passCtrl.text.trim();

    setState(() => isLoading = true);

    final error = await _authService.signUp(
      email: email,
      password: password,
      firstName: firstName,
      lastName: lastName,
    );

    setState(() => isLoading = false);

    if (error == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Sign up successful! confirm your email and log in."),
        ),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const Signin()),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
    }
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
        toolbarHeight: screenHeight * 0.05,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          color: Colors.black,
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const Signin()),
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
                  horizontal: screenWidth * 0.07,
                  vertical: screenHeight * 0.03,
                ),
                child: Column(
                  children: [
                    Image.asset(
                      'assets/images/appbarlogo.png',
                      height: screenHeight * 0.12,
                    ),
                    Text(
                      'NUTRISCAN',
                      style: GoogleFonts.roboto(
                        fontWeight: FontWeight.bold,
                        fontSize: screenWidth * 0.06,
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
                      'Sign Up Account',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: screenWidth * 0.055,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.005),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Create your account',
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
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: fnameCtrl,
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return "First name required";
                                    } else if (value.length < 2) {
                                      return "Min 2 letters";
                                    } else if (!RegExp(
                                      r'^[a-zA-Z ]+$',
                                    ).hasMatch(value)) {
                                      return "Letters only";
                                    }
                                    return null;
                                  },
                                  decoration: InputDecoration(
                                    hintText: 'First Name',
                                    prefixIcon: const Icon(Icons.person),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: screenWidth * 0.03),
                              Expanded(
                                child: TextFormField(
                                  controller: lnameCtrl,
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return "Last name required";
                                    } else if (value.length < 2) {
                                      return "Min 2 letters";
                                    } else if (!RegExp(
                                      r'^[a-zA-Z ]+$',
                                    ).hasMatch(value)) {
                                      return "Letters only";
                                    }
                                    return null;
                                  },
                                  decoration: InputDecoration(
                                    hintText: 'Last Name',
                                    prefixIcon: const Icon(
                                      Icons.person_outline,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: screenHeight * 0.025),

                          TextFormField(
                            controller: emailCtrl,
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return "Email is required";
                              } else if (!RegExp(
                                r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                              ).hasMatch(value.trim())) {
                                return "Enter valid email";
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
                                return "Password required";
                              } else if (value.length < 6) {
                                return "Min 6 characters";
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

                          SizedBox(height: screenHeight * 0.02),

                          Row(
                            children: [
                              Checkbox(
                                value: agreeTerms,
                                onChanged: (v) =>
                                    setState(() => agreeTerms = v!),
                                activeColor: Colors.blue,
                              ),
                              Flexible(
                                child: Wrap(
                                  children: [
                                    Text(
                                      "I agree to the ",
                                      style: GoogleFonts.poppins(fontSize: 13),
                                    ),
                                    GestureDetector(
                                      onTap: () {},
                                      child: Text(
                                        "Terms of Service",
                                        style: GoogleFonts.poppins(
                                          color: Colors.blue,
                                          fontWeight: FontWeight.w500,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Spacer(),
                              GestureDetector(
                                onTap: clearFields,
                                child: Text(
                                  "Clear",
                                  style: GoogleFonts.poppins(
                                    decoration: TextDecoration.underline,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: screenHeight * 0.04),

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
                                        if (agreeTerms) {
                                          _signUp();
                                        } else {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Please accept Terms of Service',
                                              ),
                                              duration: Duration(seconds: 2),
                                            ),
                                          );
                                        }
                                      }
                                    },
                              child: isLoading
                                  ? const CircularProgressIndicator(
                                      color: Colors.white,
                                    )
                                  : Text(
                                      'Sign Up',
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

                    SizedBox(height: screenHeight * 0.03),

                    Row(
                      children: const [
                        Expanded(
                          child: Divider(color: Colors.grey, thickness: 1.2),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text('Or Use'),
                        ),
                        Expanded(
                          child: Divider(color: Colors.grey, thickness: 1.2),
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
                            await signInWithGoogleAndroid();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Signed in successfully!"),
                              ),
                            );

                         Navigator.push(context, MaterialPageRoute(builder: (context)=>Signin()));
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
                          "Already have an account? ",
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
