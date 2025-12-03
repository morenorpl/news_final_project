import 'package:news_app_with_getx/Auth/login_screen.dart';
import 'package:news_app_with_getx/controller/news_controller.dart';
import 'package:news_app_with_getx/screens/news_home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController usernameController = TextEditingController();
  String message = '';
  bool pass = true;

  final Color _backgroundColor = const Color(0xFFF5F6FA); 
  final Color _primaryBlue = const Color(0xFF007AFF); 
  final Color _darkText = const Color(0xFF1C1C1E);
  final Color _greyText = const Color(0xFF8E8E93);
  final Color _inputFieldBackground = Colors.white;

  Future<void> register() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      UserCredential username =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      await username.user!.updateDisplayName(usernameController.text.trim());
      await username.user!.reload();

      if (!mounted) return;
      Navigator.pop(context); 

      setState(() {
        message = 'Berhasil Register sebagai ${usernameController.text}';
      });
      
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ));

      emailController.clear();
      passwordController.clear();
      usernameController.clear();

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const NewsHomeScreen()),
        (route) => false,
      );

    } catch (e) {
      Navigator.pop(context); 
      setState(() {
        message = "Eror: ${e.toString()}";
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Center(
                  child: Column(
                    children: [
                      Icon(Icons.campaign_outlined,
                          size: 50, color: _darkText),
                      Text(
                        "Kabari",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: _darkText,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                Text(
                  'Register',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: _darkText,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Please fill in the required information to create your account.',
                  style: TextStyle(
                    fontSize: 14,
                    color: _greyText,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 30),
                Container(
                  decoration: BoxDecoration(
                    color: _inputFieldBackground,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 10),
                  child: Column(
                    children: [
                      _buildCustomTextField(
                        controller: usernameController,
                        label: "Nama",
                        hint: "Masukan Nama anda",
                        isLast: false,
                      ),
                      _buildCustomTextField(
                        controller: emailController,
                        label: "Email",
                        hint: "Masukan Email anda",
                        keyboardType: TextInputType.emailAddress,
                        isLast: false,
                      ),
                      _buildCustomTextField(
                        controller: passwordController,
                        label: "Password",
                        hint: "Masukan password anda",
                        isPassword: true,
                        isLast: true,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 55, 
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryBlue,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () {
                      if (emailController.text.isEmpty ||
                          passwordController.text.isEmpty ||
                          usernameController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text("Semua data harus diisi")),
                        );
                        return;
                      }
                      register();
                    },
                    child: const Text(
                      "CONTINUE",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Already have an Account? ",
                      style: TextStyle(color: _greyText),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginScreen(),
                          ),
                        );
                      },
                      child: Text(
                        "Login",
                        style: TextStyle(
                          color: _primaryBlue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
  Widget _buildCustomTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
    bool isLast = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: _darkText,
          ),
        ),
        TextField(
          controller: controller,
          obscureText: isPassword ? pass : false,
          keyboardType: keyboardType,
          style: TextStyle(
              fontSize: 16, color: _darkText, fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
            suffixIcon: isPassword
                ? IconButton(
                    onPressed: () {
                      setState(() {
                        pass = !pass;
                      });
                    },
                    icon: Icon(
                      pass ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      color: _greyText,
                    ),
                  )
                : null,
          ),
        ),
        if (!isLast)
          Divider(
            color: Colors.grey.shade200,
            thickness: 1,
          ),
      ],
    );
  }
}