import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ecommerce/repositories/user_repository.dart';
import 'package:flutter_ecommerce/ui/widgets/CheckoutWidget/MainContext.dart';

import 'package:intl/intl.dart';
import 'package:meta/meta.dart';

// ignore: must_be_immutable
class ConfirmationPage extends StatefulWidget {
  Function refresh;
  String username;
  String userPhoneNumber;
  String userId;
  String note;
  String metodePembayaran;
  String kodepos;
  String address;
  String detailAlamat;
  int totalPrice;
  Map mapCart;

  User user;
  UserRepository userRepository;

  ConfirmationPage({
    @required this.refresh,
    @required this.username,
    @required this.userPhoneNumber,
    @required this.metodePembayaran,
    @required this.userId,
    @required this.mapCart,
    @required this.totalPrice,
    @required this.user,
    @required this.userRepository,
    @required this.note,
    @required this.address,
    @required this.detailAlamat,
    @required this.kodepos,
  });

  @override
  _ConfirmationPageState createState() => _ConfirmationPageState();
}

class _ConfirmationPageState extends State<ConfirmationPage> {
  List priceList = [];
  bool _termCondition = false;

  void initState() {
    super.initState();
    createPriceList();
  }

  void dispose() {
    super.dispose();
    print('dispose checkout page');
  }

  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  dynamic currentTime = DateFormat.Hm().format(DateTime.now());
  dynamic currentDate = DateFormat.yMMMMd().format(DateTime.now());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Checkout',
          style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 21, color: Colors.black),
        ),
        elevation: 0.0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.black,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Stack(
        children: [
          MainContext(
            user: widget.user,
            refresh: widget.refresh,
            userRepository: widget.userRepository,
            address: widget.address,
            detailAddress: widget.detailAlamat,
            kodepos: widget.kodepos,
            metodePembayaran: widget.metodePembayaran,
            userId: widget.userId,
            username: widget.username,
            userPhoneNumber: widget.userPhoneNumber,
            note: widget.note,
            mapCart: widget.mapCart,
            totalPrice: widget.totalPrice,
            priceList: priceList,
            setTermCondition: setTermCondition,
            termCondition: _termCondition,
          ),
        ],
      ),
    );
  }

  void setTermCondition(bool newValue) {
    setState(() {
      _termCondition = newValue;
    });
  }

  void createPriceList() async {
    for (var items in widget.mapCart.keys) {
      FirebaseFirestore.instance
          .collection('product')
          .doc(items)
          .get()
          .then((value) {
        var productDetail = value.data();

        //  calculate a new price after discount
        var discountPrice = int.parse(productDetail['harga']) *
            productDetail['discount_percent'] /
            100;
        var discount = int.parse(productDetail['harga']) - discountPrice;
        var newPrice2 = discount.toInt();
        priceList.add(newPrice2);
      });
    }
  }
}
