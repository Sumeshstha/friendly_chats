// ignore: file_names
import 'package:flutter/material.dart';

class Noti extends StatefulWidget {
  const Noti({super.key});

  @override
  State<Noti> createState() => _NotiState();
}

class _NotiState extends State<Noti> {
  @override
  Widget build(BuildContext context) {
    // ignore: file_names
    return Scaffold(
        appBar: AppBar(
      backgroundColor: Colors.orange,
      title: const Text("Notification"),
    ));
  }
}
