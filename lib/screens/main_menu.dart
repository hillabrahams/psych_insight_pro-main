import 'package:flutter/material.dart';
import 'package:psych_insight_pro/screens/journal_analyzer_screen.dart';
import 'package:psych_insight_pro/screens/phone_number_screen.dart';
import '../styles.dart';
import 'reports_screen.dart';

class MainMenu extends StatelessWidget {
  const MainMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('PsychInsightPro', style: AppStyles.heading)),
      body: Center(
        // Add this Center widget
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, // Centers vertically
            crossAxisAlignment:
                CrossAxisAlignment.center, // Centers horizontally
            mainAxisSize:
                MainAxisSize.min, // Makes column only take needed space
            children: [
              ElevatedButton(
                style: AppStyles.buttonStyle,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => JournalAnalyzerScreen(),
                    ),
                  );
                },
                child: Text('New Entry'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: AppStyles.buttonStyle,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ReportsScreen()),
                  );
                },
                child: Text('Reports'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: AppStyles.buttonStyle,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PhoneNumberScreen(),
                    ),
                  );
                },
                child: Text('Setup Share Phone Number'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
