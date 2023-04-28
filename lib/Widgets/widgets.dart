import 'package:flutter/material.dart';


goto(context, page){
  Navigator.push(context, MaterialPageRoute(builder: (context)=>page));
}

void showSnackBar (context, errorMessage, color){
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content:Text(errorMessage),
      backgroundColor: color,
      duration: const Duration(seconds: 3),)
  );
}


const textInputDecoration = InputDecoration(
  fillColor: Color.fromARGB(255, 216, 214, 214),
  labelStyle: TextStyle(color: Colors.black),
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(
      color:Color.fromARGB(255, 189, 189, 189),
      width: 1
    )),
    enabledBorder: OutlineInputBorder(
    borderSide: BorderSide(
      color: Colors.white,
      width: 1
    )
  ),
  errorBorder: OutlineInputBorder(
    borderSide: BorderSide(
      color: Colors.red,
      width: 1
    )
  )
);