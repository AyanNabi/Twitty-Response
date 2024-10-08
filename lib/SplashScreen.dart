import 'package:flutter/material.dart';
import 'package:twitty_response/main.dart';

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Start the main app after a delay
    Future.delayed(Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => MyApp()), // Replace with your main app widget
      );
    });

    return Scaffold(
      backgroundColor: Colors.white, // Background color
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/bird.png', height: 150), // Replace with your logo asset
            SizedBox(height: 20),
            CircularProgressIndicator(), // Optional loading indicator
          ],
        ),
      ),
    );
  }
}
