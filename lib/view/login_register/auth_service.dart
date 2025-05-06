import 'package:dolphin/view/home/home_page.dart';
import 'package:dolphin/view/login_register/login_or_register.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthService extends StatelessWidget {
  const AuthService({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            print('Snapshot : ${snapshot.data}');
            return HomePage();
          } else {
            return LoginOrRegister();
          }
        },
      ),
    );
  }
}
