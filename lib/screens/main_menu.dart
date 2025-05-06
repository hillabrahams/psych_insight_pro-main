import 'package:flutter/material.dart';
import 'package:psych_insight_pro/screens/journal_analyzer_screen.dart';
import '../styles.dart';
import 'reports_screen.dart';

class MainMenu extends StatelessWidget {
  const MainMenu({super.key});

  @override
  Widget build(BuildContext context) {
    // ✅ Ensure you are using this 'context'
    return Scaffold(
      appBar: AppBar(title: Text('PsychInsightPro', style: AppStyles.heading)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              style: AppStyles.buttonStyle,
              onPressed: () {
                Navigator.push(
                  context, // ✅ Make sure this is the correct 'context'
                  //MaterialPageRoute(builder: (context) => NewEntryScreen()),
                  MaterialPageRoute(
                    builder: (context) => JournalAnalyzerScreen(),
                  ),
                );
              },
              child: Text('New Entry'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              style: AppStyles.buttonStyle,
              onPressed: () {
                Navigator.push(
                  context, // ✅ Make sure this is the correct 'context'
                  MaterialPageRoute(builder: (context) => ReportsScreen()),
                );
              },
              child: Text('Reports'),
            ),
          ],
        ),
      ),
    );
  }
}
