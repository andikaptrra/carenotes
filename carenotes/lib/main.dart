import 'dart:io';
import 'package:carenotes/wrapper.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Platform.isAndroid
      ? await Firebase.initializeApp(
          options: FirebaseOptions(
          apiKey: 'AIzaSyAvl4Bffi8_WJAtjznhVSx2hzkLqoakwXw',
          appId: '1:1096472950743:android:3896356753c80bcc5c3d92',
          messagingSenderId: '1096472950743',
          projectId: 'carenotes-f86db',
          storageBucket: 'carenotes-f86db.appspot.com',
        ))
      : await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Wrapper());
  }
}
