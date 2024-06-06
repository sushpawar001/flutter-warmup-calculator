import 'package:flutter/material.dart';
import 'package:load_calc/homepage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(1, 94, 74, 227)),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}
