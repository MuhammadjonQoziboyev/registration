import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:login_register_app/screens/settings_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:login_register_app/screens/login_screen.dart';
import 'package:login_register_app/screens/profile_screen.dart';

import 'edit_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  Map<String, dynamic>? currentUserData;

  late AnimationController _controller;
  late Animation<double> fadeAnim;
  late Animation<Offset> slideAnim;

  @override
  void initState() {
    super.initState();
    loadCurrentUser();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  Future<void> loadCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getString("users");
    final loggedInUserId = prefs.getInt("logged_in_user_id");

    if (usersJson != null && loggedInUserId != null) {
      List<dynamic> users = jsonDecode(usersJson);

      Map<String, dynamic>? current;
      for (var u in users) {
        if (u['id'] == loggedInUserId) {
          current = Map<String, dynamic>.from(u);
          break;
        }
      }

      if (current != null) {
        setState(() {
          currentUserData = current;
        });
        _controller.forward();
      }
    }
  }

  void logout() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
    );
  }

  Future<void> deleteAccount() async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getString("users");

    if (usersJson != null && currentUserData != null) {
      List<dynamic> users = jsonDecode(usersJson);

      users.removeWhere((u) => u['id'] == currentUserData!['id']);

      await prefs.setString("users", jsonEncode(users));
      await prefs.remove("logged_in_user_id");

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
            (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    String username = currentUserData?['username'] ?? "Foydalanuvchi";
    String firstLetter = username.isNotEmpty ? username[0].toUpperCase() : "U";

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: AppBar(
              title: const Text(
                "Home",
                style:
                TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              ),
              backgroundColor: Colors.blue.withOpacity(0.5),
              elevation: 0,
              actions: [
                IconButton(
                  icon: const Icon(Icons.person, color: Colors.white),
                  onPressed: currentUserData == null
                      ? null
                      : () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            ProfileScreen(userData: currentUserData!),
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.white),
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (_) =>
                          AlertDialog(
                            title: const Text("Accountni o‘chirish"),
                            content: const Text("Aniq o‘chirmoqchimisiz?"),
                            actions: [
                              TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: const Text("Yo‘q")),
                              TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text("Ha")),
                            ],
                          ),
                    );
                    if (confirm == true) deleteAccount();
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.logout, color: Colors.white),
                  onPressed: logout,
                ),
              ],
            ),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF6CB4EE),
              Color(0xFFE3F2FD),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: FadeTransition(
          opacity: fadeAnim,
          child: SlideTransition(
            position: slideAnim,
            child: ListView(
              padding: const EdgeInsets.only(top: 120, left: 20, right: 20),
              children: [
                // GLASS WELCOME CARD
                ClipRRect(
                  borderRadius: BorderRadius.circular(25),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(25),
                        border:
                        Border.all(color: Colors.white.withOpacity(0.3)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withOpacity(0.2),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 32,
                            backgroundColor: Colors.blue.shade700,
                            child: Text(
                              firstLetter,
                              style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                          ),
                          const SizedBox(width: 15),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Salom, $username!",
                                style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                              const SizedBox(height: 5),
                              const Text(
                                "Xush kelibsiz 👋",
                                style: TextStyle(
                                    fontSize: 16, color: Colors.white),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 25),

                // ACTION BUTTONS
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _actionBtn(Icons.person, "Profil", () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              ProfileScreen(userData: currentUserData!),
                        ),
                      );
                    }),
                    _actionBtn(Icons.edit, "Edit", () async {
                      final updated = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EditScreen(userData: currentUserData!),
                        ),
                      );

                      if (updated == true) {
                        // qaytganimizdan so‘ng yangilangan ma'lumotlarni qayta yuklaymiz
                        loadCurrentUser();
                      }
                    }),
                    _actionBtn(Icons.settings, "Settings", () {
                      if (currentUserData != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => SettingsScreen(userId: currentUserData!['id']),
                          ),
                        );
                      }
                    }),

                  ],
                ),
                const SizedBox(height: 35),

                // STATS CARD
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white, // toza oq fon
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 12,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Profil maʼlumotlari",
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87),
                      ),

                      const SizedBox(height: 15),
                      _statRow("Foydalanuvchi nomi", username),
                      _statRow("ID", "${currentUserData?['id']}"),
                      _statRow("Email",
                          currentUserData?['email'] ?? "Kiritilmagan"),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _actionBtn(IconData icon, String text, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 95,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.85),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.2),
              blurRadius: 15,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, size: 30, color: Colors.blue.shade700),
            const SizedBox(height: 8),
            Text(text,
                style: TextStyle(fontSize: 14, color: Colors.blue.shade800)),
          ],
        ),
      ),
    );
  }

  Widget _statRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              color: Colors.blue.shade700,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

