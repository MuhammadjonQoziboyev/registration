import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:login_register_app/screens/home_screen.dart';
import 'package:login_register_app/screens/register_screen.dart';
import 'package:login_register_app/widgets/custom_button.dart';
import 'package:login_register_app/widgets/custom_textfield.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController userController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // JSON decode function
  List<dynamic> decodeUsers(String jsonString) {
    try {
      return json.decode(jsonString);
    } catch (e) {
      return [];
    }
  }

  // LOGIN FUNCTION WITH ID
  Future<void> loginUser() async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getString('users'); // List of users

    if (usersJson == null || usersJson.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Hali hech kim ro‘yxatdan o‘tmagan")),
      );
      return;
    }

    final List<dynamic> users = decodeUsers(usersJson);
    Map<String, dynamic>? currentUser;

    for (var user in users) {
      if ((user['username'] == userController.text.trim() ||
          user['email'] == userController.text.trim()) &&
          user['password'] == passwordController.text.trim()) {
        currentUser = Map<String, dynamic>.from(user);
        break;
      }
    }

    if (currentUser != null) {
      // Saqlaymiz: logged_in_user_id
      await prefs.setInt('logged_in_user_id', currentUser['id']);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomeScreen(),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Username/Email yoki parol xato")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                Image.asset(
                  'assets/login.png',
                  height: 160,
                ),
                const SizedBox(height: 15),
                const Text(
                  "Login into app",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Enter your username or email and password to login.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 30),
                CustomTextField(
                  controller: userController,
                  hintText: 'Username or Email',
                ),
                const SizedBox(height: 15),
                CustomTextField(
                  controller: passwordController,
                  hintText: 'Password',
                  obscureText: true,
                ),
                const SizedBox(height: 25),
                CustomButton(
                  text: "Login",
                  onPressed: loginUser,
                ),
                const SizedBox(height: 10),
                const Text(
                  "or",
                  style: TextStyle(color: Colors.white70),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RegisterScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    "Register",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
