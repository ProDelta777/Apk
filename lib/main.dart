import 'package:flutter/material.dart';

void main() {
  // Ultra-minimal startup to debug if the crash is inside Flutter or native code
  runApp(
    const MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.blue,
        body: Center(
          child: Text(
            'TESTING LAUNCH',
            style: TextStyle(color: Colors.white, fontSize: 24),
          ),
        ),
      ),
    ),
  );
}
