import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:sahm_app/constants/colors.dart';
import 'package:sahm_app/screens/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'سهم',
      theme: ThemeData(
        useMaterial3: true,
        splashColor: const Color.fromARGB(255, 229, 227, 222),
        scaffoldBackgroundColor: const Color.fromARGB(255, 222, 217, 202),
        colorScheme: ColorScheme.fromSeed(seedColor: ConstantColors.green),
        fontFamily: 'ReadexPro',
      ),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ar'),
      ],
      locale: const Locale('ar'),
      home: const HomeScreen(),
    );
  }
}
