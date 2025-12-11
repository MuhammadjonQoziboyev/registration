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
  final emailController = TextEditingController();
  final ageController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  String selectedGender = "Male";

  // REGISTER FUNCTION WITH ID
  Future<void> registerUser() async {
    String username = usernameController.text.trim();
    String email = emailController.text.trim();
    String age = ageController.text.trim();
    String password = passwordController.text.trim();
    String confirmPassword = confirmPasswordController.text.trim();

    // Validation
    if (username.isEmpty ||
        email.isEmpty ||
        age.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      showMessage("Barcha maydonlarni to‘ldiring!");
      return;
    }

    if (!email.contains("@") || !email.contains(".")) {
      showMessage("Email noto‘g‘ri formatda!");
      return;
    }

    if (int.tryParse(age) == null || int.parse(age) < 10) {
      showMessage("Yosh 10 dan katta bo‘lishi kerak!");
      return;
    }

    if (password != confirmPassword) {
      showMessage("Parollar mos emas!");
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    String? usersJson = prefs.getString("users");
    List<dynamic> users = usersJson == null ? [] : jsonDecode(usersJson);

    // Check duplicates
    bool userExists = users.any((u) =>
    u["username"] == username || u["email"] == email);

    if (userExists) {
      showMessage("Bu username yoki email oldin ro‘yxatdan o‘tgan!");
      return;
    }

    // Generate unique ID
    int userId = DateTime.now().millisecondsSinceEpoch;

    // Add new user with ID
    users.add({
      "id": userId,
      "username": username,
      "email": email,
      "age": age,
      "gender": selectedGender,
      "password": password,
    });

    await prefs.setString("users", jsonEncode(users));

    showMessage("Ro‘yxatdan o‘tish muvaffaqiyatli!");

    Navigator.pop(context);
  }

  void showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Padding(
        padding: EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 40),
              Image.asset('assets/register.png', height: 160),
              SizedBox(height: 10),
              Text('Registration',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
              SizedBox(height: 10),
              Text(
                  'Please fill in the details below to create an account.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70)),
              SizedBox(height: 20),
              CustomTextField(
                controller: usernameController,
                hintText: "Username",
              ),
              SizedBox(height: 10),
              CustomTextField(
                controller: emailController,
                hintText: "Email",
              ),
              SizedBox(height: 10),
              CustomTextField(
                controller: ageController,
                hintText: "Age",
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 10),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Color(0xFF2A2A2E),         // Soft dark grey
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white24),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedGender,
                    dropdownColor: Color(0xFF2A2A2E),
                    isExpanded: true,
                    icon: Icon(Icons.arrow_drop_down, color: Colors.white70),

                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),

                    items: ["Male", "Female"]
                        .map((g) => DropdownMenuItem(
                      value: g,
                      child: Text(
                        g,
                        style: TextStyle(color: Colors.white),
                      ),
                    ))
                        .toList(),

                    onChanged: (value) {
                      setState(() {
                        selectedGender = value!;
                      });
                    },
                  ),
                ),
              ),

              SizedBox(height: 10),
              CustomTextField(
                controller: passwordController,
                hintText: "Password",
                obscureText: true,
              ),
              SizedBox(height: 10),
              CustomTextField(
                controller: confirmPasswordController,
                hintText: "Confirm Password",
                obscureText: true,
              ),
              SizedBox(height: 20),
              CustomButton(
                text: "Register",
                onPressed: registerUser,
              ),
              SizedBox(height: 10),
              Text('or', style: TextStyle(color: Colors.white70)),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Login',
                    style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).colorScheme.secondary)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
