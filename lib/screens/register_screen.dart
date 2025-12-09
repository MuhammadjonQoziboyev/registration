import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:login_register_app/widgets/custom_button.dart';
import 'package:login_register_app/widgets/custom_textfield.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegisterScreen extends StatefulWidget {
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // Controllers
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // ===== REGISTER FUNCTION (TO'LIQ ISHLAYDIGAN YANGI KO'P FOYD. TIZIM) =====
  Future<void> registerUser() async {
    String username = usernameController.text.trim();
    String password = passwordController.text.trim();
    String confirmPassword = confirmPasswordController.text.trim();

    if (username.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Barcha maydonlarni to‘ldiring!")),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Parollar mos emas!")),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();

    // ------- OLDINGI USERLAR RO‘YXATINI O‘QIYDI -------
    String? usersJson = prefs.getString("users");
    List<dynamic> users = usersJson == null ? [] : jsonDecode(usersJson);

    // ------- USER AVVAL RO‘YXATDA BOR-YO‘QLIGINI TEKSHIRADI -------
    bool userExists = users.any((u) => u["username"] == username);

    if (userExists) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Bu foydalanuvchi oldin ro‘yxatdan o‘tgan!")),
      );
      return;
    }

    // ------- YANGI USERNI QO‘SHADI -------
    users.add({
      "username": username,
      "password": password,
    });

    // ------- RO‘YXATNI SAQLAYDI -------
    await prefs.setString("users", jsonEncode(users));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Ro‘yxatdan o‘tish muvaffaqiyatli!")),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(height: 40),

              Image.asset(
                'assets/register.png',
                height: 160,
              ),

              SizedBox(height: 10),

              Text(
                'Registration',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),

              SizedBox(height: 10),

              Text(
                'Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                ),
              ),

              SizedBox(height: 20),

              CustomTextField(
                controller: usernameController,
                hintText: 'Username',
              ),

              SizedBox(height: 10),

              CustomTextField(
                controller: passwordController,
                hintText: 'Password',
                obscureText: true,
              ),

              SizedBox(height: 10),

              CustomTextField(
                controller: confirmPasswordController,
                hintText: 'Confirm Password',
                obscureText: true,
              ),

              SizedBox(height: 20),

              CustomButton(
                text: 'Register',
                onPressed: registerUser,
              ),

              SizedBox(height: 10),

              Text(
                'or',
                style: TextStyle(color: Colors.white70),
              ),

              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  'Login',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
