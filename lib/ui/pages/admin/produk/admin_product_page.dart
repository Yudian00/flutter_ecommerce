import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ecommerce/ui/pages/admin/produk/admin_detail_product.dart';
import 'package:flutter_ecommerce/ui/pages/admin/produk/create_product.dart';
import 'package:flutter_ecommerce/utils/color_codes.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';

class AdminProductPage extends StatefulWidget {
  @override
  _AdminProductPageState createState() => _AdminProductPageState();
}

class _AdminProductPageState extends State<AdminProductPage> {
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
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          'Daftar Produk',
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
      ),
      body: Padding(
        padding: EdgeInsets.all(10.0),
        child: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('product')
              .orderBy('timestamp', descending: true)
              .where('status', isEqualTo: 'tersedia')
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else {
              if (snapshot.data.docs.length == 0) {
                return Center(
                  child: Text('Tidak ada produk yang tersedia'),
                );
              } else {
                return NotificationListener<OverscrollIndicatorNotification>(
                  // ignore: missing_return
                  onNotification: (overscroll) {
                    overscroll.disallowGlow();
                  },
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: snapshot.data.docs.length,
                    itemBuilder: (context, index) {
                      DocumentSnapshot snapshotData = snapshot.data.docs[index];
                      var discountPrice = int.parse(snapshotData['harga']) *
                          snapshotData['discount_percent'] /
                          100;

                      var newPrice =
                          int.parse(snapshotData['harga']) - discountPrice;
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            PageTransition(
                              type: PageTransitionType.rightToLeft,
                              child: AdminDetailProduct(
                                snapshotData: snapshotData,
                              ),
                            ),
                          );
                        },
                        child: Container(
                          margin: EdgeInsets.all(10),
                          height: MediaQuery.of(context).size.height * 0.2,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 1,
                                blurRadius: 1,
                                offset:
                                    Offset(1, 1), // changes position of shadow
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                height: MediaQuery.of(context).size.height,
                                width: 100,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(10),
                                    bottomLeft: Radius.circular(10),
                                  ),
                                  image: DecorationImage(
                                    image: NetworkImage(
                                      snapshotData['url'],
                                    ),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 30,
                              ),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding: EdgeInsets.all(5.0),
                                        child: Text(
                                          snapshotData['nama'],
                                          style: GoogleFonts.roboto(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                            height: 1.5,
                                          ),
                                        ),
                                      ),
                                    ),
                                    snapshotData['onDiscount']
                                        ? Expanded(
                                            child: Column(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    NumberFormat.currency(
                                                            locale: 'id',
                                                            symbol: 'Rp',
                                                            decimalDigits: 0)
                                                        .format(int.parse(
                                                            snapshotData[
                                                                'harga']))
                                                        .toString(),
                                                    style: TextStyle(
                                                      decoration: TextDecoration
                                                          .lineThrough,
                                                      fontSize: 11,
                                                    ),
                                                  ),
                                                ),
                                                Expanded(
                                                  child: Padding(
                                                    padding:
                                                        EdgeInsets.all(5.0),
                                                    child: Text(
                                                      NumberFormat.currency(
                                                              locale: 'id',
                                                              symbol: 'Rp',
                                                              decimalDigits: 0)
                                                          .format(newPrice)
                                                          .toString(),
                                                      style: TextStyle(
                                                        color: Colors.red,
                                                        fontSize: 11,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )
                                        : Expanded(
                                            child: Padding(
                                              padding: EdgeInsets.all(5),
                                              child: Text(
                                                NumberFormat.currency(
                                                        locale: 'id',
                                                        symbol: 'Rp',
                                                        decimalDigits: 0)
                                                    .format(int.parse(
                                                        snapshotData['harga']))
                                                    .toString(),
                                                style: TextStyle(
                                                  fontSize: 11,
                                                ),
                                              ),
                                            ),
                                          ),
                                    Expanded(
                                      child: Padding(
                                        padding: EdgeInsets.all(5.0),
                                        child: Text(
                                          'Tersedia : ' +
                                              snapshotData['stok barang']
                                                  .toString(),
                                          style: GoogleFonts.roboto(
                                            fontSize: 11,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                width: 60,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              }
            }
          },
        ),
      ),
      floatingActionButton: GestureDetector(
        onTap: () {
          Navigator.push(
              context,
              PageTransition(
                  type: PageTransitionType.rightToLeft,
                  child: CreateNewProduct()));
        },
        child: Container(
          height: 50,
          width: 50,
          decoration: BoxDecoration(
            color: primaryColor,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Icon(
              Icons.add,
              color: Colors.white,
              size: 30,
            ),
          ),
        ),
      ),
    );
  }
}
