import 'package:flutter/material.dart';
// import 'package:paired_name_app/constants/colors.dart';

class LessThanMinimumScreensScaffoldWidget extends StatelessWidget {
  const LessThanMinimumScreensScaffoldWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      // backgroundColor: ConstantColors.pink,
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Text(
            'عذرا ، يتطلب التطبيق شاشة أكبر للعمل بشكل جيد .',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18),
          ),
        ),
      ),
    );
  }
}