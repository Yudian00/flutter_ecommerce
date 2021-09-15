import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ecommerce/models/product_model.dart';
import 'package:flutter_ecommerce/ui/pages/user/product/product_detail.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';

class SearchResultPage extends StatefulWidget {
  final String searchItem;
  final List itemList;
  final User user;
  final List productID;
  final Map productData;

  SearchResultPage({
    @required this.searchItem,
    @required this.itemList,
    @required this.user,
    @required this.productID,
    @required this.productData,
  });

  @override
  _SearchResultPageState createState() => _SearchResultPageState();
}

class _SearchResultPageState extends State<SearchResultPage> {
  void initState() {
    super.initState();
    print('Pencarian : ' + widget.searchItem);
    print(widget.productData);
    getSearchedProduct();
  }

  void dispose() {
    super.dispose();
  }

  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  List resultList = [];
  List resultIdList = [];

  Product product;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Pencarian',
          style: GoogleFonts.roboto(
            color: Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.black87,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: resultList.isNotEmpty
          ? ListView(
              children: [
                Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(10, 20, 0, 20),
                      child: Text(
                        'Hasil Pencarian : ',
                        style:
                            GoogleFonts.roboto(fontWeight: FontWeight.normal),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(10, 20, 20, 20),
                      child: Text(
                        resultList.length.toString() + ' Barang ditemukan',
                        style: GoogleFonts.roboto(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                gridViewProduct(resultList),
              ],
            )
          : noResult(),
    );
  }

  //WIDGET
  Widget gridViewProduct(data) {
    print(data);
    print(resultIdList);
    return GridView.builder(
      shrinkWrap: true,
      physics: ScrollPhysics(),
      scrollDirection: Axis.vertical,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 9 / 17,
      ),
      itemCount: data.length,
      itemBuilder: (context, index) {
        //calculate a new price after discount
        var discountPrice = int.parse(data[index]['harga']) *
            data[index]['discount_percent'] /
            100;

        var newPrice = int.parse(data[index]['harga']) - discountPrice;

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProductDetailParent(
                    productID: resultIdList[index], user: widget.user),
              ),
            ).then((value) => setState(() {}));
          },
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
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
                      data[index]['url'],
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Container(
                  width: 180,
                  height: MediaQuery.of(context).size.height / 6.4,
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
                    child: data[index]['onDiscount'] == true
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(10, 10, 0, 10),
                                child: Text(
                                  data[index]['nama'],
                                  style: GoogleFonts.openSans(
                                      fontSize: 13,
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
                                      .format(int.parse(data[index]['harga']))
                                      .toString(),
                                  style: GoogleFonts.openSans(
                                      decoration: TextDecoration.lineThrough,
                                      fontSize: 13,
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
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(10, 10, 0, 10),
                                child: Text(
                                  data[index]['nama'],
                                  style: GoogleFonts.openSans(
                                      fontSize: 13,
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
                                      color: Colors.black,
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold),
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
      },
    );
  }

  Widget noResult() {
    return Container(
      child: Column(
        children: [
          LottieBuilder.asset('assets/lottieAnimations/lostWhale.json'),
          Text(
            'Tidak ada hasil',
            style:
                GoogleFonts.roboto(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: 10,
          ),
          Text(
            'Barang yang kamu cari tidak ada',
            style: GoogleFonts.roboto(fontSize: 15),
          ),
        ],
      ),
    );
  }

  //FUNCTION
  void getSearchedProduct() {
    String searchItem = widget.searchItem.toLowerCase();
    List itemList = widget.itemList;
    Map productData = widget.productData;

    //add result data
    for (var map in itemList) {
      if (map.containsKey('nama')) {
        if (map['nama'].toString().toLowerCase().contains(searchItem)) {
          resultList.add(map);
        }
      }
    }

    //add result id
    for (var i = 0; i < resultList.length; i++) {
      if (productData.containsValue(resultList[i])) {
        print('true');

        var productKey = productData.keys.firstWhere(
            (k) => productData[k] == resultList[i],
            orElse: () => null);

        resultIdList.add(productKey);
      } else {
        print('false');
      }
    }
  }
}
