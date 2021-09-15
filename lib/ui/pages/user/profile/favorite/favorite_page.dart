import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ecommerce/ui/pages/user/product/product_detail.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';

class FavoritePage extends StatefulWidget {
  final User user;

  FavoritePage({
    @required this.user,
  });

  @override
  _FavoritePageState createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  void initState() {
    super.initState();
    // getFavoriteProduct();
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
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          'Favorite',
          style: GoogleFonts.roboto(
            color: Colors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: FutureBuilder(
          future: getFavoriteProductId(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(
                child: CircularProgressIndicator(),
              );
            } else {
              var productIdSnapshot = snapshot.data;
              return GridView.builder(
                itemCount: productIdSnapshot.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 9 / 17,
                ),
                itemBuilder: (context, index) => StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('product')
                      .doc(productIdSnapshot[index])
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      var data = snapshot.data;
                      var discountPrice = int.parse(data['harga']) *
                          data['discount_percent'] /
                          100;

                      var newPrice = int.parse(data['harga']) - discountPrice;
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            PageTransition(
                              type: PageTransitionType.rightToLeft,
                              child: ProductDetailParent(
                                  productID: productIdSnapshot[index],
                                  user: widget.user),
                            ),
                          ).then((value) => setState(() {}));
                        },
                        child: Container(
                          margin: EdgeInsets.symmetric(
                              horizontal: 10, vertical: 10),
                          child: Column(
                            children: [
                              Container(
                                width: 180,
                                height: 200,
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
                                    // productURL[index],
                                    data['url'],
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Container(
                                width: 180,
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
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10.0,
                                  ),
                                  child: data['onDiscount'] == true
                                      ? Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      10, 10, 0, 10),
                                              child: Text(
                                                data['nama'],
                                                style: GoogleFonts.openSans(
                                                    fontSize: 13,
                                                    fontWeight:
                                                        FontWeight.bold),
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
                                                        data['harga']))
                                                    .toString(),
                                                style: GoogleFonts.openSans(
                                                    decoration: TextDecoration
                                                        .lineThrough,
                                                    fontSize: 13,
                                                    fontWeight:
                                                        FontWeight.bold),
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
                                                    fontSize: 13,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                          ],
                                        )
                                      : Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      10, 10, 0, 10),
                                              child: Text(
                                                data['nama'],
                                                style: GoogleFonts.openSans(
                                                    fontSize: 13,
                                                    fontWeight:
                                                        FontWeight.bold),
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
                                                    color: Colors.black,
                                                    fontSize: 13,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                          ],
                                        ),
                                ),
                              )
                            ],
                          ),
                        ),
                      );
                      // return Text(data['nama'].toString());
                    } else {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                  },
                ),
              );
            }
          },
        ),
      ),
    );
  }

  Future getFavoriteProductId() async {
    List productId = [];

    final FirebaseAuth _auth = FirebaseAuth.instance;
    final User user = _auth.currentUser;
    final uid = user.uid;
    // Similarly we can get email as well
    //final uemail = user.email;

    QuerySnapshot docRef = await FirebaseFirestore.instance
        .collection('favorite')
        .where('userId', isEqualTo: uid)
        .get();

    for (var i = 0; i < docRef.docs.length; i++) {
      if (!productId.contains(docRef.docs[i]['productId'])) {
        productId.add(docRef.docs[i]['productId']);
      }
    }

    return productId;
  }
}
