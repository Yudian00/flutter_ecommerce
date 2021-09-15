import 'dart:async';

import 'package:badges/badges.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:entry/entry.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_ecommerce/blocs/homeBloc/home_page_bloc.dart';
import 'package:flutter_ecommerce/blocs/homeBloc/home_page_state.dart';
import 'package:flutter_ecommerce/cubit/exploreCubit/cubit/explore_cubit.dart';
import 'package:flutter_ecommerce/repositories/cart_list.dart';
import 'package:flutter_ecommerce/repositories/user_repository.dart';
import 'package:flutter_ecommerce/ui/pages/login_page.dart';
import 'package:flutter_ecommerce/ui/pages/user/cart/cart_page.dart';
import 'package:flutter_ecommerce/ui/pages/user/product/product_detail.dart';
import 'package:flutter_ecommerce/ui/pages/user/search/search_page.dart';
import 'package:flutter_ecommerce/utils/color_codes.dart';
import 'package:flutter_ecommerce/utils/categories.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

/// Fix the Bloc Provider

class ExplorePageParent extends StatelessWidget {
  final User user;
  final UserRepository userRepository;

  ExplorePageParent({
    @required this.user,
    @required this.userRepository,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ExploreCubit>(
          create: (context) => ExploreCubit(),
        ),
        BlocProvider<HomePageBloc>(
          create: (context) => HomePageBloc(userRepository: userRepository),
        ),
      ],
      child: ExplorePage(
        user: user,
        userRepository: userRepository,
      ),
      // child: DrawerScreen(user: user, userRepository: userRepository),
    );
  }
}

// ignore: must_be_immutable
class ExplorePage extends StatefulWidget {
  User user;
  UserRepository userRepository;

  ExplorePage({
    @required this.user,
    @required this.userRepository,
  });

  @override
  _ExplorePageState createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  var productID = [];

  bool isChangeSort = false;
  bool isSearch = false;
  bool currentOrderIsDescending = true;

  List itemList = [];
  Map productData = {};

  String searchText;

  Future getProductID() async {
    productID = [];
    QuerySnapshot docRef = await FirebaseFirestore.instance
        .collection('product')
        .where('status', isEqualTo: 'tersedia')
        .orderBy(orderBy, descending: isDescending)
        .get();

    docRef.docs.forEach((result) {
      productID.add(result.id);
    });
  }

  void initState() {
    super.initState();
    getAllProductData();
    getProductData();
  }

  @override
  void dispose() {
    // Never called
    print("Disposing product route");
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
        title: isSearch
            ? searchAppbar()
            : Text(
                'Produk',
                style: GoogleFonts.roboto(
                  color: Colors.black87,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          Padding(
            padding: EdgeInsets.fromLTRB(15, 10, 0, 15),
            child: isSearch
                ? IconButton(
                    onPressed: () {
                      setState(() {
                        isSearch = !isSearch;
                      });
                    },
                    icon: Icon(
                      Icons.search_off_outlined,
                      color: primaryColor,
                      size: 20,
                    ),
                  )
                : IconButton(
                    onPressed: () {
                      setState(() {
                        isSearch = !isSearch;
                      });
                    },
                    icon: Icon(
                      Icons.search_outlined,
                      color: primaryColor,
                      size: 20,
                    ),
                  ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(0, 10, 15, 15),
            child: IconButton(
              onPressed: () => Navigator.of(context)
                  .push(
                    MaterialPageRoute(
                      builder: (context) => CartPageParent(
                        refresh: refresh,
                        user: widget.user,
                        userRepository: widget.userRepository,
                      ),
                    ),
                  )
                  .then((value) => refresh()),
              icon: Badge(
                badgeColor: primaryColor,
                badgeContent: Text(
                  cartProduct.length.toString(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                  ),
                ),
                child: Icon(
                  Icons.shopping_cart_outlined,
                  size: 20,
                ),
              ),
              color: primaryColor,
            ),
          ),
        ],
      ),
      floatingActionButton: GestureDetector(
        onTap: () {
          showFilterList();
        },
        child: Container(
          height: 50,
          width: 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: primaryColor,
          ),
          child: Center(
            child: Icon(
              Icons.filter_list,
              color: Colors.white,
            ),
          ),
        ),
      ),
      body: Entry.opacity(
        duration: Duration(milliseconds: 1500),
        child: Container(
          child: BlocListener<HomePageBloc, HomePageState>(
            listener: (BuildContext context, state) {
              if (state is LogOutSuccessState) {
                Navigator.pop(context);
                return navigateToLoginpPage(context);
              }
            },
            child: BlocBuilder<ExploreCubit, ExploreState>(
              builder: (context, state) {
                return streamBuilderData();
              },
            ),
          ),
        ),
      ),
    );
  }

  //Widget ================================================================
  Widget searchAppbar() {
    return TextField(
      autofocus: true,
      decoration: InputDecoration(hintText: 'Cari barang'),
      onSubmitted: (value) {
        searchText = value;
        if (searchText.isNotEmpty) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SearchResultPage(
                user: widget.user,
                productData: productData,
                productID: productID,
                itemList: itemList,
                searchItem: searchText.isEmpty ? ' ' : searchText,
              ),
            ),
          ).then((value) {
            setState(() {});
          });
        } else {
          Fluttertoast.showToast(
            msg: 'Barang yang dicari tidak boleh kosong',
            backgroundColor: Colors.black87,
          );
        }
      },
    );
  }

  Widget streamBuilderData() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('product')
          .where('status', isEqualTo: 'tersedia')
          .orderBy(orderBy, descending: isDescending)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.data == null)
          return Center(child: CircularProgressIndicator());
        var data = snapshot.data.docs;
        getProductID();

        if (snapshot.hasError) {
          return Center(child: Container());
        } else {
          return gridViewProduct(data);
        }
      },
    );
  }

  Widget gridViewProduct(data) {
    return GridView.builder(
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
                    productID: productID[index], user: widget.user),
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

  Widget bubbleCategory(String label, String varData, var setState) {
    return GestureDetector(
      onTap: () {
        onSelectedCategory(varData, setState);
      },
      child: Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          border: Border.all(
            color: primaryColor,
          ),
          borderRadius: BorderRadius.circular(40),
          color: selectedCategory[varData] == true ? thirdColor : Colors.white,
        ),
        margin: EdgeInsets.all(10),
        child: Text(
          label,
          style: GoogleFonts.roboto(
            fontSize: 12,
            color: selectedCategory[varData] == true
                ? Colors.white
                : Colors.black54,
            decoration: TextDecoration.none,
          ),
        ),
      ),
    );
  }

  //FUNCTION ===============================================================
  void refresh() {
    setState(() {});
  }

  navigatetoProductPage(int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ProductDetailParent(productID: productID[index], user: widget.user),
      ),
    ).then((value) => setState(() {}));
  }

  void navigateToLoginpPage(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) {
          return LoginPageParent(userRepository: widget.userRepository);
        },
      ),
    );
  }

  void onSelectedCategory(String label, var setState) {
    print('selected category : ' + label);
    selectedCategory['nama'] = false;
    selectedCategory['onDiscount'] = false;
    selectedCategory['harga'] = false;
    selectedCategory['kategori'] = false;
    selectedCategory['stok barang'] = false;
    selectedCategory['timestamp'] = false;

    selectedCategory[label] = true;

    setState(() {
      isChangeSort = true;
    });
  }

  void changeOrderResult(var setState) {
    setState(() {
      isChangeSort = true;
      currentOrderIsDescending = !currentOrderIsDescending;
    });
  }

  void changeCategory() {
    var category = selectedCategory.keys.firstWhere(
      (k) => selectedCategory[k] == true,
      orElse: () => null,
    );
    print(category);
    setState(() {
      orderBy = category;
      isDescending = currentOrderIsDescending;
      isChangeSort = false;
    });
    Navigator.pop(context);
  }

  void getAllProductData() {
    itemList = [];

    final docRef = FirebaseFirestore.instance
        .collection('product')
        .where('status', isEqualTo: 'tersedia')
        .orderBy(orderBy, descending: isDescending);

    docRef.get().then((snapshot) {
      snapshot.docs.forEach((doc) {
        itemList.add(doc.data());
      });
    });
  }

  Future getProductData() async {
    productID = [];
    QuerySnapshot docRef = await FirebaseFirestore.instance
        .collection('product')
        .where('status', isEqualTo: 'tersedia')
        .orderBy(orderBy, descending: isDescending)
        .get();

    docRef.docs.forEach((result) {
      productID.add(result.id);
    });

    for (var i = 0; i < productID.length; i++) {
      productData.putIfAbsent(productID[i], () => itemList[i]);
    }

    print(productData);
  }

  void showFilterList() {
    showGeneralDialog(
      barrierLabel: "Cancel Order",
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: Duration(milliseconds: 200),
      context: context,
      pageBuilder: (_, __, ___) {
        return StatefulBuilder(
          builder: (context, setState) => Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 450,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(30, 50, 0, 20),
                    child: Text(
                      'tampilkan berdasarkan : ',
                      style: GoogleFonts.roboto(
                        fontSize: 16,
                        color: Colors.black54,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(30, 0, 0, 50),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            bubbleCategory('nama', 'nama', setState),
                            bubbleCategory('diskon', 'onDiscount', setState),
                            bubbleCategory('harga', 'harga', setState),
                            bubbleCategory('kategori', 'kategori', setState),
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: [
                            bubbleCategory(
                                'stok barang', 'stok barang', setState),
                            bubbleCategory('terbaru', 'timestamp', setState),
                          ],
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          'urutkan hasil : ',
                          style: GoogleFonts.roboto(
                            fontSize: 16,
                            color: Colors.black54,
                            decoration: TextDecoration.none,
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                changeOrderResult(setState);
                              },
                              child: Container(
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: primaryColor,
                                  ),
                                  borderRadius: BorderRadius.circular(40),
                                  color: currentOrderIsDescending == false
                                      ? thirdColor
                                      : Colors.white,
                                ),
                                margin: EdgeInsets.all(10),
                                child: Text(
                                  'menaik',
                                  style: GoogleFonts.roboto(
                                    fontSize: 12,
                                    color: currentOrderIsDescending == false
                                        ? Colors.white
                                        : Colors.black54,
                                    decoration: TextDecoration.none,
                                  ),
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                changeOrderResult(setState);
                              },
                              child: Container(
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: primaryColor,
                                  ),
                                  borderRadius: BorderRadius.circular(40),
                                  color: currentOrderIsDescending == true
                                      ? thirdColor
                                      : Colors.white,
                                ),
                                margin: EdgeInsets.all(10),
                                child: Text(
                                  'menurun',
                                  style: GoogleFonts.roboto(
                                    fontSize: 12,
                                    color: currentOrderIsDescending == true
                                        ? Colors.white
                                        : Colors.black54,
                                    decoration: TextDecoration.none,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  isChangeSort
                      ? Align(
                          alignment: Alignment.centerRight,
                          child: GestureDetector(
                            onTap: () => changeCategory(),
                            child: Container(
                              margin: EdgeInsets.symmetric(
                                horizontal: 50,
                              ),
                              height: 50,
                              width: MediaQuery.of(context).size.width,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: primaryColor,
                              ),
                              child: Center(
                                child: Text(
                                  'Terapkan',
                                  style: GoogleFonts.roboto(
                                    fontSize: 16,
                                    color: Colors.white,
                                    decoration: TextDecoration.none,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        )
                      : Container(),
                ],
              ),
            ),
          ),
        );
      },
      transitionBuilder: (_, anim, __, child) {
        return SlideTransition(
          position: Tween(begin: Offset(0, 1), end: Offset(0, 0)).animate(anim),
          child: child,
        );
      },
    );
  }
}
