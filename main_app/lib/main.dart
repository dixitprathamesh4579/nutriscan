import 'package:flutter/material.dart';
import 'package:main_app/Gorouter/deeplink.dart';
import 'package:main_app/SignUp_and_Login/SignIn.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
   WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://gvpgxdclmoafiorertev.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imd2cGd4ZGNsbW9hZmlvcmVydGV2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTk0NzU4MzEsImV4cCI6MjA3NTA1MTgzMX0.vGrQYp5oPO7By0vLtoJbc79kpvZzKoaEg_tRwvm12Lw',
  );

  runApp(Nutri());
}
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
class Nutri extends StatefulWidget {
  @override
  State<Nutri> createState() => _NutriState();
}

class _NutriState extends State<Nutri> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NutriScan',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: Signin(),
    );
  }
}
