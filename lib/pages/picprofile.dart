import 'dart:io';
import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:friendly_chat/services/database_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class CompleteProfile extends StatefulWidget {
  final String uid;
  
  const CompleteProfile({super.key, required this.uid});

  @override
  State<CompleteProfile> createState() => _completeprofileState();
}
class _completeprofileState extends State<CompleteProfile> {

//import dart:io file and marking it as late so it cannot be null
//storing both pic and bio info
File? imageFile;
String? imageUrl;
String? bio;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        centerTitle: true,
        
        title: Text("Profile"),
      ), 
      body: SafeArea(
        //creates box behind profile text
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 40,
          ),
          child: ListView(
            children: [
              SizedBox(height: 20),

              CupertinoButton(
                onPressed: () {
                  showphotoOptions();
                },
                padding: EdgeInsets.all(0),
                child: CircleAvatar(
                backgroundImage: (imageFile != null) ? FileImage(imageFile!):null,
                radius: 60,
                
                  child: (imageFile==null) ? Icon(Icons.person, size: 60,) :null,
                ),
              ),
              SizedBox(height: 20),

                TextField(
                decoration: InputDecoration(
                  labelText: "Bio",
                ),
                onChanged: (value){
                  bio = value;
                },
              ),
              //creates submit button
              SizedBox(height: 20,),

              ElevatedButton(
                onPressed: () {
                 checkvalues();
                },
                style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).primaryColor),
                child: Text("Submit"),
              ),
            ],
          ),
        ),
      ),
    );
  }
  void showphotoOptions(){
    //shows dialog box
    showDialog(context: context,
     builder: (context){
      //return dialog box or widgets from below return 
      return AlertDialog(
        title: Text("Upload Profile Picture"),
        content: Column(
          //minimizes the column size
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              onTap:() {
                Navigator.pop(context);
                selectimage(ImageSource.gallery);
              },
              //shows icons from packages
              leading: Icon(Icons.photo_album),
              //gives text in dialog box
              title: Text("Select from Gallery"),
            ),
            ListTile(
                onTap:() {
                  Navigator.of(context).pop();
                selectimage(ImageSource.camera);
              },
              leading: Icon(Icons.camera_alt),
              title: Text("Take a Photo"),
            ),
          ]),
      );
     });
  }
  //image source will collect image from gallery or camera
  void selectimage (ImageSource source) async
  {
    //picks image from the selected source Xfile:if user selectes the file but doesnot browers properly then it gives null so it is used!
   XFile? pickedFile = await ImagePicker().pickImage(source: source);
   if(pickedFile != null){
      cropImage(pickedFile);
   }
    
  }
    //In argument:(), we have to give xfile
  void cropImage (XFile file) async
  {
   CroppedFile? croppedImage = await ImageCropper().cropImage(
      sourcePath: file.path,
      aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
      compressQuality: 20,
    );
   if (croppedImage != null) {
      setState(() {
        imageFile = File(croppedImage.path); 
        log("Image saved in imagefile");// Use File constructor to create a new File object
      });
   }
  }
  void checkvalues(){
      String Bioinfo = bio!;

      if(Bioinfo == " " || Bioinfo == null)
      {
        log("empty bio");
      }
      else{
        log("data is being uploaded");
        uploadData();
      }

  }
  uploadData() async{
    log("In the upload data function");
    UploadTask uploadTask =  FirebaseStorage.instance.ref("profilePictures").child(widget.uid.toString()).putFile(imageFile!);
    log("after storage");
    TaskSnapshot snapshot = await uploadTask;
    log("snapshot taken");
    imageUrl = await snapshot.ref.getDownloadURL();
    log("url aquired");
    await DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid).uploadImageandProfilePicture(imageUrl!, bio!);
    log("added to firestore database");
  }
}