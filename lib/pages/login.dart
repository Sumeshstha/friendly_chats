
import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:friendly_chat/helper/helper_function.dart';
import 'package:friendly_chat/pages/Homepage.dart';
import 'package:friendly_chat/pages/register.dart';
import 'package:friendly_chat/services/auth_service.dart';
import 'package:friendly_chat/services/database_service.dart';
// ignore: depend_on_referenced_packages
import 'package:firebase_auth/firebase_auth.dart';
import '../Components/my_button.dart';
import '../Components/my_textfield.dart';
import '../Widgets/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';



class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String? email;
  String password= '';
  bool _isLoading = false;
  final formkey = GlobalKey<FormState>();
  AuthService authService = AuthService();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
       body:   _isLoading? Center(child: CircularProgressIndicator()): SingleChildScrollView(
          child: Padding(
            padding:const EdgeInsets.symmetric(vertical: 70, horizontal: 20),
            child: Form(
              key: formkey,
              child: SafeArea(
                child: Center(
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                                    const Text("Friendly Chat", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                                    const SizedBox(height:10),
                                    const Text("Login", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w300)),
                                    const SizedBox(height:20),
                                    const Icon(
                                  Icons.lock,
                                     size: 100,
                                    ),
                      
                                    const SizedBox(height: 50),
                      
                                    const Text(
                        'Welcome!',
                        style: TextStyle(
                          color: Color.fromARGB(255, 9, 9, 9),
                          fontSize: 16,
                        ),
                                    ),
                      
                                    // username
                                    const SizedBox(height: 50,),
                      
                                    TextFormField(
                    obscureText: false,
                    decoration: textInputDecoration.copyWith(
                      fillColor: Colors.grey.shade200,
                      labelText: "Email",
                      prefixIcon: Icon(Icons.email, color:Theme.of(context).primaryColor)
                    ),
                    onChanged: (value){
                      setState(() {
                        email= value;
                      });
                    },
                    validator: (email){
                      return RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(email!) ? null : "Please enter valid email";
                    }
                  ),
                      
                                    const SizedBox(height: 10),
                      
                                    // password
                                    TextFormField(
                    obscureText: true,
                    decoration: textInputDecoration.copyWith(
                      labelText: "password",
                      prefixIcon: Icon(Icons.password, color:Theme.of(context).primaryColor)
                    ),
                    onChanged: (value){
                      setState(() {
                        password= value;
                      });
                    },
                    validator:(password) {
                      return password!.length> 8 ? null: "Password must be 8 characters long";
                    },
                  ),
                      
                                    const SizedBox(height: 25),
                      
                                    // sign in button
                                     SizedBox(
                    width: double.infinity,
                    height: 50,
                    
                    child: ElevatedButton(
                      
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                      ),
                      
                    
                      onPressed: (){
                        login();
                      },
                      child: Text("Sign in")),
                  ),
                                    const SizedBox(height: 20),
                                     Text.rich(TextSpan(
                    text: "Don't have an account yet?  ",
                    style: const TextStyle(fontSize: 14),
                    children:<TextSpan>[
                      TextSpan(
                        text: "Register now",
                        style: TextStyle(fontSize: 14, color: Colors.black, decoration: TextDecoration.underline),
                        recognizer: TapGestureRecognizer()..onTap =() {
                          goto(context, Register());
                        }
                      ),
                    ] ))
                      
                                  
                               ]),
                      ),
                ),
              ),
          ),
        ),
    );
  }
  login()async {
    if(formkey.currentState!.validate()){
      setState(() {
        _isLoading = true;
      });
      await authService.login(email!, password).then((value) async {
        if(value != null){
          QuerySnapshot snapshot=  await DatabaseService(uid:FirebaseAuth.instance.currentUser!.uid ).getUserData(email!);
          await HelperFunction.saveLoggedInStatus(true);
          await HelperFunction.saveUserEmail(email!);
          await HelperFunction.saveUserName(
            snapshot.docs[0]['userName']
          );
          goto(context, HomePage());
        }
        else {
          showSnackBar(context, "Wrong Email or Password", Colors.red);
          setState(() {
            _isLoading = false;
          });
        }
      });
    }
  }
}