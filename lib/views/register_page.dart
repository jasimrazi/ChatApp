import 'package:chat_app/services/auth_service.dart';
import 'package:chat_app/views/home_page.dart';
import 'package:chat_app/views/login_page.dart';
import 'package:chat_app/widgets/button.dart';
import 'package:chat_app/widgets/textfield.dart';
import 'package:chat_app/widgets/toast.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController nameController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();

  final TextEditingController confirmpasswordController =
      TextEditingController();

  bool isLoading = false;

  void register() async {
    if (emailController.text.isEmpty ||
        passwordController.text.isEmpty ||
        confirmpasswordController.text.isEmpty) {
      CustomToast.showToast(msg: "All fields are required");
      return;
    }

    if (passwordController.text != confirmpasswordController.text) {
      CustomToast.showToast(msg: "Passwords do not match");
      return;
    }

    AuthService auth = AuthService();
    setState(() {
      isLoading = true;
    });
    try {
      User? user = await auth.signUpWithEmailAndPassword(
          emailController.text, passwordController.text, nameController.text);
      if (user != null) {
        // Navigate to the next page or show a success message

        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomePage(),
            ));
            
        CustomToast.showToast(msg: "Registration Successful");
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
                SizedBox(
                  height: 50,
                ),
                const Text(
                  'Register Page',
                  style: TextStyle(color: Colors.deepPurple, fontSize: 24),
                ),
                SizedBox(
                  height: 200,
                ),
                CustomTextfield(
                  hintext: 'Name',
                  controller: nameController,
                ),
                SizedBox(
                  height: 20,
                ),
                CustomTextfield(
                  hintext: 'Email',
                  controller: emailController,
                ),
                SizedBox(
                  height: 20,
                ),
                CustomTextfield(
                  hintext: 'Password',
                  controller: passwordController,
                ),
                SizedBox(
                  height: 20,
                ),
                CustomTextfield(
                  hintext: 'Confirm Password',
                  controller: confirmpasswordController,
                ),
                SizedBox(
                  height: 20,
                ),
                CustomButton(
                  label: 'Register',
                  ontap: register,
                  isLoading: isLoading,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Already have an account?'),
                    TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => LoginPage()));
                        },
                        child: Text(
                          'Login',
                          style: TextStyle(color: Colors.deepPurple),
                        ))
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
