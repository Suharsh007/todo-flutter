// ignore_for_file: prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:tasker/screens/home_screen.dart';
import 'package:tasker/screens/login_screen.dart';

import 'package:firebase_auth/firebase_auth.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  FirebaseAuth auth = FirebaseAuth.instance;
  String navigate = "";
  String name = "";
  @override
  void initState() {
    super.initState();
    final user = auth.currentUser;
    if (user != null) {
      navigate = "Home";
    } else {}
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Tasker',
        debugShowCheckedModeBanner: false,
        home: AnimatedSplashScreen(
            duration: 3000,
            splash: Image.asset(
              "assets/images/app_logo.png",
            ),
            splashIconSize: 300,
            nextScreen: navigate == "Home" ? HomeScreen() : LoginScreen(),
            splashTransition: SplashTransition.fadeTransition,
            backgroundColor: Color(0xff38b6ff)));
  }
}
