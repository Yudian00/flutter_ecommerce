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
class DiscoutListView extends StatefulWidget {
  User user;
  Function refresh;

  DiscoutListView({
    @required this.user,
    @required this.refresh,
  });

  @override
  _DiscoutListViewState createState() => _DiscoutListViewState();
}

class _DiscoutListViewState extends State<DiscoutListView> {
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
          .where('onDiscount', isEqualTo: true)
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
          if (snapshot.data.docs.length == 0) {
            return Container();
          } else {
            var data = snapshot.data.docs;

            return Entry.opacity(
              duration: Duration(milliseconds: 1500),
              child: ListView(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                children: [
                  Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Row(
                      children: [
                        Container(
                          height: 20,
                          width: 50,
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Text(
                              'SALE',
                              style: GoogleFonts.openSans(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          'Diskon Minggu ini',
                          style: GoogleFonts.openSans(
                            color: Colors.black87,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  CarouselSlider.builder(
                    options: CarouselOptions(
                      height: MediaQuery.of(context).size.height / 1.8,
                      enableInfiniteScroll: false,
                      initialPage: 0,
                      viewportFraction: 0.7,
                      disableCenter: true,
                      scrollPhysics: BouncingScrollPhysics(),
                    ),
                    itemCount: data.length < 5 ? data.length : 5,
                    itemBuilder: (context, itemIndex, index) {
                      DocumentSnapshot docSnapshot = snapshot.data.docs[index];
                      //calculate a new price after discount
                      var discountPrice = int.parse(data[itemIndex]['harga']) *
                          data[itemIndex]['discount_percent'] /
                          100;

                      var newPrice =
                          int.parse(data[itemIndex]['harga']) - discountPrice;
                      return InkWell(
                        onTap: () {
                          navigatetoProductPage(
                            // widget.productID[itemIndex],
                            docSnapshot.id,
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
                                  Positioned(
                                    top: 10,
                                    right: -20,
                                    child: Container(
                                      height:
                                          MediaQuery.of(context).size.height /
                                              12.8,
                                      width:
                                          MediaQuery.of(context).size.height /
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
                                            data[itemIndex]['discount_percent']
                                                .toString(),
                                            style: GoogleFonts.robotoSlab(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 20,
                                                color: Colors.white),
                                          ),
                                          Text(
                                            // '50%',
                                            '%',
                                            style: GoogleFonts.robotoSlab(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 20,
                                                color: Colors.white),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
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
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                            decoration:
                                                TextDecoration.lineThrough,
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
