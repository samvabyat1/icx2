// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, sort_child_properties_last

import 'dart:io';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:icx2/feed.dart';
import 'package:icx2/home.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class Account extends StatefulWidget {
  final String username;
  const Account({super.key, required this.username});

  @override
  State<Account> createState() => _AccountState();
}

class _AccountState extends State<Account> {
  var posts = [], followers = [], following = [], postimg = [];
  var profilepic = '';
  var follow = false;

  void acc() {
    DatabaseReference ref =
        FirebaseDatabase.instance.ref().child('users').child(widget.username);
    DatabaseReference refp = FirebaseDatabase.instance.ref().child('posts');

    ref.onValue.listen((event) async {
      if (mounted) {
        setState(() {
    posts = [];
    followers = [];
    following = [];
    postimg = [];
          profilepic = (event.snapshot.child('profile').exists)
              ? event.snapshot.child('profile').value.toString()
              : '';

          for (final child in event.snapshot.child('followers').children) {
            followers.add(child.value.toString());
          }
          for (final child in event.snapshot.child('following').children) {
            following.add(child.value.toString());
          }

          if (followers.contains(Home.username)) {
            follow = true;
          } else {
            follow = false;
          }
        });
      }
      for (final child in event.snapshot.child('posts').children) {
        final snapshot =
            await refp.child(child.value.toString()).child('img').get();
        if (mounted) {
          setState(() {
            posts.insert(0, child.value.toString());
            postimg.insert(0, snapshot.value.toString());
          });
        }
      }
    });
  }

  void startfollow() {
    DatabaseReference ref =
        FirebaseDatabase.instance.ref().child('users').child(widget.username);
    DatabaseReference ref2 =
        FirebaseDatabase.instance.ref().child('users').child(Home.username);

    ref.child('followers').child(Home.username).set(Home.username);
    ref2.child('following').child(widget.username).set(widget.username);

    Fluttertoast.showToast(msg: 'Following ${widget.username}');
    setState(() {
      follow = true;
    });
  }

  void stopfollow() {
    DatabaseReference ref =
        FirebaseDatabase.instance.ref().child('users').child(widget.username);
    DatabaseReference ref2 =
        FirebaseDatabase.instance.ref().child('users').child(Home.username);

    ref.child('followers').update({Home.username: null});
    ref2.child('following').update({widget.username: null});

    Fluttertoast.showToast(msg: 'Unfollowed ${widget.username}');
    setState(() {
      follow = false;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    acc();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(25.0),
            child: SizedBox(
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Stack(
                    children: [
                      Hero(
                        tag: widget.username,
                        child: CircleAvatar(
                          backgroundColor: Colors.pinkAccent,
                          backgroundImage: (profilepic.isEmpty)
                              ? NetworkImage(
                                  'https://i.postimg.cc/NGNJmhnP/undraw-Male-avatar-g98d.png')
                              : NetworkImage(profilepic),
                          radius: 50,
                        ),
                      ),
                      Visibility(
                        visible: widget.username == Home.username,
                        child: Positioned(
                          bottom: 0,
                          right: 0,
                          child: InkWell(
                            onTap: () {
                              showModalBottomSheet(
                                context: context,
                                builder: (context) => EditProfile(),
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(100),
                                  border: Border.all(
                                    color: Colors.black,
                                    width: 2,
                                  )),
                              child: Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Icon(
                                  CupertinoIcons.pencil,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    widget.username,
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 30,
                    ),
                  ),
                  SizedBox(
                    height: 25,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        children: [
                          Text(
                            posts.length.toString(),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                          Text(
                            'Posts',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        ],
                      ),
                      InkWell(
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            builder: (context) => Container(
                              child: ListView.builder(
                                itemCount: followers.length,
                                itemBuilder: (context, index) => Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: Text(
                                    followers[index],
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                        child: Column(
                          children: [
                            Text(
                              followers.length.toString(),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                            Text(
                              'Followers',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          ],
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            builder: (context) => Container(
                              child: ListView.builder(
                                itemCount: following.length,
                                itemBuilder: (context, index) => Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: Text(
                                    following[index],
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                        child: Column(
                          children: [
                            Text(
                              following.length.toString(),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                            Text(
                              'Following',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Visibility(
                      visible: widget.username != Home.username,
                      child: ElevatedButton(
                        onPressed: () {
                          (follow == false) ? startfollow() : stopfollow();
                        },
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(100.0)),
                          padding: const EdgeInsets.all(0.0),
                        ),
                        child: Ink(
                          decoration: (follow == false)
                              ? const BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: <Color>[
                                      Colors.pinkAccent,
                                      Colors.deepPurpleAccent,
                                      Colors.red
                                    ],
                                  ),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(100.0)),
                                )
                              : BoxDecoration(),
                          child: Container(
                            constraints: const BoxConstraints(
                                minWidth: 88.0,
                                minHeight:
                                    36.0), // min sizes for Material buttons
                            alignment: Alignment.center,
                            child: Text(
                              (follow == false) ? 'Follow' : 'Unfollow',
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      )),
                  SizedBox(
                    height: 15,
                  ),
                  Visibility(
                    visible: posts.isEmpty,
                    child: Padding(
                      padding: const EdgeInsets.all(50.0),
                      child: Column(
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
                              CupertinoIcons.nosign,
                              color: Colors.purpleAccent,
                              size: 70,
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Text(
                            "No posts",
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
                            "Your posts show up here. Hit the + button to create new post.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 14,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(25),
                    child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 2,
                        mainAxisSpacing: 2,
                      ),
                      itemCount: posts.length,
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemBuilder: (context, index) => InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              CupertinoPageRoute(
                                builder: (context) =>
                                    Feedzoom(postindex: posts[index]),
                              ));
                        },
                        child: Image.network(postimg[index], fit: BoxFit.cover),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class Feedzoom extends StatelessWidget {
  final postindex;
  const Feedzoom({super.key, required this.postindex});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [Feeditem(value: postindex)],
    ));
  }
}

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  bool v = true;

  File? _image;
  Future _pickImage(ImageSource source) async {
    try {
      final image = await ImagePicker().pickImage(source: source, imageQuality: 50);
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
      body: Center(
        child: Stack(
          children: [
            (_image == null)
                ? CircleAvatar(
                    radius: 100,
                    backgroundImage: AssetImage('assets/defaultpic.png'),
                  )
                : CircleAvatar(
                    radius: 100,
                    backgroundImage: FileImage(_image!),
                  ),
            Positioned(
              top: 0,
              right: 0,
              child: InkWell(
                onTap: () {
                  _pickImage(ImageSource.camera);
                },
                child: CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.pinkAccent,
                  child: Icon(
                    CupertinoIcons.camera,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              child: InkWell(
                onTap: () {
                  _pickImage(ImageSource.gallery);
                },
                child: CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.red,
                  child: Icon(
                    CupertinoIcons.photo,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Visibility(
        visible: v,
        child: FloatingActionButton(
          onPressed: () async {
            if (_image == null) {
              Fluttertoast.showToast(msg: 'Please choose a photo!');
            } else {
              setState(() {
                v = false;
              });
              Fluttertoast.showToast(msg: 'Uploading');
              var imgref = FirebaseStorage.instance
                  .ref()
                  .child('profile')
                  .child(Home.username);
              var url;

              DatabaseReference ref = FirebaseDatabase.instance
                  .ref()
                  .child('users')
                  .child(Home.username);

              try {
                await imgref.putFile(_image!);
                url = await imgref.getDownloadURL();

                ref.child('profile').set(url.toString());

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
