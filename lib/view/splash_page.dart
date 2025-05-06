import 'package:dolphin/core/image/app_Image.dart';
import 'package:dolphin/view/login_register/login_or_register.dart';

import 'package:flutter/material.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    Future.microtask(() {
      Future.delayed(Duration(seconds: 2));
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginOrRegister()),
      );
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(AppImage.logo, scale: 6),
            Text(
              'Dolphin',
              style: TextStyle(
                color: Colors.blue,
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
