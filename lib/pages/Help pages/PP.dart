/* privacy policy page*/

// ignore: file_names
import 'package:flutter/material.dart';

class PP extends StatefulWidget {
  const PP({super.key});

  @override
  State<PP> createState() => _PPState();
}

class _PPState extends State<PP> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.orange,
          title: const Text("Privacy Policies"),
        ),
        body: ListView(
          children: const [
            ListTile(
              title: Text('Q1. What kind of data do we collect?'),
              subtitle: Text(
                  'we collect your Username, Email, and Password for your account in this app.'),
            ),
            ListTile(
              title: Text('Q2: How do we collect your data?'),
              subtitle: Text(
                  'we collect just your email and username when you Register'),
            ),
            ListTile(
              title: Text('Q3. How do we protect your data?'),
              subtitle:
                  Text('All your data is stored in Firebase (Made by Google)'),
            ),
            ListTile(
                title: Text('Q4. Do we share your data?'),
                subtitle: Text('We dont share your data to anyone'))
          ],
        ));
  }
}
