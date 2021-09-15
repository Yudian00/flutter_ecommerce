import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ecommerce/repositories/DatabaseServices.dart';
import 'package:flutter_ecommerce/ui/pages/admin/produk/admin_full_image.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:page_transition/page_transition.dart';
import 'package:permission_handler/permission_handler.dart';

class AddMorePhotos extends StatefulWidget {
  final DocumentSnapshot snapshot;
  final Function changeSelected;
  final bool currentState;
  final List selectedPhoto;

  AddMorePhotos({
    @required this.snapshot,
    @required this.selectedPhoto,
    @required this.currentState,
    @required this.changeSelected,
  });

  @override
  _AddMorePhotosState createState() => _AddMorePhotosState();
}

class _AddMorePhotosState extends State<AddMorePhotos> {
  final _storage = FirebaseStorage.instance;

  final _picker = ImagePicker();

  PickedFile image;

  String imageUrl;

  List _listphoto = [];

  void initState() {
    super.initState();
  }

  void dispose() {
    super.dispose();
  }

  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('product')
          .doc(widget.snapshot.id)
          .snapshots(),
      builder: (context, filesnapshot) {
        if (!filesnapshot.hasData) {
          return Container();
        } else {
          DocumentSnapshot fileSnapshot = filesnapshot.data;

          try {
            for (var i = 0; i < filesnapshot.data['fotoProduk'].length; i++) {
              _listphoto.add(filesnapshot.data['fotoProduk'][i]);
            }

            // _listphoto.add(filesnapshot.data['fotoProduk']);
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height * 0.2,
                  child: ListView.builder(
                    itemCount: fileSnapshot['fotoProduk'].length + 1,
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      if (index == 3) {
                        return Container();
                      } else if (index == fileSnapshot['fotoProduk'].length) {
                        return GestureDetector(
                          onTap: () => uploadImageFromGallery(context),
                          child: Container(
                            margin: EdgeInsets.fromLTRB(0, 20, 20, 20),
                            height: MediaQuery.of(context).size.height * 0.2,
                            width: MediaQuery.of(context).size.width * 0.27,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                            ),
                            child: Icon(
                              Icons.add_circle,
                              color: Colors.grey,
                            ),
                          ),
                        );
                      } else {
                        return GestureDetector(
                          onLongPress: () {
                            if (widget.currentState) {
                            } else {
                              widget.changeSelected();
                              widget.selectedPhoto
                                  .add(fileSnapshot['fotoProduk'][index]);
                            }
                          },
                          onTap: () {
                            if (widget.currentState) {
                              selectPhotos(fileSnapshot, index);
                            } else {
                              Navigator.push(
                                context,
                                PageTransition(
                                  type: PageTransitionType.fade,
                                  child: AdminFullImage(
                                    productName: fileSnapshot['nama'],
                                    photoURL: fileSnapshot['fotoProduk'][index],
                                  ),
                                ),
                              );
                            }
                          },
                          child: Container(
                            margin: EdgeInsets.fromLTRB(0, 20, 20, 20),
                            height: MediaQuery.of(context).size.height * 0.2,
                            width: MediaQuery.of(context).size.width * 0.27,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              image: DecorationImage(
                                image: NetworkImage(
                                    fileSnapshot['fotoProduk'][index]),
                                fit: BoxFit.cover,
                              ),
                            ),
                            child: Container(
                                alignment: Alignment.bottomLeft,
                                height:
                                    MediaQuery.of(context).size.height * 0.2,
                                width: MediaQuery.of(context).size.width * 0.27,
                                child: widget.selectedPhoto.contains(
                                        fileSnapshot['fotoProduk'][index])
                                    ? Checkbox(
                                        value: true,
                                        activeColor: Colors.blue,
                                        onChanged: (value) {},
                                      )
                                    : Container()),
                          ),
                        );
                      }
                    },
                  ),
                ),
                Text(
                  'Kamu bisa menambahkan foto produk sebanyak 3 foto',
                  style: GoogleFonts.roboto(fontSize: 13, color: Colors.grey),
                ),
              ],
            );
          } catch (e) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () => uploadImageFromGallery(context),
                  child: Container(
                    height: 150,
                    width: MediaQuery.of(context).size.width,
                    child: ListView(
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      children: [
                        Container(
                          margin: EdgeInsets.fromLTRB(0, 20, 20, 20),
                          height: 150,
                          width: 100,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                          ),
                          child: Icon(
                            Icons.add_circle,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Text(
                  'Kamu bisa menambahkan foto produk sebanyak 3 foto',
                  style: GoogleFonts.roboto(fontSize: 13, color: Colors.grey),
                ),
              ],
            );
          }
        }
      },
    );
  }

  void selectPhotos(DocumentSnapshot fileSnapshot, int index) {
    if (widget.selectedPhoto.contains(fileSnapshot['fotoProduk'][index])) {
      widget.selectedPhoto.remove(fileSnapshot['fotoProduk'][index]);
      setState(() {});
    } else {
      widget.selectedPhoto.add(fileSnapshot['fotoProduk'][index]);
      setState(() {});
    }
  }

  Future<void> uploadImageFromGallery(BuildContext context) async {
    //Check Permissions
    var status = await Permission.photos.status;

    try {
      if (status.isGranted) {
        // select image
        image = await _picker.getImage(
          source: ImageSource.gallery,
          imageQuality: 20,
        );
        var file = File(image.path);

        String fileName = file.path.split('/').last;
        print('filename : ' + fileName);

        if (image != null) {
          showDialog(
            barrierDismissible: false,
            context: context,
            builder: (_) => AlertDialog(
              contentPadding: EdgeInsets.symmetric(
                horizontal: 50,
              ),
              content: Container(
                width: double.infinity,
                height: 100,
                child: LottieBuilder.asset(
                  'assets/lottieAnimations/loading.json',
                ),
              ),
            ),
          );

          Reference reference = _storage.ref().child(fileName);
          TaskSnapshot storageTaskSnapshot = await reference.putFile(file);

          storageTaskSnapshot.ref.getDownloadURL().then((photoURL) {
            _listphoto.add(photoURL);

            DatabaseServices.addProductPhoto(widget.snapshot.id, _listphoto);
          });

          Navigator.pop(context);
        }
      } else {
        // if grant denied
        print('Grant permission denied and try again');
      }
    } catch (e) {
      print(e);
    }
  }
}
