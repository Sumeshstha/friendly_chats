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
  
  
  const CompleteProfile({super.key});

  @override
  State<CompleteProfile> createState() => _completeprofileState();
}
class _completeprofileState extends State<CompleteProfile> {

//import dart:io file and marking it as late so it cannot be null
//storing both pic and bio info
File? imageFile;
String? imageUrl;
String? bio;

//for full editing text
TextEditingController BioController = TextEditingController();

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
        imageFile = File(croppedImage.path); // Use File constructor to create a new File object
      });
   }
  }


  //below function discribes circle profile clicking system and showing two option
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
                selectimage(ImageSource.camera);
              },
              leading: Icon(Icons.camera_alt),
              title: Text("Take a Photo"),
            ),
          ]),
      );
     });
  }

  void checkvalues(){
      String Bioinfo = BioController.text.trim();

      if(Bioinfo == " " || Bioinfo == null)
      {
        print("Please fill all the fields");
      }
      else{
        uploadData();
      }

  }
  //users pic details
  void uploadData() async{
    await DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid).uploadImage(FirebaseAuth.instance.currentUser!.uid, imageFile!).then((value)async {
      TaskSnapshot snap = value;
      imageUrl = await snap.ref.getDownloadURL();
    });
    bio = BioController.toString();
    await DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid).uploadImageandProfilePicture(imageUrl!, bio!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        centerTitle: true,
        automaticallyImplyLeading: false,
        
        title: Text("Profile"),
      ), 
      body: SafeArea(
        //creates box behind profile text
        child: Container(
          padding: EdgeInsets.symmetric(
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
              ),
              //creates submit button
              SizedBox(height: 20,),

              CupertinoButton(
                onPressed: () {
                 
                },
                color: Theme.of(context).primaryColor,
                child: Text("Submit"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
