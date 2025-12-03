import 'package:news_app_with_getx/Auth/register_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  String message = '';
  bool pass= true ; 

  Future<void> login () async {
   try{
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: emailController.text.trim(),
      password: passwordController.text.trim()
    );
    setState(() {
      message = "Berhasil Login";
    });
   } catch (e){
    setState(() {
      message = "eror $e";
    });
     ScaffoldMessenger.of(context,).showSnackBar(SnackBar(content: Text(message)));
   }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(message),
                Text('Halaman Login'),
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: "Email",
                    hintText: "Masukan Email anda",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)
                    )
                  ),
                ),
                SizedBox(height: 10,),
                 TextField(
                  controller: passwordController,
                  obscureText: pass,
                  decoration: InputDecoration(
                    suffix: IconButton(onPressed: () {
                      setState(() {
                        pass = !pass;
                      });
                    }, 
                    icon: Icon(pass ? Icons.visibility : 
                    Icons.visibility_off)),
                    labelText: "Password",
                    hintText: "Masukan password anda",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)
                    )
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green
                    ),
                    onPressed: () {
                      login();
                    }, child: Text("Submit",style: TextStyle(
                      color: Colors.white
                    ),),
                )
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("Belum Punya Akun?"),
                    TextButton(
                      onPressed: (){
                        Navigator.push(context, MaterialPageRoute(builder: (context) => RegisterScreen(),));
                      }, 
                      child: Text("register"))
                  ],
                )
              ]
            ),
          ),
        )
      ),
    );
  }
}