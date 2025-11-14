import 'dart:developer';
import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:friendly_chat/Widgets/widgets.dart';
import 'package:friendly_chat/pages/Homepage.dart';
import 'package:friendly_chat/services/database_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:friendly_chat/Theme/app_theme.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:cloud_firestore/cloud_firestore.dart';

class CompleteProfile extends StatefulWidget {
  final String uid;

  const CompleteProfile({super.key, required this.uid});

  @override
  State<CompleteProfile> createState() => _completeprofileState();
}

class _completeprofileState extends State<CompleteProfile> {
  XFile? imageFile;
  String? imageUrl;
  String? existingImageUrl;
  String? userName;
  bool _isUploading = false;
  bool _isLoading = true;
  final TextEditingController _bioController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadExistingData();
  }

  Future<void> _loadExistingData() async {
    try {
      log('=== Loading Existing Profile Data ===');
      log('User ID: ${widget.uid}');
      
      final userDoc = await DatabaseService(uid: widget.uid)
          .userCollection
          .doc(widget.uid)
          .get();
      
      log('User document exists: ${userDoc.exists}');
      
      if (userDoc.exists) {
        final data = userDoc.data() as Map<String, dynamic>?;
        log('Document data: $data');
        
        final profileUrl = data?['profilePictureUrl'] ?? '';
        final bio = data?['bio'] ?? '';
        final username = data?['userName'] ?? '';
        
        log('Profile picture URL: "$profileUrl"');
        log('Bio: "$bio"');
        log('Username: "$username"');
        log('URL is empty: ${profileUrl.isEmpty}');
        
        setState(() {
          existingImageUrl = profileUrl;
          _bioController.text = bio;
          userName = username;
          _isLoading = false;
        });
        
        log('State updated. existingImageUrl: "$existingImageUrl"');
      } else {
        log('User document does not exist!');
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e, stackTrace) {
      log("Error loading profile data: ${e.toString()}");
      log('Stack trace: $stackTrace');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _bioController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.surfaceColor,
        elevation: 0,
        centerTitle: true,
        title: Text(
          existingImageUrl != null && existingImageUrl!.isNotEmpty
              ? "Edit Profile"
              : "Complete Profile",
          style: AppTheme.headingStyle.copyWith(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: AppTheme.primaryTextColor,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: AppTheme.primaryColor,
              ),
            )
          : _isUploading
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(
                        color: AppTheme.primaryColor,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "Uploading profile...",
                        style: AppTheme.bodyStyle.copyWith(
                          color: AppTheme.secondaryTextColor,
                        ),
                      ),
                    ],
                  ),
                )
              : SafeArea(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 20,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 20),
                        _buildProfilePictureSection(),
                        const SizedBox(height: 40),
                        _buildBioSection(),
                        const SizedBox(height: 40),
                        _buildSubmitButton(),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildProfilePictureSection() {
    return Column(
      children: [
        Text(
          "Profile Picture",
          style: AppTheme.headingStyle.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Add a profile photo so your friends can recognize you",
          textAlign: TextAlign.center,
          style: AppTheme.captionStyle,
        ),
        const SizedBox(height: 24),
        Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppTheme.primaryColor.withOpacity(0.3),
                  width: 3,
                ),
                boxShadow: AppTheme.cardShadow,
              ),
              child: _buildProfileAvatar(),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor,
                  shape: BoxShape.circle,
                  boxShadow: AppTheme.elevatedShadow,
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.camera_alt,
                    color: Colors.white,
                    size: 20,
                  ),
                  onPressed: showphotoOptions,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProfileAvatar() {
    // Show newly selected image
    if (imageFile != null) {
      return FutureBuilder<Uint8List>(
        future: imageFile!.readAsBytes(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.hasData) {
            return CircleAvatar(
              radius: 70,
              backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
              backgroundImage: MemoryImage(snapshot.data!),
            );
          }
          return CircleAvatar(
            radius: 70,
            backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
            child: const CircularProgressIndicator(
              color: AppTheme.primaryColor,
            ),
          );
        },
      );
    }
    
    // Show existing image from Firebase
    if (existingImageUrl != null && existingImageUrl!.isNotEmpty) {
      log('Displaying existing image: $existingImageUrl');
      return CircleAvatar(
        radius: 70,
        backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
        backgroundImage: NetworkImage(existingImageUrl!),
        onBackgroundImageError: (exception, stackTrace) {
          log('Error loading profile picture: $exception');
          log('URL: $existingImageUrl');
          log('Stack trace: $stackTrace');
        },
      );
    }
    
    // Show default placeholder with user initials
    log('Showing placeholder with initials');
    final initial = userName != null && userName!.isNotEmpty 
        ? userName![0].toUpperCase() 
        : 'U';
    
    return CircleAvatar(
      radius: 70,
      backgroundColor: AppTheme.primaryColor.withOpacity(0.2),
      child: Text(
        initial,
        style: TextStyle(
          fontSize: 48,
          fontWeight: FontWeight.bold,
          color: AppTheme.primaryColor,
        ),
      ),
    );
  }

  Widget _buildBioSection() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.borderRadius),
        side: BorderSide(
          color: AppTheme.primaryColor.withOpacity(0.2),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: AppTheme.primaryColor,
                  size: 22,
                ),
                const SizedBox(width: 8),
                Text(
                  "Bio",
                  style: AppTheme.subheadingStyle.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              "Tell us a bit about yourself",
              style: AppTheme.captionStyle,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _bioController,
              maxLines: 4,
              maxLength: 200,
              style: AppTheme.bodyStyle,
              decoration: InputDecoration(
                hintText: "e.g., Love coding, coffee enthusiast, and always learning!",
                hintStyle: AppTheme.captionStyle.copyWith(
                  fontStyle: FontStyle.italic,
                ),
                filled: true,
                fillColor: AppTheme.backgroundColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: AppTheme.primaryColor.withOpacity(0.3),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppTheme.primaryColor,
                    width: 2,
                  ),
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    final bool isEditing = existingImageUrl != null && existingImageUrl!.isNotEmpty;
    
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: checkvalues,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.buttonRadius),
          ),
          elevation: 2,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(isEditing ? Icons.save : Icons.check_circle_outline),
            const SizedBox(width: 8),
            Text(
              isEditing ? "Update Profile" : "Complete Profile",
              style: AppTheme.buttonStyle.copyWith(
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showphotoOptions() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.borderRadius),
          ),
          title: Row(
            children: [
              Icon(
                Icons.photo_library,
                color: AppTheme.primaryColor,
              ),
              const SizedBox(width: 8),
              Text(
                "Upload Profile Picture",
                style: AppTheme.subheadingStyle.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildPhotoOption(
                icon: Icons.photo_album,
                title: "Select from Gallery",
                subtitle: "Choose from your photos",
                onTap: () {
                  Navigator.pop(context);
                  selectimage(ImageSource.gallery);
                },
              ),
              const SizedBox(height: 12),
              _buildPhotoOption(
                icon: Icons.camera_alt,
                title: "Take a Photo",
                subtitle: "Use your camera",
                onTap: () {
                  Navigator.pop(context);
                  selectimage(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPhotoOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: AppTheme.primaryColor.withOpacity(0.2),
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: AppTheme.primaryColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTheme.bodyStyle.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: AppTheme.captionStyle,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppTheme.secondaryTextColor,
            ),
          ],
        ),
      ),
    );
  }

  //image source will collect image from gallery or camera
  void selectimage(ImageSource source) async {
    XFile? pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      cropImage(pickedFile);
    }
  }

  //Process selected image
  void cropImage(XFile file) async {
    setState(() {
      imageFile = file;
      log("Image selected");
    });
    
    // Show success message
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Text('Photo selected successfully!'),
            ],
          ),
          backgroundColor: AppTheme.successColor,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  void checkvalues() {
    String bioInfo = _bioController.text.trim();
    final bool isEditing = existingImageUrl != null && existingImageUrl!.isNotEmpty;

    // Only require bio for new profiles, not edits
    if (!isEditing && bioInfo.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter a bio'),
          backgroundColor: AppTheme.warningColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    // Check if there's a new image or existing image
    if (imageFile == null && !isEditing) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select a profile picture'),
          backgroundColor: AppTheme.warningColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    log("=== Pre-Upload Diagnostics ===");
    log("User authenticated: ${FirebaseAuth.instance.currentUser != null}");
    log("User UID: ${FirebaseAuth.instance.currentUser?.uid}");
    log("Image file selected: ${imageFile != null}");
    log("Is editing mode: $isEditing");
    log("Bio text: $bioInfo");
    
    // Test Firebase Storage connectivity
    _testFirebaseStorageConnectivity();
    
    log("Starting upload process...");
    uploadData();
  }
  
  Future<void> _testFirebaseStorageConnectivity() async {
    try {
      log("Testing Firebase Storage connectivity...");
      final testRef = FirebaseStorage.instance.ref("test_connectivity");
      log("✓ Firebase Storage instance initialized");
      log("  Default bucket: ${FirebaseStorage.instance.bucket}");
    } catch (e) {
      log("❌ Firebase Storage connectivity test failed: $e");
    }
  }

  uploadData() async {
    setState(() {
      _isUploading = true;
    });

    try {
      log("=== Starting Profile Upload ===");
      log("User ID: ${widget.uid}");
      
      String finalImageUrl = existingImageUrl ?? '';
      log("Existing image URL: $existingImageUrl");
      
      // Only upload new image if one was selected
      if (imageFile != null) {
        log("=== Firebase Storage Upload Process ===");
        log("New image selected, preparing upload...");
        
        // Read image data as bytes for cross-platform compatibility
        log("Reading image bytes...");
        final bytes = await imageFile!.readAsBytes();
        log("✓ Image bytes read successfully: ${bytes.length} bytes");
        
        // Verify bytes are not empty
        if (bytes.isEmpty) {
          throw Exception('Image bytes are empty! Cannot upload.');
        }
        
        // Upload to Firebase Storage
        log("Creating storage reference...");
        final storageRef = FirebaseStorage.instance
            .ref("profilePictures")
            .child(widget.uid.toString());
        log("✓ Storage reference created");
        log("  Path: ${storageRef.fullPath}");
        log("  Bucket: ${storageRef.bucket}");
        
        log("Initiating upload to Firebase Storage...");
        UploadTask uploadTask = storageRef.putData(
          bytes,
          SettableMetadata(
            contentType: 'image/jpeg',
            customMetadata: {
              'uploadedBy': widget.uid,
              'uploadTime': DateTime.now().toIso8601String(),
            },
          ),
        );
        
        // Monitor upload progress
        uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
          double progress = snapshot.bytesTransferred / snapshot.totalBytes;
          log("Upload progress: ${(progress * 100).toStringAsFixed(1)}% (${snapshot.bytesTransferred}/${snapshot.totalBytes} bytes)");
        });
        
        log("Waiting for upload to complete...");
        TaskSnapshot snapshot = await uploadTask;
        
        log("✓ Upload completed!");
        log("  State: ${snapshot.state}");
        log("  Bytes transferred: ${snapshot.bytesTransferred}");
        log("  Total bytes: ${snapshot.totalBytes}");
        
        // Verify upload was successful
        if (snapshot.state != TaskState.success) {
          throw Exception('Upload failed with state: ${snapshot.state}');
        }
        
        log("Getting download URL...");
        finalImageUrl = await snapshot.ref.getDownloadURL();
        log("✓ Download URL acquired successfully!");
        log("  URL: $finalImageUrl");
        
        // Verify URL is not empty
        if (finalImageUrl.isEmpty) {
          throw Exception('Download URL is empty!');
        }
        
        log("=== Firebase Storage Upload: SUCCESS ===");
      } else {
        log("No new image selected, keeping existing URL: $existingImageUrl");
      }
      
      log("Updating Firestore with image URL: $finalImageUrl");
      log("Bio: ${_bioController.text.trim()}");
      log("Current user UID: ${FirebaseAuth.instance.currentUser!.uid}");
      
      // Update Firestore with image URL and bio
      await DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
          .uploadImageandProfilePicture(finalImageUrl, _bioController.text.trim());
      
      log("=== Profile Upload Complete ===");
      log("Profile picture should now be visible across the app");

      setState(() {
        _isUploading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              existingImageUrl != null && existingImageUrl!.isNotEmpty
                  ? 'Profile updated successfully!'
                  : 'Profile completed successfully!'
            ),
            backgroundColor: AppTheme.successColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        // Navigate back to refresh HomePage
        Navigator.pop(context);
        // Alternative: If you want to ensure fresh HomePage state
        // Navigator.pushAndRemoveUntil(
        //   context,
        //   MaterialPageRoute(builder: (context) => const HomePage()),
        //   (route) => false,
        // );
      }
    } catch (e, stackTrace) {
      log("=== Error Uploading Profile ===");
      log("❌ Error Type: ${e.runtimeType}");
      log("❌ Error Message: ${e.toString()}");
      
      // Check for specific Firebase Storage errors
      if (e.toString().contains('permission') || e.toString().contains('unauthorized')) {
        log("❌ FIREBASE STORAGE PERMISSION ERROR!");
        log("   Firebase Storage rules may not allow write access.");
        log("   Check: https://console.firebase.google.com/project/friendlychat-a8bbc/storage/rules");
      } else if (e.toString().contains('network') || e.toString().contains('connection')) {
        log("❌ NETWORK ERROR!");
        log("   Check your internet connection and Firebase configuration.");
      } else if (e.toString().contains('storage') || e.toString().contains('bucket')) {
        log("❌ FIREBASE STORAGE CONFIGURATION ERROR!");
        log("   Storage bucket may not be configured correctly.");
        log("   Current bucket: friendlychat-a8bbc.appspot.com");
      }
      
      log("❌ Stack trace:");
      log(stackTrace.toString());
      
      setState(() {
        _isUploading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error uploading profile: ${e.toString()}'),
            backgroundColor: AppTheme.errorColor,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }
}
