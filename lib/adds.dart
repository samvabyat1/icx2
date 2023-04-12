// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, sort_child_properties_last

import 'dart:io';
import 'dart:ui';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import 'home.dart';

class AddStatus extends StatefulWidget {
  final String mystatus;
  const AddStatus({super.key, required this.mystatus});

  @override
  State<AddStatus> createState() => _AddStatusState();
}

class _AddStatusState extends State<AddStatus> {
  var fabstate = true;

  File? _image;
  Future _pickImage(ImageSource source) async {
    try {
      final image = await ImagePicker().pickImage(source: source);
      if (image == null) return;
      File? img = File(image.path);
      img = await _cropImage(imageFile: img);
      setState(() {
        _image = img;
      });
    } on PlatformException catch (e) {
      print(e);
      Navigator.pop(context);
    }
  }

  Future<File?> _cropImage({required File imageFile}) async {
    CroppedFile? croppedImage =
        await ImageCropper().cropImage(sourcePath: imageFile.path);

    if (croppedImage == null) return null;
    return File(croppedImage.path);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        decoration: BoxDecoration(
            image: (_image == null)
                ?(widget.mystatus.isEmpty)? (Home.profilepic.isEmpty)
                    ? DecorationImage(image: AssetImage('assets/feedmage.jpg'))
                    : DecorationImage(
                        image: NetworkImage(Home.profilepic), fit: BoxFit.cover):DecorationImage(
                    image: NetworkImage(widget.mystatus), fit: BoxFit.cover)
                : DecorationImage(
                    image: FileImage(_image!), fit: BoxFit.cover)),
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
                child: Stack(
                  children: [
                    Center(
                      child: Wrap(
                        children: [
                          InkWell(
                            onTap: () {
                              _pickImage(ImageSource.camera);
                            },
                            child: Column(
                              children: [
                                CircleAvatar(
                                  radius: 30,
                                  backgroundColor: Colors.pinkAccent,
                                  child: Icon(
                                    CupertinoIcons.camera,
                                    color: Colors.white,
                                  ),
                                ),
                                Text('Camera')
                              ],
                            ),
                          ),
                          SizedBox(
                            width: 30,
                          ),
                          InkWell(
                            onTap: () {
                              _pickImage(ImageSource.gallery);
                            },
                            child: Column(
                              children: [
                                CircleAvatar(
                                  radius: 30,
                                  backgroundColor: Colors.red,
                                  child: Icon(
                                    CupertinoIcons.photo,
                                    color: Colors.white,
                                  ),
                                ),
                                Text('Gallery')
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Visibility(
                      visible: _image != null,
                      child: Stack(
                        children: [
                          (_image == null)
                              ? Icon(Icons.add)
                              : Container(
                                  width: double.infinity,
                                  child: Image.file(
                                    _image!,
                                  )),
                          Positioned(
                            bottom: 15,
                            right: 15,
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  _image = null;
                                });
                              },
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(100),
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(
                                    sigmaX: 5,
                                    sigmaY: 5,
                                  ),
                                  child: CircleAvatar(
                                    radius: 30,
                                    backgroundColor: Colors.white54,
                                    child: Icon(
                                      CupertinoIcons.delete,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Visibility(
        visible: fabstate,
        child: FloatingActionButton(
          onPressed: () async {
            if (_image == null) {
              Fluttertoast.showToast(msg: 'Please choose a photo!');
            } else {
              setState(() {
                fabstate = false;
              });
              Fluttertoast.showToast(msg: 'Uploading');
              var imgref = FirebaseStorage.instance
                  .ref()
                  .child('status')
                  .child(Home.username);
              var url;

              DatabaseReference ref = FirebaseDatabase.instance
                  .ref()
                  .child('users')
                  .child(Home.username);

              try {
                await imgref.putFile(_image!);
                url = await imgref.getDownloadURL();

                ref.child('status').set(url.toString());

                Navigator.pop(context);
              } catch (e) {
                Fluttertoast.showToast(msg: 'Something went wrong!');
                print(e);
              }
            }
          },
          child: Container(
            width: 60,
            height: 60,
            child: Icon(
              CupertinoIcons.check_mark,
            ),
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: SweepGradient(
                  colors: <Color>[
                    Colors.pinkAccent,
                    Colors.deepPurpleAccent,
                    Colors.red
                  ],
                )),
          ),
        ),
      ),
    );
  }
}
