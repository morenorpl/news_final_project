import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:news_app_with_getx/controller/news_controller.dart';
import 'package:news_app_with_getx/screens/news_home_screen.dart';

void main() {
  Get.put(NewsController());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xff0B0C0E),
          foregroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
        ),
        scaffoldBackgroundColor: Color(0xff0B0C0E),
        primaryColor: Colors.black,
        colorScheme: ColorScheme.fromSeed(seedColor: Color(0xff0B0C0E)),
        fontFamily: 'Poppins',
      ),
      home: NewsHomeScreen(),
    );
  }
}
