// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'dart:async';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

class ViewStatus extends StatefulWidget {
  final String mystatus;
  const ViewStatus({super.key, required this.mystatus});

  @override
  State<ViewStatus> createState() => _ViewStatusState();
}

class _ViewStatusState extends State<ViewStatus> with TickerProviderStateMixin {
  late AnimationController controller;

  @override
  void initState() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    // TODO: implement initState
    controller = AnimationController(
      /// [AnimationController]s can be created with `vsync: this` because of
      /// [TickerProviderStateMixin].
      vsync: this,
      duration: const Duration(seconds: 5),
    )..addListener(() {
        setState(() {});
      });
    controller.repeat(reverse: true);
    super.initState();
    Timer(Duration(seconds: 5), () {
      Navigator.pop(context);
    });
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
              image: NetworkImage(widget.mystatus), fit: BoxFit.cover),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: 5,
                  sigmaY: 5,
                ),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Container(
                      width: double.infinity,
                      child: Image.network(widget.mystatus)),
                )),
          ),
        ),
      ),
      bottomSheet: LinearProgressIndicator(
        value: controller.value,
      ),
    );
  }
}
