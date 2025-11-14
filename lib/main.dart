import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:friendly_chat/Theme/app_theme.dart';
import 'package:friendly_chat/helper/helper_function.dart';
import 'package:friendly_chat/pages/ChatPage.dart';
import 'package:friendly_chat/pages/Homepage.dart';
import 'package:friendly_chat/pages/StartPage.dart';
import 'package:friendly_chat/pages/login.dart';
import 'package:friendly_chat/pages/register.dart';
import 'package:friendly_chat/shared/constants.dart';
import 'package:friendly_chat/pages/picprofile.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    // run the initialization for web
    await Firebase.initializeApp(
        options: FirebaseOptions(
            apiKey: constants.apiKey,
            appId: constants.appId,
            messagingSenderId: constants.messagingSenderId,
            projectId: constants.projectId,
            storageBucket: constants.storageBucket));
  } else {
    // run the initialization for android, ios
    await Firebase.initializeApp();
  }

  runApp(const FriendlyChatApp());
}

class FriendlyChatApp extends StatefulWidget {
  const FriendlyChatApp({Key? key}) : super(key: key);

  @override
  State<FriendlyChatApp> createState() => _FriendlyChatAppState();
}

class _FriendlyChatAppState extends State<FriendlyChatApp> {
  @override
  void initState() {
    getUserLoggedInStatus();
    super.initState();
  }

  bool _isSignedIn = false;
  getUserLoggedInStatus() async {
    await HelperFunction.getUserLoggedInStatus().then((value) {
      if (value != null) {
        setState(() {
          _isSignedIn = value;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Friendly Chat',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      home: _isSignedIn ? const HomePage() : const StartPage(),
    );
  }
}
