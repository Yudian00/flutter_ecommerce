import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_ecommerce/cubit/cartCubit/cart_cubit.dart';
import 'package:flutter_ecommerce/repositories/cart_list.dart' as cart;
import 'package:flutter_ecommerce/repositories/user_repository.dart';
import 'package:flutter_ecommerce/ui/pages/user/cart/detail_address_delivery.dart';
import 'package:flutter_ecommerce/ui/pages/user/checkout/checkout_page.dart';

import 'package:flutter_ecommerce/ui/widgets/CartWidget/PaymentMethodWidget.dart';

import 'package:flutter_ecommerce/ui/widgets/CartWidget/floatingContainer.dart';
import 'package:flutter_ecommerce/ui/widgets/CartWidget/EmptyCart.dart';
import 'package:flutter_ecommerce/utils/color_codes.dart';
import 'package:flutter_ecommerce/utils/widget_utils.dart';

import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';

class CartPageParent extends StatelessWidget {
  final Function refresh;
  final User user;
  final UserRepository userRepository;

  CartPageParent({
    @required this.user,
    @required this.userRepository,
    @required this.refresh,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CartCubit(),
      child: CartPage(
        refresh: refresh,
        user: user,
        userRepository: userRepository,
      ),
    );
  }
}

class CartPage extends StatefulWidget {
  final User user;
  final UserRepository userRepository;
  final Function refresh;

  CartPage({
    @required this.user,
    @required this.userRepository,
    @required this.refresh,
  });

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  var listProduct = cart.cartProduct;

  var mapCart = {};
  var priceCart = {};
  var initialSum = 0;

  //user information
  var userid;
  var username;
  var userPhonenumber;

  String usernameOnChanged;
  String userPhoneNumberOnChanged;
  String note = '';

  String provinsi;
  String kabupaten;
  String kecamatan;

  bool _isPayAtStoreselected = false;
  bool _isTransferSelected = false;

  final _formKey = GlobalKey<FormState>();

  void initState() {
    for (var i = 0; i < cart.cartProduct.length; i++) {
      mapCart.putIfAbsent(listProduct[i], () => 1);
    }
    sumInitial();
    getUserInfo();
    super.initState();
  }

  getUserInfo() async {
    final User user = FirebaseAuth.instance.currentUser;
    userid = user.uid;
    // print('user id : ' + userid.toString());
    getUserDetailInfo(userid);
  }

  getUserDetailInfo(String id) async {
    final userData =
        await FirebaseFirestore.instance.collection('user').doc(id).get();

    username = userData['username'];
    userPhonenumber = userData['noHP'];

    print('username : ' + username);
    print('noHP : ' + userPhonenumber);
  }

  void dispose() {
    super.dispose();
    print('dispose cart page');
  }

  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  void sumInitial() {
    cart.price.values.forEach((item) {
      initialSum = initialSum + item;
    });
  }

  void setPayOnATM() {
    setState(() {
      _isTransferSelected = !_isTransferSelected;
      _isPayAtStoreselected = false;
    });
  }

  void setPayAtStore() {
    setState(() {
      _isPayAtStoreselected = !_isPayAtStoreselected;
      _isTransferSelected = false;
    });
  }

  void setUserNamePickUpStore(String username) {
    print('set username');
    setState(() {
      usernameOnChanged = username;
    });
    print('after set : ' + username);
  }

  void setUserPhonePickupStore(String userPhoneNumber) {
    setState(() {
      userPhoneNumberOnChanged = userPhoneNumber;
    });
  }

  void setNote(String changeNote) {
    setState(() {
      note = changeNote;
    });
  }

  void setAddress(
      String valueProvinsi, String valueKabupaten, String valueKecamatan) {
    setState(() {
      provinsi = valueProvinsi;
      kabupaten = valueKabupaten;
      kecamatan = valueKecamatan;
    });
  }

  void validate(int totalPrice) {
    if (_formKey.currentState.validate()) {
      if (_isPayAtStoreselected) {
        Navigator.push(
          context,
          PageTransition(
            type: PageTransitionType.rightToLeft,
            child: ConfirmationPage(
              metodePembayaran: 'Bayar di Toko',
              kodepos: '',
              detailAlamat: '',
              address: '',
              note: note,
              refresh: widget.refresh,
              user: widget.user,
              userRepository: widget.userRepository,
              username: usernameOnChanged,
              userPhoneNumber: userPhoneNumberOnChanged,
              userId: userid,
              mapCart: cart.mapCart,
              totalPrice: totalPrice,
            ),
          ),
        );
      } else {
        if (provinsi == null || kabupaten == null || kecamatan == null) {
          final snackBar = SnackBar(
            content: Text('Informasi Alamat masih belum lengkap'),
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        } else {
          Navigator.push(
            context,
            PageTransition(
              type: PageTransitionType.rightToLeft,
              child: DetailAddressDelivery(
                user: widget.user,
                userId: userid,
                userRepository: widget.userRepository,
                kabupaten: kabupaten,
                kecamatan: kecamatan,
                provinsi: provinsi,
                mapCart: cart.mapCart,
                totalPrice: totalPrice,
              ),
            ),
          );
        }
      }
    } else {
      print('err');
    }
  }

  @override
  Widget build(BuildContext context) {
    //set initial mapCart
    cart.mapCart = mapCart;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(
          'Keranjang',
          style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 21, color: Colors.black),
        ),
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: _formKey,
        child: Stack(
          children: [
            cart.cartProduct.length == 0 ? EmptyCart() : listItemCart(),
            FloatingContainer(
              validate: validate,
              user: widget.user,
              userRepository: widget.userRepository,
              userId: userid,
              username: username,
              userPhoneNumber: userPhonenumber,
              note: note,
              initalPrice: initialSum,
              isPayAtStoreselected: _isPayAtStoreselected,
              isTransferSelected: _isTransferSelected,
            )
          ],
        ),
      ),
    );
  }

  Widget listItemCart() {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Container(
        height: MediaQuery.of(context).size.height / 0.4,
        child: ListView(
          children: <Widget>[
            SizedBox(
              height: 12,
            ),
            for (var items in listProduct)
              StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('product')
                    .doc(items)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: loadingAnimation());
                  }
                  var productDetail = snapshot.data;
                  priceCart.putIfAbsent(items, () => productDetail['harga']);

                  //  calculate a new price after discount
                  var discountPrice = int.parse(productDetail['harga']) *
                      productDetail['discount_percent'] /
                      100;
                  var discount =
                      int.parse(productDetail['harga']) - discountPrice;
                  var newPrice2 = discount.toInt();

                  return Container(
                    color: Colors.grey[100],
                    margin: EdgeInsets.only(left: 12, right: 12, bottom: 12),
                    padding: EdgeInsets.fromLTRB(12, 10, 12, 0),
                    child: Column(
                      children: [
                        // ROW per Item
                        Row(
                          children: <Widget>[
                            Container(
                              padding: EdgeInsets.all(8),
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                image: DecorationImage(
                                  image: NetworkImage(
                                    productDetail['url'],
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 12,
                            ),
                            Row(
                              children: <Widget>[
                                Column(
                                  children: <Widget>[
                                    //PRODUCT NAME
                                    Container(
                                      width: 100,
                                      child: Text(
                                        productDetail['nama'],
                                        style: TextStyle(
                                          height: 1.6,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 12,
                                    ),
                                    Row(
                                      children: <Widget>[
                                        //MIN QUANTITY PRODUCT
                                        BlocBuilder<CartCubit, CartState>(
                                          // ignore: missing_return
                                          builder: (context, state) {
                                            if (state is CartInitial) {
                                              return GestureDetector(
                                                onTap: () {
                                                  cart.cartProduct
                                                      .remove(items);
                                                  cart.price.remove(items);
                                                  print(cart.price);

                                                  context
                                                      .read()<CartCubit>()
                                                      .minQtyProduct(
                                                        mapCart,
                                                        priceCart,
                                                        items,
                                                        newPrice2,
                                                      );
                                                  setState(() {});
                                                },
                                                child: Container(
                                                  width: 20,
                                                  height: 20,
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey[300],
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            4),
                                                  ),
                                                  child: Icon(
                                                    Icons.remove,
                                                    size: 15,
                                                  ),
                                                ),
                                              );
                                            } else if (state is LoadCartState) {
                                              return GestureDetector(
                                                onTap: () {
                                                  if (state.map[items] > 1) {
                                                    context
                                                        .read<CartCubit>()
                                                        .minQtyProduct(
                                                            mapCart,
                                                            priceCart,
                                                            items,
                                                            newPrice2);
                                                  } else {
                                                    context
                                                        .read<CartCubit>()
                                                        .minQtyProduct(
                                                            mapCart,
                                                            priceCart,
                                                            items,
                                                            newPrice2);
                                                    print(state.totalPrice);

                                                    cart.cartProduct
                                                        .remove(items);
                                                    cart.price.remove(items);
                                                    print(cart.price);

                                                    priceCart.remove(items);
                                                    setState(() {});
                                                  }
                                                },
                                                child: Container(
                                                  width: 20,
                                                  height: 20,
                                                  decoration: state.map[items] >
                                                          1
                                                      ? BoxDecoration(
                                                          color: primaryColor,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(4),
                                                        )
                                                      : BoxDecoration(
                                                          color:
                                                              Colors.grey[300],
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(4),
                                                        ),
                                                  child: Icon(
                                                    Icons.remove,
                                                    size: 15,
                                                    color: state.map[items] > 1
                                                        ? Colors.white
                                                        : Colors.black,
                                                  ),
                                                ),
                                              );
                                            }
                                          },
                                        ),

                                        //QUANTITY OF PRODUCT (TEXT)
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 22.0),
                                          child:
                                              BlocBuilder<CartCubit, CartState>(
                                            // ignore: missing_return
                                            builder: (context, state) {
                                              if (state is CartInitial) {
                                                return Text(
                                                  '1',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 18),
                                                );
                                              } else if (state
                                                  is LoadCartState) {
                                                return Text(
                                                  state.map[items].toString(),
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 18),
                                                );
                                              }
                                            },
                                          ),
                                        ),

                                        //ADD QUANTITY PRODUCT
                                        GestureDetector(
                                          onTap: () {
                                            context
                                                .read<CartCubit>()
                                                .addQtyProduct(
                                                    mapCart,
                                                    priceCart,
                                                    items,
                                                    newPrice2);
                                          },
                                          child: Container(
                                            width: 20,
                                            height: 20,
                                            decoration: BoxDecoration(
                                              color: primaryColor,
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: Icon(
                                              Icons.add,
                                              size: 15,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  width: 20,
                                ),
                              ],
                            ),

                            // CURRENT PRICE
                            BlocBuilder<CartCubit, CartState>(
                              // ignore: missing_return
                              builder: (context, state) {
                                if (state is CartInitial) {
                                  return Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        productDetail['onDiscount']
                                            ? Container(
                                                width: 100,
                                                child: Text(
                                                  NumberFormat.currency(
                                                          locale: 'id',
                                                          symbol: 'Rp',
                                                          decimalDigits: 0)
                                                      .format(int.parse(
                                                          productDetail[
                                                              'harga'])),
                                                  style: TextStyle(
                                                      decoration: TextDecoration
                                                          .lineThrough,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 15),
                                                ),
                                              )
                                            : Container(),
                                        Container(
                                          width: 100,
                                          child: Text(
                                            NumberFormat.currency(
                                                    locale: 'id',
                                                    symbol: 'Rp',
                                                    decimalDigits: 0)
                                                .format(newPrice2)
                                                .toString(),
                                            style: TextStyle(
                                                color:
                                                    productDetail['onDiscount']
                                                        ? Colors.red
                                                        : Colors.black,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                } else if (state is LoadCartState) {
                                  //CASTING TYPE TO INT
                                  var list = [];

                                  // ignore: unused_local_variable
                                  var parse;

                                  state.priceCart
                                      .forEach((k, v) => list.add(v));
                                  print(list);

                                  if (state.priceCart[items] is String) {
                                    parse = int.parse(state.priceCart[items]);
                                  } else {
                                    parse = state.priceCart[items];
                                  }

                                  //calculate a new price after discount
                                  var discountPrice =
                                      int.parse(productDetail['harga']) *
                                          productDetail['discount_percent'] /
                                          100;

                                  var currentPrice =
                                      int.parse(productDetail['harga']) -
                                          discountPrice;

                                  var finalValue =
                                      currentPrice * state.map[items];

                                  return Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        productDetail['onDiscount']
                                            ? Container(
                                                width: 100,
                                                child: Text(
                                                  NumberFormat.currency(
                                                          locale: 'id',
                                                          symbol: 'Rp',
                                                          decimalDigits: 0)
                                                      .format(int.parse(
                                                              productDetail[
                                                                  'harga']) *
                                                          state.map[items]),
                                                  style: TextStyle(
                                                      decoration: TextDecoration
                                                          .lineThrough,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 15),
                                                ),
                                              )
                                            : Container(),
                                        Container(
                                          width: 100,
                                          child: Text(
                                            NumberFormat.currency(
                                                    locale: 'id',
                                                    symbol: 'Rp',
                                                    decimalDigits: 0)
                                                .format(finalValue),
                                            style: TextStyle(
                                                color:
                                                    productDetail['onDiscount']
                                                        ? Colors.red
                                                        : Colors.black,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 20,
                        ),
                      ],
                    ),
                  );
                },
              ),
            PaymentMethod(
              context: context,
              setUsernamePickup: setUserNamePickUpStore,
              setUserPhonePickup: setUserPhonePickupStore,
              setTransferFunction: setPayOnATM,
              setPayAtStoreFunction: setPayAtStore,
              username: username,
              userPhoneNumber: userPhonenumber,
              note: note,
              setNote: setNote,
              setAddress: setAddress,
            ),
            SizedBox(
              height: 200,
            )
          ],
        ),
      ),
    );
  }
}
