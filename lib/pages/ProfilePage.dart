import 'package:flutter/material.dart';
import 'package:friendly_chat/helper/helper_function.dart';
import 'package:friendly_chat/pages/Help%20pages/PP.dart';
import 'package:friendly_chat/pages/password.dart';
import '../Widgets/widgets.dart';
import 'Help pages/Faq.dart';

class ProfilePage extends StatefulWidget {
  final String userName;
  final String userId;
  final String userEmail;
  const ProfilePage({super.key, required this.userEmail, required this.userName, required this.userId});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.orange,
        title: const Text("Profile"),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            const Icon(
              Icons.account_circle,
              size: 100,
            ),
            const SizedBox(height: 5),
            Container(
              width:300,
              
              alignment: AlignmentDirectional.center,
              child: Padding(
                padding: const EdgeInsets.only(left: 50),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                  'Username : ${widget.userName}',
                  style: const TextStyle(
                    color: Color.fromARGB(255, 9, 9, 9),
                    fontSize: 16,
                  ),
                            ),
                            const SizedBox(height:10),
                            Text("User ID: ${widget.userId}", style: const TextStyle(
                    color: Color.fromARGB(255, 9, 9, 9),
                    fontSize: 16,)), 
                            const SizedBox(height: 10),
                            Text(
                  'Email : ${widget.userEmail}',
                  style: const TextStyle(
                    color: Color.fromARGB(255, 9, 9, 9),
                    fontSize: 16,
                  ),
                            ),
                  ],
                            
                ),
              )),

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
            ListTile(
              onTap: () => goto(context,Password() ),
              selected: false,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              leading: const Icon(
                Icons.password,
                color: Colors.red,
              ),
              title: const Text(
                "Change Password",
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
