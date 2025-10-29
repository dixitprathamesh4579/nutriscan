import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:main_app/SignUp_and_Login/SignIn.dart';
class GoogleAuth extends StatefulWidget {
  const GoogleAuth({super.key});
  @override
  State<GoogleAuth> createState() => GoogleAuthstate();
}
class GoogleAuthstate extends State<GoogleAuth> {
  bool isLoading = false;
    final supabase = Supabase.instance.client;


  Future<void> _googleSignUp() async {
  setState(() => isLoading = true);

  try {
    // Trigger Google sign-in
    final googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) return; // User canceled

    final googleAuth = await googleUser.authentication;

    // Authenticate with Supabase using Google tokens
    final res = await supabase.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: googleAuth.idToken!,
      accessToken: googleAuth.accessToken!,
    );

    final user = res.user;
    if (user == null) return;

    // Split display name into first and last names
    final fullName = (googleUser.displayName ?? '').trim();
    final parts = fullName.split(' ');
    final firstName = parts.isNotEmpty ? parts.first : '';
    final lastName = parts.length > 1 ? parts.sublist(1).join(' ') : '';

    // Check if user profile already exists
    final profile = await supabase
        .from('profiles')
        .select()
        .eq('id', user.id)
        .maybeSingle();

    // Insert if new user
    if (profile == null) {
      await supabase.from('profiles').insert({
        'id': user.id,
        'first_name': firstName,
        'last_name': lastName,
        'created_at': DateTime.now().toIso8601String(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Welcome $firstName!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Logged in successfully!')),
      );
    }

    // Navigate to home/sign-in page
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
       return Scaffold(
  
        
       );
  }

}