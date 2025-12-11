import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'edit_screen.dart';

class SettingsScreen extends StatefulWidget {
  final int userId; // ID orqali olamiz
  const SettingsScreen({super.key, required this.userId});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool notifGeneral = true;
  bool notifUpdates = false;
  bool darkMode = false;

  Map<String, dynamic>? currentUserData; // foydalanuvchi ma’lumotlari

  @override
  void initState() {
    super.initState();
    loadPrefs();
    loadUserData();
  }

  Future<void> loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      notifGeneral = prefs.getBool("notif_general") ?? true;
      notifUpdates = prefs.getBool("notif_updates") ?? false;
      darkMode = prefs.getBool("dark_mode") ?? false;
    });
  }

  Future<void> savePrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("notif_general", notifGeneral);
    await prefs.setBool("notif_updates", notifUpdates);
    await prefs.setBool("dark_mode", darkMode);
  }

  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getString("users");
    if (usersJson != null) {
      List<dynamic> users = jsonDecode(usersJson);
      currentUserData = users.firstWhere(
              (u) => u['id'] == widget.userId,
          orElse: () => null) as Map<String, dynamic>?;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    if (currentUserData == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: ListView(
        children: [

          // ============================
          //  PROFILE SECTION
          // ============================
          sectionTitle("ACCOUNT"),

          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text("Edit Profile"),
            onTap: () async {
              final updated = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EditScreen(userData: currentUserData!),
                ),
              );
              if (updated == true) loadUserData();
            },
          ),

          ListTile(
            leading: const Icon(Icons.lock),
            title: const Text("Change Password"),
            onTap: () async {
              final updated = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EditScreen(userData: currentUserData!),
                ),
              );
              if (updated == true) loadUserData();
            },
          ),

          // ============================
          //  NOTIFICATION SECTION
          // ============================
          const SizedBox(height: 20),
          sectionTitle("NOTIFICATIONS"),

          SwitchListTile(
            value: notifGeneral,
            onChanged: (val) {
              setState(() => notifGeneral = val);
              savePrefs();
            },
            title: const Text("General Notifications"),
            secondary: const Icon(Icons.notifications),
          ),

          SwitchListTile(
            value: notifUpdates,
            onChanged: (val) {
              setState(() => notifUpdates = val);
              savePrefs();
            },
            title: const Text("App Updates"),
            secondary: const Icon(Icons.system_update),
          ),

          // ============================
          //  APPEARANCE SECTION
          // ============================
          const SizedBox(height: 20),
          sectionTitle("APPEARANCE"),

          SwitchListTile(
            value: darkMode,
            onChanged: (val) {
              setState(() => darkMode = val);
              savePrefs();
            },
            title: const Text("Dark Mode"),
            secondary: const Icon(Icons.dark_mode),
          ),

          // ============================
          //  MORE SECTION
          // ============================
          const SizedBox(height: 20),
          sectionTitle("MORE"),

          ListTile(
            leading: const Icon(Icons.language, color: Colors.green),
            title: const Text("Language"),
            subtitle: const Text("English"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {},
          ),

          const Divider(height: 1),

          ListTile(
            leading: const Icon(Icons.info, color: Colors.orange),
            title: const Text("About App"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {},
          ),

          // ============================
          // LOG OUT
          // ============================
          const SizedBox(height: 30),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                "Log Out",
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, bottom: 8, top: 10),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey.shade700,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
