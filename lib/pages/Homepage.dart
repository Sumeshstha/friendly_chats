// ignore: file_names

import 'package:flutter/material.dart';
// ignore: unused_import
import 'package:flutter/physics.dart';
import 'package:friendly_chat/Widgets/widgets.dart';
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
  List<String> arrNames= ["one", 'two', 'three', '4', '5', '6'];
  String userName = "";
  String email = "";
  Stream? groups;
  String groupName = "";

  
  get centerTitle => null;

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
              const Text(
                "USER_NAME",
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
              itemCount: arrNames.length,
              shrinkWrap:true,
              itemBuilder: (context, index) {
              return InkWell(
                child: ListTile(
                  leading:Icon(Icons.account_circle),
                  title: Text(arrNames[index]),
                  subtitle: Text("No messages"),
                ),
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
