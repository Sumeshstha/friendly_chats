// ignore: file_names

import 'package:flutter/material.dart';
// ignore: unused_import
import 'package:flutter/physics.dart';
import 'package:friendly_chat/Widgets/widgets.dart';
import 'package:friendly_chat/helper/helper_function.dart';
import 'package:friendly_chat/services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:friendly_chat/services/database_service.dart';
import 'login.dart';
import 'Search_page.dart';
// ignore: duplicate_import
import 'ProfilePage.dart';
import 'dart:io';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? userEmail;
  String? userName;
  AuthService authService = AuthService();
  get centerTitle => null;
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
   await HelperFunction.getUsername().then((val){
      setState(() {
        userName = val;
      });
  });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          actions: [
            IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.search,
              ),
            )
          ],
          centerTitle: false,
          backgroundColor: Colors.orange,
          title: const Text("Messages",
              style: TextStyle(
                fontSize: 27,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              )),
              ),

      drawer: Drawer(
        child: ListView(
            padding: const EdgeInsets.symmetric(vertical: 50),
            children: <Widget>[
              const Icon(
                Icons.account_circle,
                size: 150,
                color: Color.fromARGB(255, 208, 123, 223),
              ),
              const SizedBox(
                height: 15,
              ),
               Text("$userName",
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 35,
              ),
              const Divider(
                height: 2,
              ),
              ListTile(
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ProfilePage())),
                selected: true,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                leading: const Icon(Icons.person),
                title: const Text(
                  "Profile and Settings",
                  style: TextStyle(color: Colors.black),
                ),
              ),
              ListTile(
                onTap: () {
                  authService.logout();
                  goto(context, LoginPage());
                },
                selected: true,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                leading: const Icon(Icons.logout),
                title: const Text(
                  "Logout",
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ]),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: 2,
              shrinkWrap:true,
              itemBuilder: (context, index) {
              return ListTile(
                  leading:Icon(Icons.account_circle),
                  title: Text(""),
                  subtitle: Text("No messages"),
                onTap:() => Navigator.push(context, MaterialPageRoute(builder: (context){
                  return LoginPage();
                })),
              );
            }),
          ),
        ],)
      );
  }
}
