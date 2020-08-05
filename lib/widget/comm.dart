import 'package:flutter/material.dart';

AppBar appBar(title) {
  return AppBar(
    title: Text(
      title,
      style: TextStyle(color: Colors.white),
    ),
    iconTheme: IconThemeData(color: Colors.white),
  );
}
