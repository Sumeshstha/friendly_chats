// ignore: depend_on_referenced_packages
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:friendly_chat/Widgets/widgets.dart';
import 'package:friendly_chat/helper/helper_function.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:friendly_chat/pages/ChatPage.dart';
import 'package:friendly_chat/pages/Search_page2.dart';
import 'package:friendly_chat/pages/StartPage.dart';
import 'package:friendly_chat/pages/picprofile.dart';
import 'package:friendly_chat/services/database_service.dart';
import 'package:friendly_chat/Theme/app_theme.dart';
import '../services/auth_service.dart';
import 'login.dart';
// ignore: duplicate_import
import 'ProfilePage.dart';
import 'dart:io';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? userEmail;
  String? userName;
  Stream? streamSnapshot;
  var chats = [];
  String? chatName;
  String? chatId;
  AuthService authService = AuthService();

  @override
  void initState() {
    getUserData();
    super.initState();
  }

  getUserData() async {
    await HelperFunction.getUserEmail().then((value) {
      userEmail = value;
    });
    await DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
        .getUserData(userEmail!)
        .then((value) {
      QuerySnapshot snap = value;
      setState(() {
        userName = snap.docs[0]['userName'];
      });
    });
    await DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
        .getUserChats()
        .then((value) {
      setState(() {
        streamSnapshot = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppTheme.surfaceColor,
        actions: [
          IconButton(
            onPressed: () {
              goto(
                  context,
                  SearchPage2(
                    currentUserEmail: userEmail!,
                    currentUserName: userName!,
                  ));
            },
            icon: Icon(
              Icons.search,
              color: AppTheme.primaryTextColor,
            ),
          ),
          IconButton(
            onPressed: () {
              // Add notification action
            },
            icon: Icon(
              Icons.notifications_outlined,
              color: AppTheme.primaryTextColor,
            ),
          ),
          const SizedBox(width: 8),
        ],
        centerTitle: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Messages",
              style: AppTheme.headingStyle.copyWith(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              "Your conversations",
              style: AppTheme.captionStyle,
            ),
          ],
        ),
      ),
      drawer: _buildDrawer(),
      body: chatList(),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: AppTheme.surfaceColor,
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: AppTheme.primaryColor.withOpacity(0.2),
                  child: Text(
                    userName != null ? userName![0].toUpperCase() : "U",
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  userName ?? "User",
                  style: AppTheme.subheadingStyle,
                ),
                // Text(
                //   userEmail ?? "email@example.com",
                //   style: AppTheme.captionStyle,
                // ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildDrawerItem(
                  icon: Icons.person_outline,
                  title: "Profile",
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProfilePage(
                        userEmail: userEmail!,
                        userName: userName!,
                        userId: FirebaseAuth.instance.currentUser!.uid,
                      ),
                    ),
                  ),
                ),
                _buildDrawerItem(
                  icon: Icons.photo_camera_outlined,
                  title: "Profile Picture",
                  onTap: () {
                    goto(
                      context,
                      CompleteProfile(
                        uid: FirebaseAuth.instance.currentUser!.uid,
                      ),
                    );
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.settings_outlined,
                  title: "Settings",
                  onTap: () {
                    // Navigate to settings
                  },
                ),
                const Divider(),
                _buildDrawerItem(
                  icon: Icons.logout,
                  title: "Logout",
                  textColor: AppTheme.errorColor,
                  iconColor: AppTheme.errorColor,
                  onTap: () {
                    logout();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? textColor,
    Color? iconColor,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: iconColor ?? AppTheme.primaryTextColor,
      ),
      title: Text(
        title,
        style: AppTheme.bodyStyle.copyWith(
          color: textColor ?? AppTheme.primaryTextColor,
        ),
      ),
      onTap: onTap,
    );
  }

  chatList() {
    return StreamBuilder(
      stream: streamSnapshot,
      builder: (context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data['chats'] != null) {
            if (snapshot.data['chats'].length != 0) {
              chats = snapshot.data["chats"];
              return ListView.builder(
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                itemCount: chats.length,
                itemBuilder: (context, index) {
                  chatName = getChatName(chats[chats.length - (index + 1)]);
                  chatId = getChatId(chats[chats.length - (index + 1)]);
                  if (chatName != null) {
                    return _buildChatItem(chatName!, chatId!);
                  } else {
                    return const SizedBox.shrink();
                  }
                },
              );
            } else {
              return _buildEmptyState();
            }
          } else {
            return _buildEmptyState();
          }
        } else {
          return _buildLoadingState();
        }
      },
    );
  }

  Widget _buildChatItem(String name, String id) {
    return FutureBuilder<String>(
      future: getRecentMessage(id),
      builder: (context, snapshot) {
        String recentMessage = "Tap to start chatting";
        if (snapshot.connectionState == ConnectionState.waiting) {
          recentMessage = "Loading...";
        } else if (snapshot.hasData) {
          recentMessage = snapshot.data!;
        }

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.borderRadius),
          ),
          child: InkWell(
            onTap: () {
              goto(
                context,
                ChatPage(
                  currentUserName: userName!,
                  chatId: id,
                  friendName: name,
                ),
              );
            },
            borderRadius: BorderRadius.circular(AppTheme.borderRadius),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: AppTheme.primaryColor.withOpacity(0.2),
                    child: Text(
                      name[0].toUpperCase(),
                      style: const TextStyle(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name, style: AppTheme.subheadingStyle),
                        const SizedBox(height: 4),
                        Text(
                            recentMessage == ""
                                ? "Tap to start chatting"
                                : recentMessage,
                            style: AppTheme.captionStyle),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: AppTheme.secondaryTextColor,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 80,
            color: AppTheme.secondaryTextColor.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            "No conversations yet",
            style: AppTheme.headingStyle.copyWith(
              color: AppTheme.secondaryTextColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Start a chat with your friends",
            style: AppTheme.bodyStyle.copyWith(
              color: AppTheme.secondaryTextColor,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              goto(
                context,
                SearchPage2(
                  currentUserEmail: userEmail!,
                  currentUserName: userName!,
                ),
              );
            },
            icon: const Icon(Icons.person_add),
            label: const Text("Find Friends"),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.buttonRadius),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Card(
            margin: const EdgeInsets.only(bottom: 12),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.borderRadius),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 120,
                          height: 16,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: 80,
                          height: 12,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  getChatName(String chatIdAndName) {
    String chatname = chatIdAndName.substring(chatIdAndName.indexOf("_") + 1);
    return chatname;
  }

  getChatId(String chatIdAndName) {
    return chatIdAndName.substring(0, chatIdAndName.indexOf("_"));
  }

  Future<String> getRecentMessage(String chatId) async {
    DocumentSnapshot chatsnapshot =
        await DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
            .getChatData(chatId);
    if (chatsnapshot.exists && chatsnapshot.data() != null) {
      return chatsnapshot.get("recentMessage") ?? "Tap to start chatting";
    } else {
      return "Tap to start chatting";
    }
  }

  logout() {
    setState(() {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text("Are you sure?"),
              actions: [
                TextButton(
                    onPressed: () {
                      authService
                          .logout()
                          .whenComplete(() => goto(context, LoginPage()));
                    },
                    child: const Text("Yes")),
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text("No"))
              ],
            );
          });
    });
  }
}
