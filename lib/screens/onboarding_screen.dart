import 'package:flutter/material.dart';

import 'main_menu.dart';

import '../utils/styles.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        // Centers entire content vertically and horizontally
        child: Padding(
          padding: EdgeInsets.all(24),

          child: Column(
            mainAxisSize: MainAxisSize.min, // Prevents full screen stretch

            crossAxisAlignment:
                CrossAxisAlignment.center, // Center horizontally

            children: [
              Text(
                'Welcome to PsychInsightPro',

                textAlign: TextAlign.center,

                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),

              SizedBox(height: 20),

              Text(
                'Analyze your journal entries with AI-driven insights.',

                textAlign: TextAlign.center,
              ),

              SizedBox(height: 40),

              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,

                    MaterialPageRoute(builder: (context) => MainMenu()),
                  );
                },

                style: AppStyles.buttonStyle,

                child: Text('Get Started', textAlign: TextAlign.center),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
