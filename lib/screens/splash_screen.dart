import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';

import '../tabs.dart';
import 'auth_screen.dart';

class MySplash extends StatefulWidget {
  final bool? isAuth;

  const MySplash({Key? key, required this.isAuth}) : super(key: key);

  @override
  _MySplashState createState() => _MySplashState();
}

class _MySplashState extends State<MySplash> {
  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
      duration: 50,
      nextScreen: widget.isAuth == true ? const HomePage() : const AuthScreen(),
      splashTransition: SplashTransition.fadeTransition,
      splash: const Text('...انتظار', style: TextStyle(fontSize: 80)),
      splashIconSize: 400,
      backgroundColor: const Color(0xFF1D1E33),
    );
  }
}
