import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // 🔹 Sign Up
  Future<String?> signUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        emailRedirectTo: 'io.supabase.nutriscan://login-callback/',
      );

      final user = response.user;

      if (user == null) {
        return "Signup failed. Please try again.";
      }

      // Insert profile
      await _supabase.from('profiles').insert({
        'id': user.id,
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
        'created_at': DateTime.now().toIso8601String(),
      });

      return null;

    } on AuthException catch (e) {
      return _mapAuthError(e);
    } catch (e) {
      return "Something went wrong. Please try again.";
    }
  }

  // 🔹 Sign In
  Future<String?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final res = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (res.user == null) {
        return "Invalid login credentials.";
      }

      return null;

    } on AuthException catch (e) {
      return _mapAuthError(e);
    } catch (e) {
      return "Unable to sign in. Please try again.";
    }
  }

  // 🔹 Sign Out
  Future<String?> signOut() async {
    try {
      await _supabase.auth.signOut();
      return null;
    } catch (e) {
      return "Logout failed. Try again.";
    }
  }

  // 🔹 Current User
  User? get currentUser => _supabase.auth.currentUser;

  // 🔥 Centralized Error Mapping
  String _mapAuthError(AuthException e) {
    final message = e.message.toLowerCase();

    if (message.contains('invalid login credentials')) {
      return "Incorrect email or password.";
    }

    if (message.contains('email not confirmed')) {
      return "Please verify your email before logging in.";
    }

    if (message.contains('user already registered')) {
      return "This email is already registered.";
    }

    if (message.contains('password should be at least')) {
      return "Password must be at least 6 characters.";
    }

    if (message.contains('network')) {
      return "Check your internet connection.";
    }

    return "Authentication error. Please try again.";
  }
}