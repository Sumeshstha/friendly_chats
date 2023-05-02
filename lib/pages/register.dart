import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:friendly_chat/helper/helper_function.dart';
import 'package:friendly_chat/pages/Homepage.dart';
import 'package:friendly_chat/pages/login.dart';
import 'package:friendly_chat/services/auth_service.dart';
import '../Widgets/widgets.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  bool obscureTextController = true;
  bool _isLoading = false;
  final formkey_register = GlobalKey<FormState>();
  String? email;
  String? password;
  String? userName;
  AuthService authService = AuthService();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading? Center(
        child: CircularProgressIndicator(color: Theme.of(context).primaryColor)
      ):SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 80),
          child: Form(
            key: formkey_register,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>  [
                const Text("Friendly Chat", style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                const Text("Register", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w300)),
                const SizedBox(height: 50) ,
                Icon(Icons.lock) ,
                const SizedBox(height: 40),
                TextFormField(
                  obscureText: false,
                  decoration: textInputDecoration.copyWith(
                    labelText: "Username",
                    prefixIcon: Icon(Icons.person, color:Theme.of(context).primaryColor)
                  ),
                  onChanged: (value){
                    setState(() {
                      userName= value;
                    });
                  },
                  validator:(value) {
                    return value!.isEmpty ?"Username cannot be empty": null;
                  },
                ),  
                const SizedBox(height: 10),
                TextFormField(
                  
                  decoration: textInputDecoration.copyWith(
                    fillColor: Colors.grey.shade200,
                    labelText: "Email",
                    prefixIcon: Icon(Icons.email, color: Theme.of(context).primaryColor)
                  ),
                  onChanged: (value){
                    setState(() {
                      email = value;
                    });
                  },
                  validator: (value){
                    return RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(value!) ? null : "Please enter valid email";
                  }
                ),
                const SizedBox(height: 10),
                TextFormField(
                    obscureText: obscureTextController,
                    decoration: textInputDecoration.copyWith(
                      suffixIcon:IconButton(onPressed:(){
                        setState(() {
                          obscureTextController = ! obscureTextController;
                        });
                      } , icon: Icon(obscureTextController? Icons.visibility_off: Icons.visibility)),
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
                const SizedBox(height: 10),               
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  
                  child: ElevatedButton(
                    
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                    ),
                    
                  
                    onPressed: (){
                      register();
                    },
                    child: Text("Sign up")),
                ),
                const SizedBox(height: 20),
                Text.rich(TextSpan(
                  text: "Already have an account?  ",
                  style: const TextStyle(fontSize: 14),
                  children:<TextSpan>[
                    TextSpan(
                      text: "Login now.",
                      style: TextStyle(fontSize: 14, color: Colors.black, decoration: TextDecoration.underline),
                      recognizer: TapGestureRecognizer()..onTap =() {
                        goto(context, LoginPage());
                      }
                    ),
                  ] ))
                
                  ] ))
                
              )
          ),
        );
  }
  register()async {
    if(formkey_register.currentState!.validate()){
      setState(() {
        _isLoading= true; 
        
      });
      await authService.registerWithEmail(userName!, email!, password!).then((value)async {
        if(value == true){
          await HelperFunction.saveLoggedInStatus(true);
          await HelperFunction.saveUserEmail(email!);
          await HelperFunction.saveUserName(userName!);

          goto(context, HomePage());
        }
        else {

          showSnackBar(context, value, Colors.blue);
          setState(() {
            _isLoading = false;
            
         });
        }
      });
    }
    }
    

 }