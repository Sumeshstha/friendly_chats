import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:friendly_chat/pages/register.dart';
import '../Widgets/widgets.dart';
import 'Homepage.dart';
import '../Components/my_button.dart';
import '../Components/my_textfield.dart';
import '../Components/square_tile.dart';


class LoginPage extends StatelessWidget {
  LoginPage({super.key});
  bool _isLoading = false;
  String? email;
  String? password;
  final formkey = GlobalKey<FormState>();
  void signUserIn() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        
        body:   _isLoading? Center(child: CircularProgressIndicator()): SingleChildScrollView(
          child: Form(
            key: formkey,
            child: SafeArea(
              child: Center(
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                                  const SizedBox(height: 50),
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
                    
                                   MyTextField(
                                    controller: email,
                                    lableText: 'Email',
                                    obscureText: false,
                                    validator: (email){
                                      return RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(email)? null : "Please enter valid email";
                                    }
                                  ),
                    
                                  const SizedBox(height: 10),
                    
                                  // password
                                  MyTextField(
                                    controller: password,
                                    lableText: 'Password',
                                    obscureText: true,
                                    validator: (password){
                                      return password.length >8 ? null : "Password must be 8 characters long";
                                    }
                                  ),
                    
                                  const SizedBox(height: 25),
                    
                                  // sign in button
                                  MyButton(
                                    text:"Sign In",
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context)=>HomePage()))
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
        );
  }
  
}
