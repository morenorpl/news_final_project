import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:news_app_with_getx/Auth/login_screen.dart';


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

  @override
  void initState() {
    super.initState();
    controller = CameraController(
      widget.camera,
      ResolutionPreset.high, // Resolusi lebih tinggi agar deteksi akurat
      enableAudio: false,
    );
    _initializeControllerFuture = controller.initialize();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  // Fungsi Reset untuk tombol "Foto Ulang"
  void _resetCamera() {
    setState(() {
      imageFile = null;
      faceCount = 0;
      isBusy = false;
    });
  }

  // Fungsi Logika Absen/Login
  void _handleAbsen() {
    if (faceCount > 0) {
      // TODO: Masukkan logika verifikasi ke backend/firebase di sini
      // Contoh: Cek apakah wajah ini cocok dengan data user yang sudah register
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Absen Berhasil! Masuk ke aplikasi...")),
      );

      // Navigasi ke halaman utama setelah login sukses
      // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen()));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Wajah tidak terdeteksi, mohon foto ulang.")),
      );
    }
  }

  Future<void> _takePictureAndDetect() async {
    if (isBusy) return;
    
    setState(() {
      isBusy = true;
    });

    try {
      await _initializeControllerFuture;
      final image = await controller.takePicture();
      
      // Deteksi wajah langsung setelah foto diambil
      final faces = await _detectFaces(File(image.path));

      setState(() {
        imageFile = image;
        faceCount = faces.length;
        isBusy = false;
      });

    } catch (e) {
      setState(() {
        isBusy = false;
      });
      print("Error capturing image: $e");
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
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("cancel", style: TextStyle(color: Colors.blue, fontSize: 16)),
                  ),
                  const Text(
                    "Face Detection", 
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black54)
                  ),
                  TextButton(
                    onPressed: () {
                    },
                    child: const Text("lanjutkan", style: TextStyle(color: Colors.blue, fontSize: 16)),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
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
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
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
                        Positioned.fill(
                          child: CustomPaint(
                            painter: CornerPainter(),
                          ),
                        ),
                        if (imageFile == null)
                        Positioned(
                          bottom: -25,
                          child: GestureDetector(
                            onTap: _takePictureAndDetect,
                            child: Container(
                              height: 60,
                              width: 60,
                              decoration: BoxDecoration(
                                color: Colors.blueAccent,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 4),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 10,
                                    spreadRadius: 2,
                                  )
                                ]
                              ),
                              child: isBusy 
                                ? const Padding(padding: EdgeInsets.all(15), child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                                : const Icon(Icons.camera_alt, color: Colors.white, size: 28),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 50),
                    if (imageFile != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF64B5F6), 
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                             BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 5, offset: const Offset(0, 3))
                          ]
                        ),
                        child: Column(
                          children: [
                            const Text("Wajah Terdeteksi", style: TextStyle(color: Colors.white, fontSize: 12)),
                            Text(
                              "$faceCount", 
                              style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _resetCamera,
                              icon: const Icon(Icons.camera_alt_outlined, color: Colors.white),
                              label: const Text("Foto Ulang", style: TextStyle(color: Colors.white)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFF5252), 
                                padding: const EdgeInsets.symmetric(vertical: 15),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _handleAbsen,
                              icon: const Icon(Icons.check_circle_outline, color: Colors.white),
                              label: const Text("Absen", style: TextStyle(color: Colors.white)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF69F0AE),
                                padding: const EdgeInsets.symmetric(vertical: 15),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                            ),
                          ),
                        ],
                      )
                    ] else ...[
                      const Text(
                        "Posisikan wajah Anda di dalam kotak",
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
class CornerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    final double length = 40; 

    final path = Path();

    path.moveTo(20, 20 + length);
    path.lineTo(20, 20);
    path.lineTo(20 + length, 20);

    path.moveTo(size.width - 20 - length, 20);
    path.lineTo(size.width - 20, 20);
    path.lineTo(size.width - 20, 20 + length);

    path.moveTo(20, size.height - 20 - length);
    path.lineTo(20, size.height - 20);
    path.lineTo(20 + length, size.height - 20);


    path.moveTo(size.width - 20 - length, size.height - 20);
    path.lineTo(size.width - 20, size.height - 20);
    path.lineTo(size.width - 20, size.height - 20 - length);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}