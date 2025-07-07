import 'package:exam_flutter/ecrans/accueil.dart';
import 'package:flutter/material.dart';
import 'ecrans/accueil.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Exame Flutter',
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      home: const Accueil(),
    );
  }
}
