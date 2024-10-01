import 'package:carenotes/screens/authenticatePages/Authpage.dart';
import 'package:carenotes/screens/mainPages/MenuPage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return MenuPage();
          } else {
            return AuthPage();
          }
        },
      ),
    );
  }
}