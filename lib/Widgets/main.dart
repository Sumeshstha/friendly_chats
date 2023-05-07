import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:friendly_chat/helper/helper_function.dart';
import 'package:friendly_chat/pages/ChatPage.dart';
import 'package:friendly_chat/pages/Homepage.dart';
import 'package:friendly_chat/pages/StartPage.dart';
import 'package:friendly_chat/pages/login.dart';
import 'package:friendly_chat/pages/register.dart';
import 'package:friendly_chat/shared/constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    // run the initializtion for web
    await Firebase.initializeApp(
        options: FirebaseOptions(
            apiKey: constants.apiKey,
            appId: constants.appId,
            messagingSenderId: constants.messagingSenderId,
            projectId: constants.projectId));
  } else {
    // run the initializtion for andriod, ios
    await Firebase.initializeApp();
  }

  runApp(const chatapp());
}

class chatapp extends StatefulWidget {
  const chatapp({Key? key}) : super(key: key);

  @override
  State<chatapp> createState() => _chatappState();
}

class _chatappState extends State<chatapp> {
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
        theme: ThemeData(
          primaryColor: Colors.orange,
        ),
        darkTheme: ThemeData.dark(),
        themeMode: ThemeMode.system,
        debugShowCheckedModeBanner: false,
        home: _isSignedIn ? HomePage() : StartPage());
  }
}
