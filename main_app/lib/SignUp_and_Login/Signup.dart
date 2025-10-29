import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'SignIn.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:main_app/GoogleAuth/google_auth.dart';


class Signup extends StatefulWidget {
  const Signup({super.key});
  @override
  State<Signup> createState() => SignupState();
}

class SignupState extends State<Signup> {
  final FormKey_SignUp = GlobalKey<FormState>();

  final TextEditingController F_name = TextEditingController();
  final TextEditingController L_name = TextEditingController();
  final TextEditingController E_mail = TextEditingController();
  final TextEditingController Pass = TextEditingController();

  bool _obscurePassword = true;
  bool isChecked = false;
  final supabase = Supabase.instance.client;
  bool isLoading = false;


  void Clear() {
    F_name.clear();
    L_name.clear();
    E_mail.clear();
    Pass.clear();
  }

 Future<void> _signUp() async {
    final firstName = F_name.text.trim();
    final lastName = L_name.text.trim();
    final email = E_mail.text.trim();
    final password = Pass.text.trim();

    setState(() => isLoading = true);

     try {
      final response = await supabase.auth.signUp(
        email: email,
        password: password,
      );
      final user = response.user;
      if (user != null) {
        await supabase.from('profiles').insert({
          'id': user.id,
          'first_name': firstName,
          'last_name': lastName,
        });
 ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Sign up successful! Please log in.")),
        );
        Navigator.pushReplacement(context, MaterialPageRoute(builder:(context)=>Signin()));
      }
     }on AuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error signing up")),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }


Future<void> _googleSignUp() async {
  setState(() => isLoading = true);

  try {
    // Google sign-in
    final googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) return;

    final googleAuth = await googleUser.authentication;

    // Supabase auth with Google
    final res = await supabase.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: googleAuth.idToken!,
      accessToken: googleAuth.accessToken!,
    );

    final user = res.user;
    if (user == null) return;

    // Check profile in Supabase
    final profile = await supabase
        .from('profiles')
        .select()
        .eq('id', user.id)
        .maybeSingle();

    // Insert new user if not exists
    if (profile == null) {
      final names = (googleUser.displayName ?? '').split(' ');
      await supabase.from('profiles').insert({
        'id': user.id,
        'email': user.email,
        'first_name': names.isNotEmpty ? names.first : '',
        'last_name': names.length > 1 ? names.last : '',
        'avatar_url': googleUser.photoUrl,
        'created_at': DateTime.now().toIso8601String(),
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Welcome ${googleUser.displayName}!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Logged in successfully!')),
      );
    }

    // Navigate to Signin
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const Signin()),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Google sign-in failed: $e')),
    );
  } finally {
    setState(() => isLoading = false);
  }
}


  @override
  Widget build(BuildContext context) {
    final screenheight = MediaQuery.of(context).size.height;
    final screenwidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        toolbarHeight: screenheight * 0.05,
        backgroundColor: Colors.white,
        leading: Builder(
          builder: (context) => IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (Context) => Signin()),
              );
            },
            icon: Icon(Icons.arrow_back_ios_new),
          ),
        ),
      ),
      body: SafeArea(
        child: SizedBox.expand(
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: Container(
              color: Colors.white,
              width: screenwidth,
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Image.asset(
                    'assets/images/appbarlogo.png',
                    height: screenheight * 0.12,
                  ),
                  Text(
                    'NUTRISCAN',
                    style: GoogleFonts.roboto(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    'Health & Wellness',
                    style: GoogleFonts.poppins(
                      fontSize: screenwidth * 0.03,
                      color: Colors.black,
                    ),
                  ),

                  SizedBox(height: screenheight * 0.02),

                  Text(
                    'Sign Up Account',
                    style: GoogleFonts.poppins(
                      color: Colors.black,
                      fontSize: screenwidth * 0.05,
                    ),
                  ),

                  SizedBox(height: screenheight * 0.02),

                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Create your Account',
                      style: GoogleFonts.roboto(
                        fontSize: screenwidth * 0.03,
                        color: Colors.grey,
                      ),
                    ),
                  ),

                  SizedBox(height: screenheight * 0.02),

                  Form(
                    key: FormKey_SignUp,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: F_name,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return "First name is required";
                                  } else if (value.length < 2) {
                                    return "Must be at least 2 characters";
                                  } else if (!RegExp(
                                    r'^[a-zA-Z ]+$',
                                  ).hasMatch(value)) {
                                    return "Only letters allowed";
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(
                                  hintText: 'First Name',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                              ),
                            ),

                            SizedBox(width: screenwidth * 0.03),

                            Expanded(
                              child: TextFormField(
                                controller: L_name,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return "Last name is required";
                                  } else if (value.length < 2) {
                                    return "Must be at least 2 characters";
                                  } else if (!RegExp(
                                    r'^[a-zA-Z ]+$',
                                  ).hasMatch(value)) {
                                    return "Only letters allowed";
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(
                                  hintText: 'Last Name',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: screenheight * 0.02),

                        TextFormField(
                          controller: E_mail,
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
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),

                        SizedBox(height: screenheight * 0.02),

                        TextFormField(
                          controller: Pass,
                          obscureText: _obscurePassword,
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
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),

                        SizedBox(height: screenheight * 0.02),

                        Row(
                          children: [
                            Checkbox(
                              value: isChecked,
                              onChanged: (bool? value) {
                                setState(() {
                                  isChecked = value!;
                                });
                              },
                            ),
                            const Text("I agree to the "),
                            GestureDetector(
                              onTap: () {},
                              child: const Text(
                                "Terms of Services",
                                style: TextStyle(
                                  color: Colors.blue,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                            const Spacer(),
                            GestureDetector(
                              onTap: Clear,
                              child: const Text(
                                "Clear",
                                style: TextStyle(
                                  color: Colors.black,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: screenheight * 0.02),

                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(
                        vertical: 15,
                        horizontal: 100,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      if (FormKey_SignUp.currentState!.validate() &&
                          isChecked) {
                            _signUp();
                      }
                      ;
                      if (isChecked) {
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please Accept Terms of services'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }
                    },

                    child: const Text(
                      'Sign Up',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  SizedBox(height: screenheight * 0.02),

                  Row(
                    children: const [
                      Expanded(
                        child: Divider(color: Colors.grey, thickness: 2),
                      ),
                      Text('Or Use'),
                      Expanded(
                        child: Divider(color: Colors.grey, thickness: 2),
                      ),
                    ],
                  ),

                  SizedBox(height: screenheight * 0.02),

                 Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: _googleSignUp,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                        
                          Image.asset('assets/images/google.png', height: 15),
                          const Text('  Google'),
                        ],
                      ),
                    ),

                      SizedBox(width: screenwidth * 0.15),

                     
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
