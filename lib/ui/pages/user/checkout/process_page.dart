import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ecommerce/repositories/user_repository.dart';
import 'package:flutter_ecommerce/utils/color_codes.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:flutter_ecommerce/repositories/cart_list.dart' as cart;
import 'package:lottie/lottie.dart';

class ProcessPage extends StatefulWidget {
  final Function refresh;
  final User user;
  final UserRepository userRepository;
  final bool isSuccess;

  ProcessPage({
    @required this.refresh,
    @required this.user,
    @required this.userRepository,
    @required this.isSuccess,
  });

  @override
  _ProcessPageState createState() => _ProcessPageState();
}

class _ProcessPageState extends State<ProcessPage> {
  bool isLoading = true;
  String title = 'Tunggu ya..';

  void initState() {
    super.initState();

    resetCart();
  }

  void dispose() {
    super.dispose();
    print('dispose process page');
  }

  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  void resetCart() {
    cart.cartProduct = [];
    cart.mapCart = {};
    cart.price = {};
    cart.totalPrice = 0;
  }

  void navigateToHome() {
    widget.refresh();

    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    Timer timer = Timer(Duration(seconds: 4), () {
      setState(() {
        isLoading = false;
      });
    });

    return Scaffold(
      body: content(context, timer),
    );
  }

  Widget content(BuildContext context, Timer timer) {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      color: Colors.white,
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.only(top: 100),
            child: Text(title, style: GoogleFonts.fredokaOne(fontSize: 18)),
          ),
          isLoading
              ? Center(
                  child: Container(
                    margin: EdgeInsets.only(top: 100),
                    height: 300,
                    width: 300,
                    child: LottieBuilder.asset(
                        'assets/lottieAnimations/paper_plane.json'),
                  ),
                )
              : container(context, timer, widget.isSuccess),
        ],
      ),
    );
  }

  Widget container(BuildContext context, Timer timer, bool isSuccess) {
    timer.cancel();
    return isSuccess ? successTransaction(context) : failedTransaction(context);
  }

  Widget failedTransaction(BuildContext context) {
    return Column(
      children: [
        Center(
          child: Container(
            width: MediaQuery.of(context).size.width / 1.2,
            height: MediaQuery.of(context).size.height / 2.4,
            child: LottieBuilder.asset(
                'assets/lottieAnimations/payment-failed.json'),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              child: Text(
                'Tidak bisa menambahkan ',
                style: GoogleFonts.openSans(
                  fontSize: 17,
                ),
              ),
            ),
            Container(
              child: Text(
                'Pesanan',
                style: GoogleFonts.openSans(
                    fontSize: 17,
                    color: Colors.blue[900],
                    fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        Container(
          width: MediaQuery.of(context).size.width,
          margin: EdgeInsets.only(top: 15, left: 30, right: 30),
          child: Text(
            'kamu telah mencapai jumlah maksimum transaksi yang sedang menunggu',
            style: GoogleFonts.exo(
              fontSize: 15,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        Container(
          padding: EdgeInsets.fromLTRB(30, 50, 30, 20),
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              navigateToHome();
            },
            style: ElevatedButton.styleFrom(
              elevation: 5.0,
              padding: EdgeInsets.all(15.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              primary: thirdColor,
            ),
            child: Text(
              'Kembali ke Beranda',
              style: GoogleFonts.patuaOne(
                color: Colors.white,
                fontSize: 15.0,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget successTransaction(BuildContext context) {
    return Column(
      children: [
        Container(
          width: MediaQuery.of(context).size.width / 2,
          height: MediaQuery.of(context).size.height / 3,
          margin: EdgeInsets.only(bottom: 10, top: 10),
          child: LottieBuilder.asset('assets/lottieAnimations/success_2.json'),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              child: Text(
                'Pesanan kamu sedang kami ',
                style: GoogleFonts.openSans(
                  fontSize: 17,
                ),
              ),
            ),
            Container(
              child: Text(
                'Proses',
                style: GoogleFonts.openSans(
                    fontSize: 17,
                    color: thirdColor,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        Container(
          width: MediaQuery.of(context).size.width,
          margin: EdgeInsets.only(top: 15, left: 30, right: 30),
          child: Text(
            'Mohon ditunggu sampai admin mengkonfirmasi pesananmu',
            style: GoogleFonts.exo(
              fontSize: 15,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        Container(
          padding: EdgeInsets.fromLTRB(30, 50, 30, 20),
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              elevation: 5.0,
              padding: EdgeInsets.all(15.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              primary: primaryColor,
            ),
            onPressed: () {
              navigateToHome();
            },
            child: Text(
              'Kembali ke Beranda',
              style: GoogleFonts.patuaOne(
                color: Colors.white,
                fontSize: 15.0,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
