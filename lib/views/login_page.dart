import 'package:chat_app/views/home_page.dart';
import 'package:chat_app/views/register_page.dart';
import 'package:chat_app/widgets/button.dart';
import 'package:chat_app/widgets/textfield.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:chat_app/services/auth_service.dart';
import 'package:chat_app/widgets/toast.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();

  bool isLoading = false;

  void login(BuildContext context) async {
    AuthService auth = AuthService();
    setState(() {
      isLoading = true;
    });
    try {
      print('111');
      User? user = await auth.signInWithEmailAndPassword(
        emailController.text,
        passwordController.text,
      );

      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(),
          ));
      if (user != null) {
        // Navigate to the next page or show a success message
        CustomToast.showToast(msg: "Login Successful");
      }
    } on FirebaseAuthException catch (e) {
      // Handle specific Firebase authentication errors
      CustomToast.showToast(msg: e.message ?? "An error occurred");
    } catch (e) {
      // Handle general errors
      CustomToast.showToast(msg: "An unexpected error occurred");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Center(
            child: Column(
              children: [
                SizedBox(height: 50),
                const Text(
                  'Login Page',
                  style: TextStyle(color: Colors.deepPurple, fontSize: 24),
                ),
                SizedBox(height: 200),
                CustomTextfield(
                  hintext: 'Email',
                  controller: emailController,
                ),
                SizedBox(height: 20),
                CustomTextfield(
                  hintext: 'Password',
                  controller: passwordController,
                ),
                SizedBox(height: 20),
                CustomButton(
                  label: 'Login',
                  isLoading: isLoading,
                  ontap: () {
                    login(context);
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Don\'t have an account?'),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => RegisterPage()),
                        );
                      },
                      child: Text(
                        'Register',
                        style: TextStyle(color: Colors.deepPurple),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
