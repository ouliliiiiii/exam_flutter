import 'package:flutter/material.dart';
import 'ecrans/accueil.dart'; // adapte le chemin si besoin

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Hacker News Flutter',
      theme: ThemeData(
        fontFamily: 'Roboto',

        primaryColor: const Color(0xFF6D4C41), // Marron
        scaffoldBackgroundColor: const Color(0xFFF5F5DC), // Beige clair

        colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.brown)
            .copyWith(
              primary: const Color(0xFF6D4C41),
              secondary: const Color(0xFFD7CCC8),
            ),

        ///////////////////////// AppBar
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF6D4C41),
          foregroundColor: Colors.white,
        ),

        /////////////////////////// Card
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 4,
          margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),

        iconTheme: const IconThemeData(color: Color(0xFF6D4C41)),

        ///////////////////////// les  Textes
        textTheme: const TextTheme(
          titleLarge: TextStyle(
            color: Color(0xFF4E342E),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          bodyMedium: TextStyle(color: Colors.black, fontSize: 14),
        ),
      ),
      home: const Accueil(),
    );
  }
}
