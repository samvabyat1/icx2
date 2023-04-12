// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

class Message extends StatelessWidget {
  const Message({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            ShaderMask(
              shaderCallback: (Rect bounds) {
                return SweepGradient(
                  colors: [
                    Colors.pinkAccent,
                    Colors.deepPurpleAccent,
                    Colors.red
                  ],
                ).createShader(bounds);
              },
              child: Icon(
                CupertinoIcons.paperplane_fill,
                color: Colors.purpleAccent,
              ),
            ),
            SizedBox(
              width: 10,
            ),
            Text(
              'Messages',
              style: TextStyle(
                color: Colors.black,
                fontSize: 25,
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(50.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ShaderMask(
              shaderCallback: (Rect bounds) {
                return SweepGradient(
                  colors: [
                    Colors.pinkAccent,
                    Colors.deepPurpleAccent,
                    Colors.red
                  ],
                ).createShader(bounds);
              },
              child: Icon(
                CupertinoIcons.bolt_horizontal_circle,
                color: Colors.purpleAccent,
                size: 70,
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Text(
              "No messages",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20.0,
                color: Colors.black,
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Text(
              "This feature isn't available at this moment.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black54,
                fontSize: 14,
              ),
            )
          ],
        ),
      ),
    );
  }
}
