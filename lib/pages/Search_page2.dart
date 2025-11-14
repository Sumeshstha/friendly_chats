import 'package:flutter/material.dart';
import 'package:friendly_chat/Widgets/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:friendly_chat/pages/Homepage.dart';
import 'package:friendly_chat/pages/ProfilePage.dart';
import 'package:friendly_chat/services/database_service.dart';
import 'package:friendly_chat/Theme/app_theme.dart';
import 'package:shimmer/shimmer.dart';

class SearchPage2 extends StatefulWidget {
  final String currentUserName;
  final String currentUserEmail;
  const SearchPage2(
      {super.key,
      required this.currentUserEmail,
      required this.currentUserName});

  @override
  State<SearchPage2> createState() {
    return _SearchPage2State();
  }
}

class _SearchPage2State extends State<SearchPage2> {
  final formkey = GlobalKey<FormState>();
  String? searched;
  bool _isLoading = false;
  String? username;
  String? uidSearched;
  QuerySnapshot? snapshot;
  bool _friendAdded = true;
  List<DocumentSnapshot>? list;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppTheme.surfaceColor,
        title: Text(
          "Find Friends",
          style: AppTheme.headingStyle.copyWith(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: AppTheme.primaryTextColor,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: _isLoading ? _buildLoadingState() : _buildSearchResults(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        boxShadow: AppTheme.cardShadow,
      ),
      child: Form(
        key: formkey,
        child: TextFormField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: "Search by username",
            hintStyle: TextStyle(color: AppTheme.hintTextColor),
            prefixIcon: Icon(Icons.search, color: AppTheme.primaryColor),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: Icon(Icons.clear, color: AppTheme.secondaryTextColor),
                    onPressed: () {
                      setState(() {
                        _searchController.clear();
                        searched = null;
                        username = null;
                      });
                    },
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.borderRadius),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Colors.grey[100],
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 16,
            ),
          ),
          onChanged: (value) {
            setState(() {
              searched = value;
            });
          },
          onFieldSubmitted: (value) {
            search();
          },
          validator: (searched) {
            return searched!.isNotEmpty ? null : "Username cannot be empty";
          },
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    if (username != null) {
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: snapshot!.docs.length,
        itemBuilder: (context, index) {
          return _buildUserCard(
            snapshot!.docs[index]['userName'],
            snapshot!.docs[index]["email"],
            snapshot!.docs[index]['uid'],
          );
        },
      );
    } else {
      return _buildEmptyState();
    }
  }

  Widget _buildUserCard(String userName, String email, String uid) {
    return FutureBuilder<String>(
      future: DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
          .getUserProfilePicture(userName),
      builder: (context, snapshot) {
        String profilePic = '';
        if (snapshot.hasData) {
          profilePic = snapshot.data ?? '';
        }
        
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.borderRadius),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: AppTheme.primaryColor.withOpacity(0.2),
                  backgroundImage: (profilePic.isNotEmpty)
                      ? NetworkImage(profilePic)
                      : null,
                  child: (profilePic.isEmpty)
                      ? Text(
                          userName[0].toUpperCase(),
                          style: TextStyle(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userName,
                        style: AppTheme.subheadingStyle,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        email,
                        style: AppTheme.captionStyle,
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    createChat(userName, uid);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.buttonRadius),
                    ),
                  ),
                  child: const Text("Add"),
                ),
              ],
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
            Icons.person_search,
            size: 80,
            color: AppTheme.secondaryTextColor.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            "Find friends to chat with",
            style: AppTheme.headingStyle.copyWith(
              color: AppTheme.secondaryTextColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Search by username to get started",
            style: AppTheme.bodyStyle.copyWith(
              color: AppTheme.secondaryTextColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 3,
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
                  Container(
                    width: 60,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.circular(AppTheme.buttonRadius),
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

  search() async {
    if (formkey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      await DatabaseService().searchByUsername(searched!).then(
        (value) {
          snapshot = value;
          if (snapshot!.docs.isNotEmpty) {
            setState(() {
              _isLoading = false;
              username = snapshot!.docs[0]['userName'];
            });
          } else {
            setState(() {
              _isLoading = false;
            });
            showSnackBar(context, "User doesn't exist", AppTheme.errorColor);
          }
        },
      );
    }
  }

  createChat(String userName2, String uid2) async {
    setState(() {
      _isLoading = true;
    });
    await DatabaseService()
        .check(FirebaseAuth.instance.currentUser!.uid, uid2)
        .then((value) async {
      QuerySnapshot snap = value;
      if (snap.size == 0) {
        await DatabaseService()
            .createChatWithFriend(FirebaseAuth.instance.currentUser!.uid,
                widget.currentUserName, uid2, userName2)
            .then((value) {
          showSnackBar(
              context, "Chat created successfully", AppTheme.successColor);
          goto(context, HomePage());
        });
      } else {
        showSnackBar(context, "Chat already exists", AppTheme.errorColor);
        setState(() {
          _isLoading = false;
        });
      }
    });
  }
}
