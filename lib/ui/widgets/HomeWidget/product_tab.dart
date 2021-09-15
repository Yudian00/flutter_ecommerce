import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:entry/entry.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ecommerce/ui/pages/user/product/product_detail.dart';
import 'package:flutter_ecommerce/utils/color_codes.dart';
import 'package:flutter_ecommerce/utils/widget_utils.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

// ignore: must_be_immutable
class ProductTab extends StatefulWidget {
  User user;
  Function refresh;
  String category;

  ProductTab({
    @required this.user,
    @required this.refresh,
    @required this.category,
  });

  @override
  _ProductTabState createState() => _ProductTabState();
}

class _ProductTabState extends State<ProductTab> {
  navigatetoProductPage(String productID, User user) {
    Navigator.of(context)
        .push(
      MaterialPageRoute(
        builder: (context) => ProductDetailParent(
          productID: productID,
          user: user,
        ),
      ),
    )
        .then((value) {
      widget.refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('product')
          .where('kategori', isEqualTo: widget.category)
          .where('status', isEqualTo: 'tersedia')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting)
          return Center(
              child: Column(
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.3,
              ),
              loadingAnimation(),
            ],
          ));
        else {
          if (!snapshot.hasData) {
            return Container();
          } else {
            var data = snapshot.data.docs;

            return Entry.opacity(
              duration: Duration(milliseconds: 1500),
              child: ListView(
                physics: NeverScrollableScrollPhysics(),
                children: [
                  CarouselSlider.builder(
                    options: CarouselOptions(
                      height: MediaQuery.of(context).size.height / 1.8,
                      enableInfiniteScroll: false,
                      initialPage: 0,
                      viewportFraction: 0.7,
                      disableCenter: true,
                      scrollPhysics: BouncingScrollPhysics(),
                    ),
                    itemCount: data.length > 5 ? 6 : data.length,
                    itemBuilder:
                        (BuildContext context, int itemIndex, int index) {
                      //calculate a new price after discount
                      var discountPrice = int.parse(data[itemIndex]['harga']) *
                          data[itemIndex]['discount_percent'] /
                          100;

                      var newPrice =
                          int.parse(data[itemIndex]['harga']) - discountPrice;

                      return InkWell(
                        onTap: () {
                          navigatetoProductPage(
                            snapshot.data.docs[index].id,
                            widget.user,
                          );
                        },
                        child: Container(
                          child: Column(
                            children: [
                              Stack(
                                children: [
                                  Container(
                                    width: MediaQuery.of(context).size.width /
                                        1.06,
                                    height: MediaQuery.of(context).size.height /
                                        3.2,
                                    margin: EdgeInsets.only(
                                      left: 10.0,
                                      right: 10.0,
                                      top: 20,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[100],
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(20),
                                        topRight: Radius.circular(20),
                                      ),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(20),
                                        topRight: Radius.circular(20),
                                      ),
                                      child: Image.network(
                                        // productURL[itemIndex],
                                        data[itemIndex]['url'],
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  data[itemIndex]['onDiscount'] == true
                                      ? Positioned(
                                          top: 30,
                                          right: -20,
                                          child: Container(
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height /
                                                12.8,
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .height /
                                                4.6,
                                            decoration: BoxDecoration(
                                              color: secondaryColor,
                                              shape: BoxShape.circle,
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  data[itemIndex]
                                                          ['discount_percent']
                                                      .toString(),
                                                  style: GoogleFonts.robotoSlab(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 20,
                                                      color: Colors.white),
                                                ),
                                                Text(
                                                  // '50%',
                                                  '%',
                                                  style: GoogleFonts.robotoSlab(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 20,
                                                      color: Colors.white),
                                                ),
                                              ],
                                            ),
                                          ),
                                        )
                                      : Container(),
                                ],
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width / 1.55,
                                height:
                                    MediaQuery.of(context).size.height / 6.4,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(20),
                                    bottomRight: Radius.circular(20),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey[200],
                                      blurRadius: 10.0, // soften the shadow
                                      spreadRadius: 1.0, //extend the shadow
                                      offset: Offset(
                                        5.0, // Move to right 10  horizontally
                                        5.0, // Move to bottom 10 Vertically
                                      ),
                                    )
                                  ],
                                ),
                                child: data[itemIndex]['onDiscount'] == true
                                    ? Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                                10, 10, 0, 10),
                                            child: Text(
                                              data[itemIndex]['nama'],
                                              style: GoogleFonts.openSans(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 10.0, bottom: 5.0),
                                            child: Text(
                                              NumberFormat.currency(
                                                      locale: 'id',
                                                      symbol: 'Rp',
                                                      decimalDigits: 0)
                                                  .format(int.parse(
                                                      data[itemIndex]['harga']))
                                                  .toString(),
                                              style: GoogleFonts.openSans(
                                                  decoration: TextDecoration
                                                      .lineThrough,
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 10.0, bottom: 5.0),
                                            child: Text(
                                              NumberFormat.currency(
                                                      locale: 'id',
                                                      symbol: 'Rp',
                                                      decimalDigits: 0)
                                                  .format(newPrice)
                                                  .toString(),
                                              style: GoogleFonts.openSans(
                                                  color: Colors.red,
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ],
                                      )
                                    : Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                                10, 10, 0, 10),
                                            child: Text(
                                              data[itemIndex]['nama'],
                                              style: GoogleFonts.openSans(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 10.0, bottom: 5.0),
                                            child: Text(
                                              NumberFormat.currency(
                                                      locale: 'id',
                                                      symbol: 'Rp',
                                                      decimalDigits: 0)
                                                  .format(int.parse(
                                                      data[itemIndex]['harga']))
                                                  .toString(),
                                              style: GoogleFonts.openSans(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          }
        }
      },
    );
  }
}
