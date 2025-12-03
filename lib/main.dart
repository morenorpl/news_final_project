import 'package:news_app_with_getx/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:camera/camera.dart';
import 'firebase_options.dart';


import 'package:news_app_with_getx/screens/splash_screen.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await Permission.camera.request();
  final cameras = await availableCameras();
  
  final firstCamera = cameras.isNotEmpty ? cameras.first : null;

  if (firstCamera == null) {
    debugPrint("Tidak ada kamera yang ditemukan!");
  }

  runApp(MyApp(camera: firstCamera!));
}

class MyApp extends StatelessWidget {
  final CameraDescription camera;
  
  const MyApp({super.key, required this.camera});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Auth Final Project',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const SplashScreen(), 
    );
  }
}