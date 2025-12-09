import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:login_register_app/screens/register_screen.dart';
import 'package:login_register_app/screens/home_screen.dart';
import 'package:login_register_app/widgets/custom_button.dart';
import 'package:login_register_app/widgets/custom_textfield.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // JSON decode function
  List<dynamic> decodeUsers(String jsonString) {
    try {
      return json.decode(jsonString);
    } catch (e) {
      return [];
    }
  }

  // LOGIN FUNCTION (multi-user)
  Future<void> loginUser() async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getString('users'); // list of users

    if (usersJson == null || usersJson.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Hali hech kim ro‘yxatdan o‘tmagan")),
      );
      return;
    }

    final List<dynamic> users = decodeUsers(usersJson);
    bool found = false;

    for (var user in users) {
      if (user['username'] == usernameController.text.trim() &&
          user['password'] == passwordController.text.trim()) {
        found = true;
        break;
      }
    }

    if (found) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Username yoki parol xato"),
        ),
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

                // IMAGE
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
                  "Lorem ipsum dolor sit amet, consectetur adipiscing elit. "
                      "Nullam tincidunt ante lacus, eu pretium purus.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),

                const SizedBox(height: 30),

                CustomTextField(
                  controller: usernameController,
                  hintText: 'Username',
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
                  onPressed: () {
                    loginUser();
                  },
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
