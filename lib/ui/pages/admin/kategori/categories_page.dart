import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ecommerce/repositories/DatabaseServices.dart';
import 'package:flutter_ecommerce/utils/color_codes.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';

class CategoriesPage extends StatefulWidget {
  @override
  _CategoriesPageState createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  TextEditingController _categoryController = TextEditingController();

  void initState() {
    super.initState();
  }

  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          'Kategori Produk',
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
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: primaryColor),
            onPressed: () {
              showAlertDialog(context);
            },
          )
        ],
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('categories')
            .orderBy('category_name')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else {
            if (snapshot.data.docs.length == 0) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    height: MediaQuery.of(context).size.height * 0.3,
                    width: MediaQuery.of(context).size.width * 0.5,
                    child: LottieBuilder.asset(
                        'assets/lottieAnimations/square.json'),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Center(
                    child: Text(
                      'Kategori Kosong',
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Center(
                    child: Text(
                      'Klik "+" untuk menambahkan kategori produk',
                      style: TextStyle(
                        color: Colors.black45,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              );
            } else {
              var data = snapshot.data.docs;

              return ListView.builder(
                itemCount: data.length,
                itemBuilder: (context, index) {
                  DocumentSnapshot documentSnapshot = data[index];
                  return Container(
                    margin: EdgeInsets.all(10),
                    height: MediaQuery.of(context).size.height * 0.07,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            data[index]['category_name'],
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            highlightColor: Colors.transparent,
                            icon: Icon(
                              Icons.close,
                              color: Colors.black38,
                              size: 15,
                            ),
                            onPressed: () {
                              showDeleteDialog(
                                  context, documentSnapshot.id.toString());
                            },
                          )
                        ],
                      ),
                    ),
                  );
                },
              );
            }
          }
        },
      ),
    );
  }

  showAlertDialog(BuildContext context) {
    // set up the buttons
    Widget cancelButton = TextButton(
      child: Text(
        "Batalkan",
        style: TextStyle(
          color: Colors.black38,
        ),
      ),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    Widget continueButton = TextButton(
      child: Text("Tambahkan"),
      onPressed: () {
        String sentece = toBeginningOfSentenceCase(_categoryController.text);

        Navigator.pop(context);
        DatabaseServices.addCategory(
            sentece, showSnackbar, duplicateSnackbar, resetController);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(
        "Tambah kategori baru",
        style: TextStyle(
          fontSize: 18,
        ),
      ),
      content: TextField(
        controller: _categoryController,
        decoration: InputDecoration(
          hintText: 'contoh : Jilbab, Gamis, dll',
          hintStyle: TextStyle(
            color: Colors.black38,
            fontSize: 12,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          contentPadding: EdgeInsets.all(10),
        ),
      ),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  showDeleteDialog(BuildContext context, String categoryId) {
    // set up the buttons
    Widget cancelButton = TextButton(
      child: Text(
        "Batalkan",
        style: TextStyle(
          color: Colors.black38,
        ),
      ),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    Widget continueButton = TextButton(
      child: Text(
        "Hapus",
        style: TextStyle(color: Colors.red[500]),
      ),
      onPressed: () {
        DatabaseServices.deleteCategory(categoryId, deleteSuccess);
        Navigator.pop(context);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Hapus"),
      content: Text("Kamu yakin ingin menghapus kategori ini?"),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  void showSnackbar() {
    final snackBar = SnackBar(
      content: Text(
        'Kategori berhasil ditambahkan',
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void duplicateSnackbar() {
    final snackBar = SnackBar(
      content: Text(
        'Kategori sudah tersedia. Coba yang lain',
      ),
      backgroundColor: Colors.red[300],
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void deleteSuccess() {
    final snackBar = SnackBar(
      content: Text(
        'Kategori berhasil dihapus',
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void resetController() {
    _categoryController.clear();
  }
}
