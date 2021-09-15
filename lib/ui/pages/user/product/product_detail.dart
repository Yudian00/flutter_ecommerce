import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:favorite_button/favorite_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_ecommerce/blocs/productBloc/productdetail_bloc.dart';
import 'package:flutter_ecommerce/models/product_model.dart';
import 'package:flutter_ecommerce/repositories/DatabaseServices.dart';
import 'package:flutter_ecommerce/repositories/cart_list.dart' as cart;
import 'package:flutter_ecommerce/ui/pages/user/home/home_page.dart';
import 'package:flutter_ecommerce/utils/color_codes.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class ProductDetailParent extends StatelessWidget {
  final User user;
  final String productID;

  ProductDetailParent({
    @required this.productID,
    @required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProductdetailBloc(productID: productID),
      child: ProductDetail(
        productID: productID,
        user: user,
      ),
    );
  }
}

// ignore: must_be_immutable
class ProductDetail extends StatefulWidget {
  User user;
  String productID;

  ProductDetail({@required this.productID, @required this.user});

  @override
  _ProductDetailState createState() => _ProductDetailState();
}

class _ProductDetailState extends State<ProductDetail> {
  Product product;
  bool _isLoading = false;
  bool isFavorite = false;
  bool isInCart = false;
  ProductdetailBloc productdetailBloc;
  List<Product> cartProduct;

  List favList = [];
  HomePageParent homePageParent;
  String currentUserId;

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  void initState() {
    super.initState();
    getCurrentUser();

    // getProductData();
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
    productdetailBloc = BlocProvider.of<ProductdetailBloc>(context);

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        toolbarHeight: 0.0,
        backgroundColor: Colors.white,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _buildBody(),
    );
  }

  Widget _buildBody() {
    return Container(
      child: BlocBuilder<ProductdetailBloc, ProductdetailState>(
        // ignore: missing_return
        builder: (context, state) {
          if (state is ProductdetailInitial) {
            return _buildColumn(false);
          } else if (state is AddProductToCart) {
            return _buildColumn(true);
          } else if (state is RemoveProductFromCart) {
            return _buildColumn(false);
          }
        },
      ),
    );
  }

  Widget _buildColumn(bool isInCart) {
    return Container(
      color: Colors.white,
      child: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('product')
            .doc(widget.productID)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.data == null)
            return Center(child: CircularProgressIndicator());
          else {
            var data = snapshot.data;
            //Calculate product if there is a discount
            var discountPrice =
                int.parse(data['harga']) * data['discount_percent'] / 100;
            var newPrice = int.parse(data['harga']) - discountPrice;

            return Stack(
              children: [
                Container(
                  color: Colors.white,
                  child: ListView(
                    physics: ClampingScrollPhysics(),
                    children: [
                      Stack(
                        children: <Widget>[
                          Container(
                            height: 350,
                            width: MediaQuery.of(context).size.width,
                            child: GridTile(
                              child: Container(
                                color: Colors.white,
                                child: data['url'] == null
                                    ? Container()
                                    : Image.network(
                                        data['url'],
                                        fit: BoxFit.cover,
                                      ),
                              ),
                            ),
                          ),
                          data['onDiscount'] == true
                              ? Container(
                                  height: 60,
                                  width: 60,
                                  margin: EdgeInsets.only(left: 270, top: 20),
                                  decoration: BoxDecoration(
                                    color: secondaryColor,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        data['discount_percent'].toString(),
                                        style: GoogleFonts.robotoSlab(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 30,
                                            color: Colors.white),
                                      ),
                                      Text(
                                        '%',
                                        style: GoogleFonts.robotoSlab(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20,
                                            color: Colors.white),
                                      ),
                                    ],
                                  ),
                                )
                              : Container(),
                          Padding(
                            padding: EdgeInsets.only(top: 25, left: 10),
                            child: Container(
                              height: 40,
                              width: 40,
                              decoration: BoxDecoration(
                                color: Colors.white54,
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                icon: Padding(
                                  padding: EdgeInsets.only(left: 3.0),
                                  child: Icon(
                                    Icons.arrow_back_ios,
                                    color: Colors.black45,
                                  ),
                                ),
                                onPressed: () => Navigator.of(context).pop(),
                              ),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(top: 300),
                            width: MediaQuery.of(context).size.width,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(40),
                                topRight: Radius.circular(40),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.fromLTRB(
                                          30, 20, 10, 5),
                                      width: 270,
                                      child: Text(data['nama'],
                                          style: GoogleFonts.openSans(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold)),
                                    ),
                                    data['onDiscount'] == true
                                        ? Column(
                                            children: [
                                              Container(
                                                padding:
                                                    const EdgeInsets.fromLTRB(
                                                        30, 5, 10, 10),
                                                child: Text(
                                                    NumberFormat.currency(
                                                            locale: 'id',
                                                            symbol: 'Rp',
                                                            decimalDigits: 0)
                                                        .format(int.parse(
                                                            data['harga'])),
                                                    style: TextStyle(
                                                        color: Colors.grey[500],
                                                        decoration:
                                                            TextDecoration
                                                                .lineThrough,
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.bold)),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 30.0),
                                                child: Text(
                                                  NumberFormat.currency(
                                                          locale: 'id',
                                                          symbol: 'Rp',
                                                          decimalDigits: 0)
                                                      .format(newPrice)
                                                      .toString(),
                                                  style: GoogleFonts.openSans(
                                                      color: thirdColor,
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ),
                                            ],
                                          )
                                        : Container(
                                            padding: const EdgeInsets.fromLTRB(
                                                30, 5, 10, 10),
                                            child: Text(
                                              NumberFormat.currency(
                                                      locale: 'id',
                                                      symbol: 'Rp',
                                                      decimalDigits: 0)
                                                  .format(
                                                      int.parse(data['harga'])),
                                              style: TextStyle(
                                                  color: Colors.grey[500],
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                  ],
                                ),
                                FutureBuilder(
                                  future: isFavoriteItem(),
                                  builder: (context, snapshot) {
                                    if (snapshot.hasData) {
                                      if (isFavorite == true) {
                                        return Expanded(
                                          child: FavoriteButton(
                                            isFavorite: isFavorite,
                                            valueChanged: (isFavorite) {
                                              deleteFromFavorite(favList[0]);
                                              setState(() {
                                                isFavorite = !isFavorite;
                                              });
                                            },
                                          ),
                                        );
                                      } else {
                                        return Expanded(
                                          child: FavoriteButton(
                                            isFavorite: isFavorite,
                                            valueChanged: (isFavorite) {
                                              addToFavorite();
                                              setState(() {
                                                isFavorite = !isFavorite;
                                              });
                                            },
                                          ),
                                        );
                                      }
                                    } else {
                                      return Container(
                                        height: 30,
                                        width: 30,
                                        margin:
                                            const EdgeInsets.only(right: 20.0),
                                        child: CircularProgressIndicator(
                                          valueColor:
                                              new AlwaysStoppedAnimation<Color>(
                                                  Colors.grey),
                                        ),
                                      );
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.fromLTRB(30, 0, 30, 0),
                        color: Colors.white,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  margin: EdgeInsets.only(right: 20),
                                  height: 50,
                                  child: Icon(
                                    Icons.card_travel,
                                    color: Colors.black,
                                  ),
                                ),
                                Text(
                                  'Tersedia : ',
                                  style: GoogleFonts.robotoSlab(
                                    fontSize: 15,
                                  ),
                                ),
                                Text(
                                  data['stok barang'].toString(),
                                  textAlign: TextAlign.left,
                                  style: GoogleFonts.openSans(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.fromLTRB(30, 0, 30, 20),
                        color: Colors.white,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(0, 8, 8, 8),
                              child: Text(
                                'Deskripsi',
                                style: GoogleFonts.openSans(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ),
                            Text(
                              'Lorem ipsum dolor sit amet, consectetur sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
                              textAlign: TextAlign.left,
                              style: GoogleFonts.openSans(
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 200,
                      ),
                    ],
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: data['stok barang'] == 0
                      ? AnimatedContainer(
                          duration: Duration(milliseconds: 500),
                          margin: EdgeInsets.all(20),
                          height: 50,
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.grey[700],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: Icon(
                                  Icons.remove_shopping_cart,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                'BARANG HABIS',
                                style: GoogleFonts.robotoSlab(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        )
                      : !cart.cartProduct.contains(widget.productID)
                          ? InkWell(
                              onTap: () {
                                productdetailBloc.add(CartButtonPressed());
                              },
                              child: AnimatedContainer(
                                duration: Duration(milliseconds: 500),
                                margin: EdgeInsets.all(20),
                                height: 50,
                                width: MediaQuery.of(context).size.width,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: primaryColor,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Icon(
                                      Icons.shopping_cart,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                    Text(
                                      'TAMBAHKAN KE KERANGJANG',
                                      style: GoogleFonts.robotoSlab(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : InkWell(
                              onTap: () {
                                productdetailBloc
                                    .add(RemoveCartButtonPressed());
                              },
                              child: AnimatedContainer(
                                duration: Duration(milliseconds: 500),
                                margin: EdgeInsets.all(20),
                                height: 50,
                                width: MediaQuery.of(context).size.width,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: secondaryColor,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Icon(
                                      Icons.close,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                    Text(
                                      'HAPUS DARI KERANGJANG',
                                      style: GoogleFonts.robotoSlab(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                ),
              ],
            );
          }
        },
      ),
    );
  }

  void getCurrentUser() async {
    setState(() {
      currentUserId = FirebaseAuth.instance.currentUser.uid;
    });
  }

  void addToFavorite() {
    DatabaseServices.addToFavorite(currentUserId, widget.productID);
  }

  void deleteFromFavorite(String id) {
    DatabaseServices.deleteFromFavorite(id);
  }

  // Future getAllUserFavCollection() async {
  //   allFavList = [];
  //   QuerySnapshot docRef = await Firestore.instance
  //       .collection('favorite')
  //       .where('userId', isEqualTo: currentUserId)
  //       .getDocuments();

  //   docRef.documents.forEach((result) {
  //     allFavList.add(result.documentID);
  //   });
  // }

  Future<bool> isFavoriteItem() async {
    QuerySnapshot docRef = await FirebaseFirestore.instance
        .collection('favorite')
        .where('userId', isEqualTo: currentUserId)
        .where('productId', isEqualTo: widget.productID)
        .get();

    docRef.docs.forEach((result) {
      if (!favList.contains(result.id)) {
        favList.add(result.id);
      }
    });

    if (favList.isNotEmpty) {
      isFavorite = true;
      return isFavorite;
    } else {
      isFavorite = false;
      return isFavorite;
    }
  }
}
