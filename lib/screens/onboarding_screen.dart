import 'package:flutter/material.dart';
import 'main_menu.dart';
import '../utils/styles.dart';

// class OnboardingScreen extends StatelessWidget {
//   const OnboardingScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         padding: EdgeInsets.all(24),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Text(
//               'Welcome to PsychInsightPro',
//               style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
//             ),
//             SizedBox(height: 20),
//             Text(
//               'Analyze your journal entries with AI-driven insights.',
//               textAlign: TextAlign.center,
//             ),
//             SizedBox(height: 40),
//             ElevatedButton(
//               onPressed: () {
//                 Navigator.pushReplacement(
//                   context,
//                   MaterialPageRoute(builder: (context) => MainMenu()),
//                 );
//               },
//               style: ElevatedButton.styleFrom(
//                 foregroundColor: Colors.white, // This sets the text color
//                 backgroundColor:
//                     Colors
//                         .blueAccent, // You can also set the button background color here
//               ),
//               child: Text('Get Started'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Welcome to PsychInsightPro',
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
              style: AppStyles.buttonStyle, // Use the same style as "Reports"
              child: Text('Get Started'),
            ),
          ],
        ),
      ),
    );
  }
}
