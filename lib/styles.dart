import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppStyles {
  // Color Palette
  static final Color primaryColor = Colors.indigo;
  static final Color accentColor = Colors.purpleAccent;
  static final Color positiveColor = Colors.green;
  static final Color negativeColor = Colors.red;
  static final Color neutralColor = Colors.grey;

  // Heading Style
  static var heading = GoogleFonts.lato(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: primaryColor,
  );

  // Subheading Style
  static var subheading = GoogleFonts.lato(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: Colors.black87,
  );

  // Button Style
  static var buttonStyle = ElevatedButton.styleFrom(
    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
    textStyle: GoogleFonts.lato(fontSize: 18, fontWeight: FontWeight.bold),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    backgroundColor: primaryColor,
    foregroundColor: Colors.white,
  );

  // Light Theme
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    colorScheme: ColorScheme.light(
      primary: primaryColor,
      secondary: accentColor,
      brightness: Brightness.light,
    ),
    textTheme: GoogleFonts.latoTextTheme(),
    scaffoldBackgroundColor: Colors.white,
  );

  // Dark Theme
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
      primary: primaryColor,
      secondary: accentColor,
      brightness: Brightness.dark,
    ),
    textTheme: GoogleFonts.latoTextTheme().apply(bodyColor: Colors.white),
    scaffoldBackgroundColor: Colors.black,
  );
}
