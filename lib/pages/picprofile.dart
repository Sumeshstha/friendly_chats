import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class completeprofile extends StatefulWidget {
  const completeprofile({super.key});

  @override
  State<completeprofile> createState() => _completeprofileState();
}

class _completeprofileState extends State<completeprofile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        automaticallyImplyLeading: false,
        // ignore: prefer_const_constructors
        title: Text("Profile"),
      ), // add a comma here
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: 40,
          ),
          child: ListView(
            children: [
              SizedBox(height: 20),

              CupertinoButton(
                onPressed: () {},
                padding: EdgeInsets.all(0),
                child: CircleAvatar(
                  radius: 60,
                  child: Icon(Icons.person, size: 60),
                ),
              ),
              SizedBox(height: 20),

              TextField(
                decoration: InputDecoration(
                  labelText: "Bio",
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
