// ignore: file_names
import 'package:flutter/material.dart';

class Faq extends StatefulWidget {
  const Faq({Key? key}) : super(key: key);

  @override
  State<Faq> createState() => _FaqState();
}

class _FaqState extends State<Faq> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: const Text('Frequently Asked Questions'),
      ),
      body: ListView(
        children: const [
          ListTile(
            title: Text('Q1. How do I create an account and login?'),
            subtitle: Text(
                'A1. You can create an account by clicking on the "Register now" button on the login page, right after the "Get started" button. To log in, use your registered email and password.'),
          ),
          ListTile(
            title: Text('Q2. How do I reset my password?'),
            subtitle: Text('A2. You can for now contact us'),
          ),
          ListTile(
            title: Text('Q3. How do I delete my account?'),
            subtitle: Text(
                'A3. To delete your account, please contact our customer support team.'),
          ),
          ListTile(
            title: Text('Q4. In which language was this app written?'),
            subtitle: Text(
                'A4. This Program was written in Dart language and Flutter'),
          )
        ],
      ),
    );
  }
}
