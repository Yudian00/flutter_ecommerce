import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ecommerce/repositories/DatabaseServices.dart';
import 'package:flutter_ecommerce/ui/pages/admin/kategori/categories_page.dart';
import 'package:flutter_ecommerce/utils/color_codes.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:page_transition/page_transition.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wc_form_validators/wc_form_validators.dart';

class CreateNewProduct extends StatefulWidget {
  @override
  _CreateNewProductState createState() => _CreateNewProductState();
}

class _CreateNewProductState extends State<CreateNewProduct> {
  bool _checked = false;

  static final _formKey = GlobalKey<FormState>();
  String _dropDownValue;

  String photoUrl;
  PickedFile image;
  final _picker = ImagePicker();
  final _storage = FirebaseStorage.instance;

  TextEditingController nameController = TextEditingController();
  TextEditingController hargaController = TextEditingController();
  TextEditingController stokController = TextEditingController();
  TextEditingController deskripsiController = TextEditingController();
  TextEditingController diskonController = TextEditingController();
  TextEditingController diskonPercentController = TextEditingController();

  void initState() {
    super.initState();
    nameController.text = '';
    hargaController.text = '';
    stokController.text = '';
    deskripsiController.text = '';
    diskonController.text = '';
    diskonPercentController.text = '';
  }

  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Tambah Produk Baru',
          style: GoogleFonts.roboto(
            color: Colors.black,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
      ),
      body: NotificationListener<OverscrollIndicatorNotification>(
        // ignore: missing_return
        onNotification: (overscroll) {
          overscroll.disallowGlow();
        },
        child: Form(
          key: _formKey,
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: GestureDetector(
              // onTap: () {
              //   FocusScope.of(context).requestFocus(new FocusNode());
              // },
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('categories')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (snapshot.data.docs.length == 0) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Center(
                          child: Container(
                            height: MediaQuery.of(context).size.height * 0.3,
                            width: MediaQuery.of(context).size.width * 0.5,
                            child: LottieBuilder.asset(
                                'assets/lottieAnimations/empty_illustration_99.json'),
                          ),
                        ),
                        Text(
                          'Kategori Kosong',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          'Sepertinya kamu lupa menambahkan kategori untuk setiap produkmu. Yuk, tambahkan kategori produk sebelum membuat produk baru',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            height: 1.5,
                            color: Colors.black38,
                          ),
                        ),
                        SizedBox(
                          height: 40,
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 50),
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pushReplacement(
                                  context,
                                  PageTransition(
                                      type: PageTransitionType.fade,
                                      child: CategoriesPage()));
                            },
                            style: ElevatedButton.styleFrom(
                              primary: adminMainColor,
                              padding: EdgeInsets.all(15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                            ),
                            child: Center(
                              child: Text(
                                'Tambah Kategori',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  } else {
                    List<String> categoryList = [];

                    for (var i = 0; i < snapshot.data.docs.length; i++) {
                      categoryList.add(snapshot.data.docs[i]['category_name']);
                    }

                    return ListView(
                      children: [
                        photoUrl == null
                            ? GestureDetector(
                                onTap: () => uploadImageFromGallery(context),
                                child: Container(
                                  height:
                                      MediaQuery.of(context).size.height * 0.35,
                                  width: MediaQuery.of(context).size.width,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.image,
                                      ),
                                      SizedBox(
                                        height: 20,
                                      ),
                                      Text(
                                        'Ketuk untuk menambahkan foto produk',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.black54,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : Container(
                                height:
                                    MediaQuery.of(context).size.height * 0.35,
                                width: MediaQuery.of(context).size.width,
                                decoration: BoxDecoration(
                                  color: Colors.grey,
                                  borderRadius: BorderRadius.circular(10),
                                  image: DecorationImage(
                                    image: NetworkImage(
                                      photoUrl,
                                    ),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                        textField('Nama Barang', nameController),
                        textFieldNumber('Harga Barang', hargaController),
                        textFieldNumber('Stok Barang', stokController),
                        dropDownCategory(categoryList),
                        multiLineTextField(
                            'Deskripsi Barang', deskripsiController),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CheckboxListTile(
                              title: Text(
                                'Berlaku Diskon',
                                style: TextStyle(
                                  color: Colors.black54,
                                  fontSize: 13,
                                ),
                              ),
                              contentPadding: EdgeInsets.only(left: 0),
                              controlAffinity: ListTileControlAffinity.leading,
                              activeColor: primaryColor,
                              value: _checked,
                              onChanged: (bool value) {
                                setState(() {
                                  _checked = value;
                                });
                              },
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width * 0.4,
                              child: TextFormField(
                                enabled: _checked,
                                controller: diskonPercentController,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                validator: Validators.compose([
                                  Validators.min(0, 'format tidak sesuai'),
                                  Validators.max(90, 'Maksimal diskon 90%'),
                                ]),
                                decoration: InputDecoration(
                                  hintText: '0 %',
                                  suffixText: '%',
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide(width: 100),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 30,
                            ),
                            ElevatedButton(
                              onPressed: () {
                                submit();
                              },
                              style: ElevatedButton.styleFrom(
                                primary: primaryColor,
                                minimumSize: Size(
                                  MediaQuery.of(context).size.width,
                                  MediaQuery.of(context).size.height * 0.070,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  'Simpan',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        // discountOption(),
                        // submitButton(),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.05,
                        ),
                      ],
                    );
                  }
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget textField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 30,
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: Colors.black54,
          ),
        ),
        SizedBox(
          height: 20,
        ),
        TextFormField(
          controller: nameController,
          validator: Validators.required('Field tidak boleh kosong'),
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        SizedBox(
          height: 20,
        ),
      ],
    );
  }

  Widget textFieldNumber(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 30,
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: Colors.black54,
          ),
        ),
        SizedBox(
          height: 20,
        ),
        TextFormField(
          validator: Validators.compose([
            Validators.required('Field tidak boleh kosong'),
          ]),
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
          ],
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        SizedBox(
          height: 20,
        ),
      ],
    );
  }

  Widget dropDownCategory(List categoryList) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 30,
        ),
        Text(
          'Kategori Produk',
          style: TextStyle(
            fontSize: 13,
            color: Colors.black54,
          ),
        ),
        SizedBox(
          height: 10,
        ),
        Padding(
          padding: EdgeInsets.only(left: 10.0),
          child: DropdownButtonFormField(
            validator: (String value) {
              if (_dropDownValue == null) {
                return 'Pilih Kategori terlebih dahulu';
              } else {
                return null;
              }
            },
            hint: _dropDownValue == null
                ? Text('Pilih Kategori')
                : Text(
                    _dropDownValue,
                    style: TextStyle(color: Colors.blue),
                  ),
            isExpanded: true,
            iconSize: 30.0,
            style: TextStyle(color: Colors.black87),
            items: categoryList.map(
              (val) {
                return DropdownMenuItem<String>(
                  value: val,
                  child: Text(val),
                );
              },
            ).toList(),
            onChanged: (val) {
              setState(() {
                _dropDownValue = val;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget multiLineTextField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 50,
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: Colors.black54,
          ),
        ),
        SizedBox(
          height: 20,
        ),
        TextFormField(
          controller: controller,
          validator: Validators.compose([
            Validators.required('Field tidak boleh kosong'),
          ]),
          keyboardType: TextInputType.multiline,
          maxLines: 5,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        SizedBox(
          height: 20,
        ),
      ],
    );
  }

  Widget discountOption() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CheckboxListTile(
          title: Text(
            'Berlaku Diskon',
            style: TextStyle(
              color: Colors.black54,
              fontSize: 13,
            ),
          ),
          contentPadding: EdgeInsets.only(left: 0),
          controlAffinity: ListTileControlAffinity.leading,
          value: _checked,
          onChanged: (bool value) {
            setState(() {
              _checked = value;
            });
          },
          activeColor: primaryColor,
        ),
        Container(
          width: MediaQuery.of(context).size.width * 0.4,
          child: TextFormField(
            enabled: _checked,
            controller: diskonPercentController,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
            validator: Validators.compose([
              Validators.min(0, 'format tidak sesuai'),
              Validators.max(90, 'Maksimal diskon 90%'),
            ]),
            decoration: InputDecoration(
              hintText: '0 %',
              suffixText: '%',
              border: OutlineInputBorder(
                borderSide: BorderSide(width: 100),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget submitButton() {
    return Column(
      children: [
        SizedBox(
          height: 30,
        ),
        ElevatedButton(
          onPressed: () => submit(),
          style: ElevatedButton.styleFrom(
            primary: adminMainColor,
            minimumSize: Size(
              MediaQuery.of(context).size.width,
              MediaQuery.of(context).size.height * 0.070,
            ),
          ),
          child: Center(
            child: Text(
              'Simpan',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
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
            setState(() {
              photoUrl = photoURL;
            });
            print('photo url : ' + photoUrl);
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

  void submit() {
    if (_formKey.currentState.validate()) {
      if (nameController.text.isNotEmpty) {
        if (_checked) {
          if (int.parse(diskonPercentController.text) < 10 ||
              int.parse(diskonPercentController.text) == null) {
            doWarning();
          } else {
            doSubmit();
          }
        } else {
          doSubmit();
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Nama barang tidak boleh kosong')));
      }
    }
  }

  void doSubmit() {
    final snackBar = SnackBar(
      content: Text('Produk berhasil ditambahkan'),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);

    DatabaseServices.createNewProduct(
      nama: nameController.text,
      deskripsi: deskripsiController.text,
      diskon: _checked,
      harga: hargaController.text,
      kategori: _dropDownValue,
      persenDiskon: int.parse(diskonPercentController.text),
      stokBarang: int.parse(stokController.text),
      url: photoUrl,
    );

    Navigator.pop(context);
  }

  void doWarning() {
    final snackBar = SnackBar(
      content: Text('Minimal Diskon 10%'),
      backgroundColor: Colors.red,
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
