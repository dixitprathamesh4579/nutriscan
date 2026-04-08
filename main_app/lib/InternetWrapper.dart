import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class InternetWrapper extends StatefulWidget {
  final Widget child;

  const InternetWrapper({super.key, required this.child});

  @override
  State<InternetWrapper> createState() => _InternetWrapperState();
}

class _InternetWrapperState extends State<InternetWrapper> {
  bool isOffline = false;

  late StreamSubscription<List<ConnectivityResult>> subscription;

  @override
  void initState() {
    super.initState();

    checkInternet();

    subscription = Connectivity()
        .onConnectivityChanged
        .listen((List<ConnectivityResult> results) async {
      bool hasNet = await hasInternet();

      setState(() {
        isOffline = !hasNet;
      });

      print("Connectivity: $results | Internet: $hasNet");
    });
  }

  /// 🔍 Check real internet (not just WiFi)
  Future<bool> hasInternet() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  /// 🔁 Initial check
  Future<void> checkInternet() async {
    bool hasNet = await hasInternet();

    setState(() {
      isOffline = !hasNet;
    });
  }

  @override
  void dispose() {
    subscription.cancel(); 
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (isOffline)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              color: const Color.fromARGB(255, 248, 169, 113),
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: const SafeArea(
                child: Text(
                  "No Internet Connection",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}