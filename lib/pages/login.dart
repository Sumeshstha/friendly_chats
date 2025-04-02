import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:friendly_chat/helper/helper_function.dart';
import 'package:friendly_chat/pages/Homepage.dart';
import 'package:friendly_chat/pages/register.dart';
import 'package:friendly_chat/services/auth_service.dart';
import 'package:friendly_chat/services/database_service.dart';
import 'package:friendly_chat/Theme/app_theme.dart';
// ignore: depend_on_referenced_packages
import 'package:firebase_auth/firebase_auth.dart';
import '../Components/my_button.dart';
import '../Components/my_textfield.dart';
import '../Widgets/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool obscureTextController = true;
  FocusNode _focusNode = FocusNode();
  String? email;
  String password = '';
  bool _isLoading = false;
  final formkey = GlobalKey<FormState>();
  AuthService authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(color: AppTheme.primaryColor))
          : SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Form(
                    key: formkey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 40),
                        // Logo and welcome text
                        Container(
                          height: 200,
                          child: Lottie.network(
                            'https://assets5.lottiefiles.com/packages/lf20_jcikwtux.json',
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          "Welcome Back!",
                          style: AppTheme.headingStyle.copyWith(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Sign in to continue chatting with friends",
                          style: AppTheme.bodyStyle.copyWith(
                            color: AppTheme.secondaryTextColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 40),

                        // Email field
                        Container(
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceColor,
                            borderRadius:
                                BorderRadius.circular(AppTheme.borderRadius),
                            boxShadow: AppTheme.cardShadow,
                          ),
                          child: TextFormField(
                            obscureText: false,
                            decoration: InputDecoration(
                              hintText: "Email",
                              hintStyle:
                                  TextStyle(color: AppTheme.hintTextColor),
                              prefixIcon: Icon(Icons.email,
                                  color: AppTheme.primaryColor),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                    AppTheme.borderRadius),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: AppTheme.surfaceColor,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 16,
                              ),
                            ),
                            onChanged: (value) {
                              setState(() {
                                email = value;
                              });
                            },
                            onFieldSubmitted: (value) {
                              login();
                            },
                            validator: (email) {
                              return RegExp(
                                          r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                      .hasMatch(email!)
                                  ? null
                                  : "Please enter valid email";
                            },
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Password field
                        Container(
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceColor,
                            borderRadius:
                                BorderRadius.circular(AppTheme.borderRadius),
                            boxShadow: AppTheme.cardShadow,
                          ),
                          child: TextFormField(
                            obscureText: obscureTextController,
                            decoration: InputDecoration(
                              hintText: "Password",
                              hintStyle:
                                  TextStyle(color: AppTheme.hintTextColor),
                              prefixIcon: Icon(Icons.lock,
                                  color: AppTheme.primaryColor),
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    obscureTextController =
                                        !obscureTextController;
                                  });
                                },
                                icon: Icon(
                                  obscureTextController
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: AppTheme.secondaryTextColor,
                                ),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                    AppTheme.borderRadius),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: AppTheme.surfaceColor,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 16,
                              ),
                            ),
                            onChanged: (value) {
                              setState(() {
                                password = value;
                              });
                            },
                            onFieldSubmitted: (value) {
                              login();
                            },
                            validator: (password) {
                              return password!.length > 8
                                  ? null
                                  : "Password must be 8 characters long";
                            },
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Forgot password
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              // Navigate to forgot password page
                            },
                            child: Text(
                              "Forgot Password?",
                              style: TextStyle(
                                color: AppTheme.primaryColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Sign in button
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryColor,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    AppTheme.buttonRadius),
                              ),
                            ),
                            onPressed: () {
                              login();
                            },
                            child: Text(
                              "Sign In",
                              style: AppTheme.buttonStyle,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Register link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Don't have an account? ",
                              style: AppTheme.bodyStyle.copyWith(
                                color: AppTheme.secondaryTextColor,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                goto(context, Register());
                              },
                              child: Text(
                                "Register",
                                style: AppTheme.bodyStyle.copyWith(
                                  color: AppTheme.primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  login() async {
    if (formkey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      await authService.login(email!, password).then((value) async {
        if (value != null) {
          QuerySnapshot snapshot =
              await DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
                  .getUserData(email!);
          await HelperFunction.saveLoggedInStatus(true);
          await HelperFunction.saveUserEmail(email!);
          await HelperFunction.saveUserName(snapshot.docs[0]['userName']);
          goto(context, HomePage());
        } else {
          showSnackBar(context, "Wrong Email or Password", Colors.red);
          setState(() {
            _isLoading = false;
          });
        }
      });
    }
  }
}
