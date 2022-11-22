import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:todo_app/ui/home_page.dart';
import 'package:page_transition/page_transition.dart';
class LandingPage extends StatelessWidget {
  const LandingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedSplashScreen(
        backgroundColor: Colors.black,
        splash: Column(
          children: [
            CircleAvatar(
              backgroundImage: AssetImage("img/logo.png"),
            ),
            const Text('Daily Dairy',style: TextStyle(fontSize: 40,fontWeight: FontWeight.bold,color: Colors.white),)
          ],
        ),
        nextScreen: const HomePage(),
        splashIconSize: 400,
        duration: 4000,
        splashTransition: SplashTransition.rotationTransition,
        pageTransitionType: PageTransitionType.leftToRightWithFade,
        animationDuration: const Duration(seconds: 4),

      ),
    );
  }
}
