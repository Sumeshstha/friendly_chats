import 'package:flutter/material.dart';
import 'package:friendly_chat/helper/helper_function.dart';
import 'package:friendly_chat/pages/Help%20pages/PP.dart';
import 'Help pages/Faq.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? userName;
  String? userEmail;
  @override
  void initState() {
    getUserData();
    super.initState();
  }

  getUserData() async {
    await HelperFunction.getUserEmail().then((value) {
      setState(() {
        userEmail = value;
      });
    });
    await HelperFunction.getUsername().then((val) {
      setState(() {
        userName = val;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.orange,
        title: const Text("Profile"),
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            const Icon(
              Icons.account_circle,
              size: 100,
            ),
            const SizedBox(height: 5),
            Text(
              '$userName',
              style: const TextStyle(
                color: Color.fromARGB(255, 9, 9, 9),
                fontSize: 16,
              ),
            ),
            const SizedBox(
              height: 35,
            ),
            const Divider(
              height: 2,
            ),
            /* Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: const [
                SizedBox(height: 10),
                Icon(
                  Icons.settings,
                  size: 52,
                ),
                Text(
                  'Settings',
                  style: TextStyle(
                    color: Color.fromARGB(255, 9, 9, 9),
                    fontSize: 32,
                  ),
                ),
              ],
            ),*/
            ListTile(
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const Faq())),
              selected: true,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              leading: const Icon(Icons.notification_add_rounded),
              title: const Text(
                "Notifications",
                style: TextStyle(color: Colors.black),
              ),
            ),
            ListTile(
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const Faq())),
              selected: true,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              leading: const Icon(
                Icons.lock_clock,
                color: Colors.red,
              ),
              title: const Text(
                "Privacy and Security",
                style: TextStyle(color: Colors.black),
              ),
            ),
            /* Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: const [
                SizedBox(height: 50),
                Icon(
                  Icons.chat_bubble,
                  size: 25,
                ),
                Text(
                  'Chats',
                  style: TextStyle(
                    color: Color.fromARGB(255, 9, 9, 9),
                    fontSize: 16,
                  ),
                )
              ],
            ),*/
            const Divider(
              height: 2,
            ),
            /*Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: const [
                SizedBox(height: 50),
                Icon(
                  Icons.help,
                  size: 52,
                ),
                Text(
                  'Help',
                  style: TextStyle(
                    color: Color.fromARGB(255, 9, 9, 9),
                    fontSize: 32,
                  ),
                ),
              ],
            ),*/
            ListTile(
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const Faq())),
              selected: true,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              leading: const Icon(
                Icons.chat_bubble_outline_sharp,
                color: Colors.orange,
              ),
              title: const Text(
                "Frequently Asked Questions",
                style: TextStyle(color: Colors.black),
              ),
            ),
            ListTile(
              onTap: () => Navigator.push(
                  context, MaterialPageRoute(builder: (context) => const PP())),
              selected: true,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              leading: const Icon(
                Icons.key_rounded,
                color: Colors.purple,
              ),
              title: const Text(
                "Privacy Policy",
                style: TextStyle(color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
