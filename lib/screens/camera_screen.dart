import 'dart:async'; 
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:news_app_with_getx/screens/news_home_screen.dart'; 

class FaceAttendanceScreen extends StatefulWidget {
  final CameraDescription camera;

  const FaceAttendanceScreen({super.key, required this.camera});

  @override
  State<FaceAttendanceScreen> createState() => _FaceAttendanceScreenState();
}

class _FaceAttendanceScreenState extends State<FaceAttendanceScreen> {
  late CameraController controller;
  late Future<void> _initializeControllerFuture;
  
  XFile? imageFile;
  int faceCount = 0;
  bool isBusy = false;
  bool isRedirecting = false; 

  @override
  void initState() {
    super.initState();
    controller = CameraController(
      widget.camera,
      ResolutionPreset.high,
      enableAudio: false,
    );
    _initializeControllerFuture = controller.initialize();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _resetCamera() {
    if (isRedirecting) return;

    setState(() {
      imageFile = null;
      faceCount = 0;
      isBusy = false;
      isRedirecting = false;
    });
  }

  void _handleLoginFace() {
    setState(() {
      isRedirecting = true; 
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Wajah Terkonfirmasi! Masuk ke Kabari..."),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );

    Timer(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      
      Navigator.pushAndRemoveUntil(
        context, 
        MaterialPageRoute(builder: (context) => const NewsHomeScreen()), 
        (route) => false 
      );
    });
  }

  Future<void> _takePictureAndDetect() async {
    if (isBusy || isRedirecting) return;
    
    setState(() {
      isBusy = true;
    });

    try {
      await _initializeControllerFuture;
      final image = await controller.takePicture();
      
      final faces = await _detectFaces(File(image.path));

      setState(() {
        imageFile = image;
        faceCount = faces.length;
        isBusy = false;
      });

      if (faces.isNotEmpty) {
        _handleLoginFace();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
           const SnackBar(
             content: Text("Wajah tidak terdeteksi. Silakan foto ulang."),
             backgroundColor: Colors.red,
           )
        );
      }

    } catch (e) {
      setState(() {
        isBusy = false;
      });
      debugPrint("Error capturing image: $e");
    }
  }

  Future<List<Face>> _detectFaces(File imageFile) async {
    final inputImage = InputImage.fromFile(imageFile);
    final options = FaceDetectorOptions(
      performanceMode: FaceDetectorMode.accurate,
      enableLandmarks: true,
      enableClassification: true,
    );
    final faceDetector = FaceDetector(options: options);
    
    try {
      final faces = await faceDetector.processImage(inputImage);
      return faces;
    } finally {
      await faceDetector.close();
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: isRedirecting ? null : () => Navigator.pop(context),
                    icon: Icon(Icons.arrow_back, color: isRedirecting ? Colors.grey : Colors.black54),
                  ),
                  const Text(
                    "Login Wajah", 
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black87)
                  ),
                  const SizedBox(width: 40), 
                ],
              ),
            ),

            const SizedBox(height: 10),
            
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Stack(
                      alignment: Alignment.bottomCenter,
                      clipBehavior: Clip.none, 
                      children: [
                        Container(
                          height: size.width * 0.9,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.grey[200],
                            border: isRedirecting ? Border.all(color: Colors.green, width: 5) : null,
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: imageFile == null
                                ? FutureBuilder<void>(
                                    future: _initializeControllerFuture,
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState == ConnectionState.done) {
                                        return CameraPreview(controller);
                                      } else {
                                        return const Center(child: CircularProgressIndicator());
                                      }
                                    },
                                  )
                                : Image.file(
                                    File(imageFile!.path),
                                    fit: BoxFit.cover,
                                  ),
                          ),
                        ),
                        
                        if (imageFile == null)
                        Positioned(
                          bottom: -30,
                          child: GestureDetector(
                            onTap: _takePictureAndDetect,
                            child: Container(
                              height: 70,
                              width: 70,
                              decoration: BoxDecoration(
                                color: Colors.blueAccent,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 4),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 15,
                                    spreadRadius: 2,
                                  )
                                ]
                              ),
                              child: isBusy 
                                ? const Padding(padding: EdgeInsets.all(15), child: CircularProgressIndicator(color: Colors.white)) 
                                : const Icon(Icons.camera_alt, color: Colors.white, size: 32),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 60),
                    
                    if (imageFile != null) ...[
                      if (faceCount > 0)
                        Column(
                          children: [
                            const Icon(Icons.check_circle, color: Colors.green, size: 60),
                            const SizedBox(height: 10),
                            Text(
                              "Login Berhasil!", 
                              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green[800])
                            ),
                            const SizedBox(height: 5),
                            const Text("Masuk ke halaman utama...", style: TextStyle(color: Colors.grey)),
                            const SizedBox(height: 20),
                            const LinearProgressIndicator(), 
                          ],
                        )
                      
                      else
                        Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.red[50],
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.red[200]!)
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.warning_amber_rounded, color: Colors.red[700]),
                                  const SizedBox(width: 8),
                                  Text("Wajah Tidak Terdeteksi", style: TextStyle(color: Colors.red[700], fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: _resetCamera,
                                icon: const Icon(Icons.refresh),
                                label: const Text("Coba Lagi"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.black87,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 15)
                                ),
                              ),
                            )
                          ],
                        )
                    ] else ...[
                      const Text(
                        "Tap tombol kamera untuk login",
                        style: TextStyle(color: Colors.grey),
                      )
                    ]
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}