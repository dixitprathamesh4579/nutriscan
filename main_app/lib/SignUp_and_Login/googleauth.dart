import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';

final supabase = Supabase.instance.client;

Future<void> signInWithGoogleAndroid() async {
  try {
    const webClientId = '619329217313-osmjsl1lie4hnehki99k4qc5tu4th4m2.apps.googleusercontent.com';

    final googleSignIn = GoogleSignIn(
      clientId: webClientId,
      scopes: ['email', 'profile'],
    );

    final googleUser = await googleSignIn.signIn();
    if (googleUser == null) {
      print('User cancelled sign-in');
      return;
    }

    final googleAuth = await googleUser.authentication;

    final AuthResponse response = await supabase.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: googleAuth.idToken!,
      accessToken: googleAuth.accessToken,
    );

    if (response.session != null) {
      print('Signed in successfully');
      print('User ID: ${response.user?.id}');
    } else {
      print('Supabase sign-in failed');
    }
  } catch (e) {
    print('Error: $e');
  }
}
