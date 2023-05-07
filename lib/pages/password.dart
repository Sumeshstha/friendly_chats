import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:friendly_chat/Widgets/widgets.dart';
import 'package:friendly_chat/pages/Homepage.dart';
import 'package:friendly_chat/services/auth_service.dart';
import 'package:friendly_chat/services/database_service.dart';

class Password extends StatefulWidget {
  const Password({super.key});

  @override
  State<Password> createState() => _PasswordState();
}

class _PasswordState extends State<Password> {
  final formkey = GlobalKey<FormState>();
  String? oldPassword;
  String? newPassword;
  String? confirmNewPassword;
  String? password;
  AuthService authService = AuthService();
  bool _isLoading = false;
  bool obscureTextController1 = true;
  bool obscureTextController2 = true;
  bool obscureTextController3 = true;
  @override
  void initState() {
    getUserData();
    super.initState();
  }
  getUserData()async {
    await DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid).getUserData(FirebaseAuth.instance.currentUser!.email!).then((value) {
      QuerySnapshot snap = value;
      password = snap.docs[0]['password'];
    });
    

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: const Text("Change Password", style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body:_isLoading?Center(child: CircularProgressIndicator(color: Theme.of(context).primaryColor)) :Padding(
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10 ),
        child: SingleChildScrollView(
          child: Form(
            key: formkey,
            child: Column(
                    children: <Widget>[
                      const SizedBox(height: 50,),
                      TextFormField(
                                  obscureText: obscureTextController1,
                                  decoration: textInputDecoration.copyWith(
                                      suffixIcon: IconButton(
                                          onPressed: () {
                                            setState(() {
                                              obscureTextController1 =
                                                  !obscureTextController1;
                                            });
                                          },
                                          icon: Icon(obscureTextController1
                                              ? Icons.visibility_off
                                              : Icons.visibility)),
                                      hintText: "Old password",
                                      prefixIcon: Icon(Icons.password,
                                          color: Theme.of(context).primaryColor)),
                        onChanged: (value){
                          oldPassword = value;
                        },
                        validator:(oldPassword){
                         if(oldPassword == password){
                          return null;
                         } 
                         else {return "Please enter correct passwrod";}
                        }
                      ), 
                      const SizedBox(height: 20),
                      TextFormField(
                                  obscureText: obscureTextController2,
                                  decoration: textInputDecoration.copyWith(
                                      suffixIcon: IconButton(
                                          onPressed: () {
                                            setState(() {
                                              obscureTextController2 =
                                                  !obscureTextController2;
                                            });
                                          },
                                          icon: Icon(obscureTextController2
                                              ? Icons.visibility_off
                                              : Icons.visibility)),
                                      hintText: "New password",
                                      prefixIcon: Icon(Icons.password,
                                          color: Theme.of(context).primaryColor)),
                        onChanged: (value){
                          newPassword = value;
                        },
                        validator:(newPassword){
                          return newPassword!.length >8? null: "Password must be 8 characters long";
                        }
                      ),
                      const SizedBox(height: 20), 
                      TextFormField(
                                  obscureText: obscureTextController3,
                                  decoration: textInputDecoration.copyWith(
                                      suffixIcon: IconButton(
                                          onPressed: () {
                                            setState(() {
                                              obscureTextController3 =
                                                  !obscureTextController3;
                                            });
                                          },
                                          icon: Icon(obscureTextController3
                                              ? Icons.visibility_off
                                              : Icons.visibility)),
                                      hintText: "Confirm password",
                                      prefixIcon: Icon(Icons.password,
                                          color: Theme.of(context).primaryColor)),
                        onChanged: (value){
                          confirmNewPassword = value;
                        },
                        validator:(confirmNewPassword){
                         if(confirmNewPassword == newPassword){
                          return null;
                         }
                         else {return "Password doesn't match";}
                        }
                      ),
                      const SizedBox(height: 30),
                     SizedBox(
                                  width: double.infinity,
                                  height: 50,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.orange,
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10))),
                          onPressed: (){
                            changePassword();
                          },
                           child:const Text("Change Password"),)
                      )
                    ],),
          ),
        ),
      )
    );
  }
  changePassword()async {
    if(formkey.currentState!.validate()){
      setState(() {
        _isLoading = true;
      }); 
      await authService.changePassword(oldPassword!, newPassword!).then((value) {
        if(value == null){
          setState(() {
            _isLoading = false;
            
          });
        showSnackBar(context, "Password changed successfully", Colors.green);
        }
        else {
          showSnackBar(context, value, Colors.red);
          setState(() {
            _isLoading  = false;
          });
        }
      },);
      goto(context, HomePage());
    }
  }
}
