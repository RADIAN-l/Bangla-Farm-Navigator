import 'package:flutter/material.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blueAccent, Colors.lightBlue],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Profile or app image
                CircleAvatar(
                  radius: 50,
                  backgroundImage: AssetImage('assets/logo.png'),
                  backgroundColor: Colors.white,
                ),
                const SizedBox(height: 5),
                const Text(
                  "BANGLA FARM NAVIGATOR",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // About Button
          ListTile(
            leading: const Icon(Icons.info, color: Colors.blueAccent),
            title: const Text("About"),
            onTap: () {
              Navigator.pop(context);
              // Navigate to About Page
              showDialog(
                context: context,
                builder: (_) => const AlertDialog(
                  title: Text("About"),
                  content: Text("Developed by Farmonauts"),
                ),
              );
            },
          ),

          // Contact Button
          ListTile(
            leading: const Icon(Icons.contact_mail, color: Colors.blueAccent),
            title: const Text("Contact"),
            onTap: () {
              Navigator.pop(context);
              // Navigate to Contact Page
              showDialog(
                context: context,
                builder: (_) => const AlertDialog(
                  title: Text("Contact"),
                  content: Text("Email: radianislam19@gmail.com"),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
