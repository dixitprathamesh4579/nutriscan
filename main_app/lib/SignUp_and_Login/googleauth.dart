import 'package:main_app/HomePageAll/HomePage.dart';
import 'package:main_app/SignUp_and_Login/SignIn.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart';

final supabase = Supabase.instance.client;
const webClientId =
    '619329217313-osmjsl1lie4hnehki99k4qc5tu4th4m2.apps.googleusercontent.com';

Future<void> signUpWithGoogleAndroid(BuildContext context) async {
  try {
    final googleSignIn = GoogleSignIn(
      clientId: webClientId,
      scopes: ['email', 'profile'],
    );

try {
  if (await googleSignIn.isSignedIn()) {
    await googleSignIn.disconnect();
    await googleSignIn.signOut();
  }
} catch (e) {
  debugPrint('Google disconnect warning: $e');
}


    final googleUser = await googleSignIn.signIn();

    if (googleUser == null) {
      debugPrint('User cancelled sign-up');
      return;
    }

    final googleAuth = await googleUser.authentication;

    final AuthResponse response = await supabase.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: googleAuth.idToken!,
      accessToken: googleAuth.accessToken,
    );

    if (response.session != null) {
      final user = response.user;
      debugPrint('Signed up successfully!');
      debugPrint('User ID: ${user?.id}');
      debugPrint('Email: ${user?.email}');

      final profile = await supabase
          .from('profiles')
          .select()
          .eq('id', user!.id)
          .maybeSingle();

      if (profile == null) {
        final fullName = googleUser.displayName ?? '';
        final parts = fullName.split(' ');
        final firstName = parts.isNotEmpty ? parts.first : '';
        final lastName = parts.length > 1 ? parts.sublist(1).join(' ') : '';

        await supabase.from('profiles').insert({
          'id': user.id,
          'email': user.email,
          'created_at': DateTime.now().toIso8601String(),
          'first_name': firstName,
          'last_name': lastName,
          'avatar_url': googleUser.photoUrl,
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('New User profile created please login'),
          ),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Signin()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Already SignedUp Please Login'),
          ),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Signin()),
        );
      }
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Sign-up failed')));
    }
  } catch (e) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Error during Google sign-up $e')));
  }
}

Future<void> loginWithGoogleAndroid(BuildContext context) async {
  try {
    final googleSignIn = GoogleSignIn(
      clientId: webClientId,
      scopes: ['email', 'profile'],
    );

    final googleUser = await googleSignIn.signIn();
    if (googleUser == null) {
      debugPrint('User cancelled Google Login');
      return;
    }

    final googleAuth = await googleUser.authentication;

    final AuthResponse response = await supabase.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: googleAuth.idToken!,
      accessToken: googleAuth.accessToken,
    );

    if (response.session == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Google Login failed. Try again.')),
      );
      return;
    }

    final user = response.user!;
    debugPrint('User logged in: ${user.email}');

    final profile = await supabase
        .from('profiles')
        .select()
        .eq('id', user.id)
        .maybeSingle();

    if (profile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Account not found. Please sign up first.'),
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Signin()),
      );
    } else {
       final fullName = googleUser.displayName ?? '';
        final parts = fullName.split(' ');
        final firstName = parts.isNotEmpty ? parts.first : '';
        final lastName = parts.length > 1 ? parts.sublist(1).join(' ') : '';
      await supabase
          .from('profiles')
          .update({
            'first_name': firstName,
            'last_name': lastName,
            'avatar_url': googleUser.photoUrl,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', user.id);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Welcome! Login successful.')),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    }
  } catch (e) {
    debugPrint('Error during Google Login: $e');
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Error during Google Login: $e')));
  }
}



Future<void> logoutUser(BuildContext context) async {
  try {
    await supabase.auth.signOut();

    final googleSignIn = GoogleSignIn(
      clientId: webClientId,
      scopes: ['email', 'profile'],
    );

    try {
      if (await googleSignIn.isSignedIn()) {
        await googleSignIn.signOut();
        await googleSignIn.disconnect();
      }
    } catch (e) {
      debugPrint('Google sign-out warning: $e');
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Logged out successfully')),
    );

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const Signin()),
      (route) => false,
    );
  } catch (e) {
    debugPrint('Logout error: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error during logout: $e')),
    );
  }
}