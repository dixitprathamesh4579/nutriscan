import 'package:flutter/material.dart';
import 'package:main_app/Gorouter/deeplink.dart';
import 'package:main_app/HomePageAll/HomePage.dart';
import 'package:main_app/Profile/user_profile.dart';
import 'package:main_app/Progress/ProgressPage.dart';
import 'package:main_app/Scanned_Output_page.dart/Product_output.dart';
import 'package:main_app/Scanned_Output_page.dart/open_food_fact_api_call.dart';
import 'package:main_app/Scanner/Product_Image.dart';
import 'package:main_app/Scanner/Product_image_display.dart';
import 'package:main_app/Scanner/ScannerCamera.dart';
import 'package:main_app/SignUp_and_Login/SignIn.dart';
import 'package:main_app/SignUp_and_Login/Signup.dart';
import 'package:main_app/forgotPassword_page/PasswordRecovery.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:main_app/InternetWrapper.dart';
import 'Profile/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  // 🔔 Notifications init
  await NotificationService.init();
  await NotificationService.setupTimezone();

  // optional test
  await NotificationService.testNotification();
  await NotificationService.scheduleNotification();

  runApp(const Nutri());
}

class Nutri extends StatefulWidget {
  const Nutri({super.key});

  @override
  State<Nutri> createState() => _NutriState();
}

class _NutriState extends State<Nutri> {
  @override
  void initState() {
    super.initState();

    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final event = data.event;

      if (event == AuthChangeEvent.passwordRecovery) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const Passwordrecovery(),
            ),
          );
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NutriScan',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),

      home: InternetWrapper(
        child: const Signin(),
      ),
    );
  }
}