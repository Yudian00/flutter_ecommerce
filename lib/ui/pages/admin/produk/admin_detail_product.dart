import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ecommerce/repositories/DatabaseServices.dart';

import 'package:flutter_ecommerce/ui/pages/admin/produk/admin_edit_product.dart';
import 'package:flutter_ecommerce/ui/pages/admin/produk/admin_full_image.dart';
import 'package:flutter_ecommerce/utils/color_codes.dart';
import 'package:flutter_ecommerce/utils/product_option.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';

class AdminDetailProduct extends StatefulWidget {
  final DocumentSnapshot snapshotData;

  AdminDetailProduct({
    @required this.snapshotData,
  });

  @override
  _AdminDetailProductState createState() => _AdminDetailProductState();
}

class _AdminDetailProductState extends State<AdminDetailProduct> {
  var newPrice;

  void initState() {
    super.initState();
    if (widget.snapshotData['harga'] is String) {
      print('String');
    }
    var discountPrice = int.parse(widget.snapshotData['harga']) *
        widget.snapshotData['discount_percent'] /
        100;

    newPrice = int.parse(widget.snapshotData['harga']) - discountPrice;
    print(newPrice);
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
    return Scaffold(
      body: NotificationListener<OverscrollIndicatorNotification>(
        // ignore: missing_return
        onNotification: (overscroll) {
          overscroll.disallowGlow();
        },
        child: ListView(
          children: [
            Stack(
              children: [
                Container(
                  height: MediaQuery.of(context).size.height * 0.4,
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    image: DecorationImage(
                      image: NetworkImage(widget.snapshotData['url']),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  top: 20,
                  left: 10,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                        color: Colors.white30,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Icon(
                          Icons.arrow_back,
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.all(20.0),
                        child: Text(
                          widget.snapshotData['nama'],
                          style: GoogleFonts.roboto(
                            fontWeight: FontWeight.bold,
                            fontSize: 25,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 20.0),
                        child: widget.snapshotData['onDiscount']
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    NumberFormat.currency(
                                            locale: 'id',
                                            symbol: 'Rp',
                                            decimalDigits: 0)
                                        .format(int.parse(
                                            widget.snapshotData['harga']))
                                        .toString(),
                                    style: TextStyle(
                                      decoration: TextDecoration.lineThrough,
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Text(
                                    NumberFormat.currency(
                                            locale: 'id',
                                            symbol: 'Rp',
                                            decimalDigits: 0)
                                        .format(newPrice)
                                        .toString(),
                                    style: TextStyle(
                                      color: Colors.red,
                                    ),
                                  ),
                                ],
                              )
                            : Text(
                                'harga',
                                style: GoogleFonts.roboto(fontSize: 20),
                              ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(20.0),
                        child: Text(
                          'Kategori : ' + widget.snapshotData['kategori'],
                          style: GoogleFonts.roboto(
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(15.0),
                  child: PopupMenuButton<String>(
                    onSelected: choiceAction,
                    itemBuilder: (context) {
                      return ProductOption.choices.map((String choice) {
                        return PopupMenuItem<String>(
                          value: choice,
                          child: Text(choice),
                        );
                      }).toList();
                    },
                  ),
                )
              ],
            ),
            StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('product')
                  .doc(widget.snapshotData.id)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Container();
                } else {
                  try {
                    if (snapshot.data['fotoProduk'].length == 0) {
                      return Container();
                    } else {
                      return Container(
                        margin: EdgeInsets.fromLTRB(20, 0, 20, 0),
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height * 0.2,
                        child: ListView.builder(
                          itemCount: snapshot.data['fotoProduk'].length,
                          shrinkWrap: true,
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () => Navigator.push(
                                context,
                                PageTransition(
                                  type: PageTransitionType.fade,
                                  child: AdminFullImage(
                                    productName: snapshot.data['nama'],
                                    photoURL: snapshot.data['fotoProduk']
                                        [index],
                                  ),
                                ),
                              ),
                              child: Container(
                                margin: EdgeInsets.fromLTRB(0, 20, 20, 20),
                                height:
                                    MediaQuery.of(context).size.height * 0.2,
                                width: MediaQuery.of(context).size.width * 0.27,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                  image: DecorationImage(
                                    image: NetworkImage(
                                        snapshot.data['fotoProduk'][index]),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    }
                  } catch (e) {
                    return Container();
                  }
                }
              },
            ),
            Container(
              height: MediaQuery.of(context).size.height * 0.15,
              width: MediaQuery.of(context).size.width,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width * 0.3,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.thumb_up_alt_outlined,
                          color: primaryColor,
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        StreamBuilder(
                          stream: FirebaseFirestore.instance
                              .collection('favorite')
                              .where('productId',
                                  isEqualTo: widget.snapshotData.id)
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return Container();
                            } else {
                              return Text(snapshot.data.docs.length.toString());
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: 100,
                    width: MediaQuery.of(context).size.width * 0.3,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          widget.snapshotData['stok barang'].toString(),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text('Stok'),
                      ],
                    ),
                  ),
                  widget.snapshotData['onDiscount']
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.attach_money,
                              color: Colors.black,
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text('Sedang diskon'),
                          ],
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.money_off_csred_outlined,
                              color: Colors.black,
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text('Tidak ada diskon'),
                          ],
                        ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(20.0),
              child: Text(
                widget.snapshotData['deskripsi'],
                style: GoogleFonts.roboto(
                  height: 1.5,
                ),
              ),
            ),
            SizedBox(
              height: 50,
            ),
          ],
        ),
      ),
    );
  }

  void choiceAction(String choice) {
    if (choice == ProductOption.Edit) {
      Navigator.push(
          context,
          PageTransition(
              type: PageTransitionType.rightToLeft,
              child: EditProduct(
                snapshot: widget.snapshotData,
              )));
    } else if (choice == ProductOption.Hapus) {
      confirmDelete(context);
    }
  }

  confirmDelete(BuildContext context) {
    // set up the buttons
    Widget cancelButton = TextButton(
      child: Text(
        "Tidak",
        style: TextStyle(
          color: Colors.black45,
        ),
      ),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    Widget continueButton = TextButton(
      child: Container(
        height: 40,
        width: 100,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: Colors.red,
        ),
        child: Center(
          child: Text(
            "Hapus",
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ),
      ),
      onPressed: () {
        Navigator.pop(context);
        Navigator.pop(context);
        DatabaseServices.deleteProduct(widget.snapshotData.id);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text('Peringatan'),
      content: Text("Hapus produk ini?"),
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
}
