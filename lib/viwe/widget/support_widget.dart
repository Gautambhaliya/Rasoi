import 'package:flutter/material.dart';

class AppWidget {
  static TextStyle boldfeidtextstyle() {
    return TextStyle(
        color: Colors.black,
        fontSize: 13.2,
        fontWeight: FontWeight.bold,
        fontFamily: 'roboto');
  }

  static TextStyle lightfildtextstyle() {
    return TextStyle(
        fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black
        // fontFamily: 'Bebas'
        );
  }

  static TextStyle TitleText() {
    return TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Colors.black,
        fontFamily: 'Aleo');
  }

  static TextStyle Recipe_Title() {
    return TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: Colors.black,
        fontFamily: 'merri');
  }

  static TextStyle Details() {
    return TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: Colors.grey[700],
        fontFamily: 'roboto');
  }

  static TextStyle Recipedatatitle() {
    return TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.black,
        fontFamily: 'Aleo');
  }

  static TextStyle content() {
    return TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.bold,
      fontFamily: 'Archivo',
    );
  }

  static TextStyle mainrecipenametitle() {
    return TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.bold,
      fontFamily: 'merri',
    );
  }
}
