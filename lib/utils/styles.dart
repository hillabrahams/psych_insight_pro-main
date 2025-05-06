import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppStyles {
  // Color Palette
  static final Color primaryColor = Colors.indigo;
  static final Color accentColor = Colors.purpleAccent;
  static final Color positiveColor = Colors.green;
  static final Color negativeColor = Colors.red;
  static final Color neutralColor = Colors.grey;

  static final TextStyle heading = GoogleFonts.lato(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: primaryColor,
  );

  static final TextStyle subheading = GoogleFonts.lato(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: Colors.black87,
  );

  static final TextStyle bodyText = GoogleFonts.lato(
    fontSize: 16,
    color: Colors.black87,
  );

  static final ButtonStyle buttonStyle = ElevatedButton.styleFrom(
    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
    textStyle: TextStyle(fontSize: 18),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    foregroundColor: Colors.white, // Text color
    backgroundColor: primaryColor, // Button background color
  );

  // Light Theme
  static final ThemeData lightTheme = ThemeData(
    primarySwatch: Colors.indigo,
    brightness: Brightness.light,
    primaryColor: primaryColor,
    hintColor: accentColor,
    textTheme: GoogleFonts.latoTextTheme(),
    scaffoldBackgroundColor: Colors.white,
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: buttonStyle.copyWith(
        backgroundColor: WidgetStateProperty.all(primaryColor),
      ),
    ),
    cardColor: Colors.white,
    dialogTheme: DialogThemeData(backgroundColor: Colors.white),
  );

  // Dark Theme
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: primaryColor,
    textTheme: GoogleFonts.latoTextTheme().apply(
      bodyColor: Colors.white,
      displayColor: Colors.white,
    ),
    scaffoldBackgroundColor: Colors.black,
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: buttonStyle.copyWith(
        backgroundColor: WidgetStateProperty.all(accentColor),
      ),
    ),
    cardColor: Colors.grey[800],
    colorScheme: ColorScheme.fromSwatch(
      primarySwatch: Colors.indigo,
    ).copyWith(secondary: accentColor),
    dialogTheme: DialogThemeData(backgroundColor: Colors.grey[850]),
  );
}
