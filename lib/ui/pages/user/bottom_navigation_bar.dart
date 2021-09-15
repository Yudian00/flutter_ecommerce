import 'dart:async';

import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ecommerce/repositories/user_repository.dart';
import 'package:flutter_ecommerce/ui/pages/user/product/product_page.dart';
import 'package:flutter_ecommerce/ui/pages/user/home/home_page.dart';
import 'package:flutter_ecommerce/ui/pages/user/profile/profile_page.dart';
import 'package:flutter_ecommerce/ui/pages/user/transaction/transaction_page.dart';
import 'package:flutter_ecommerce/utils/color_codes.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lottie/lottie.dart';

// ignore: must_be_immutable
class CustomBottomNavigationBar extends StatefulWidget {
  final User user;
  final UserRepository userRepository;
  int currentIndex;

  CustomBottomNavigationBar({
    @required this.user,
    @required this.userRepository,
    @required this.currentIndex,
  });

  @override
  _CustomBottomNavigationBarState createState() =>
      _CustomBottomNavigationBarState();
}

class _CustomBottomNavigationBarState extends State<CustomBottomNavigationBar> {
  // int currentIndex = 0;

  DateTime currentBackPressTime;

  final List<IconData> iconList = [
    Icons.home_outlined,
    Icons.shopping_bag_outlined,
    Icons.account_balance_wallet_outlined,
    Icons.person_outline,
  ];

  String _connectionStatus = 'Unknown';
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult> _connectivitySubscription;

  @override
  initState() {
    super.initState();
    initConnectivity();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  @override
  dispose() {
    super.dispose();
    _connectivitySubscription.cancel();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> widgetTab = <Widget>[
      HomePageParent(user: widget.user, userRepository: widget.userRepository),
      ExplorePageParent(
        user: widget.user,
        userRepository: widget.userRepository,
      ),
      TransactionPageParent(
        user: widget.user,
        userRepository: widget.userRepository,
      ),
      ProfilePageParent(
        userRepository: widget.userRepository,
        user: widget.user,
      ),
    ];

    void _onItemTapped(int index) {
      setState(() {
        widget.currentIndex = index;
      });
    }

    return Scaffold(
      body: WillPopScope(
          onWillPop: onWillPop,
          child: _connectionStatus == 'ConnectivityResult.none'
              ? _noInternetWidget()
              : widgetTab.elementAt(widget.currentIndex)),
      bottomNavigationBar: AnimatedBottomNavigationBar(
        gapWidth: 0,
        iconSize: 20,
        elevation: 10.0,
        backgroundColor: Colors.white,
        activeColor: primaryColor,
        inactiveColor: Colors.grey,
        icons: iconList,
        activeIndex: widget.currentIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  Widget _noInternetWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
            height: 300,
            width: 300,
            child: LottieBuilder.asset(
                'assets/lottieAnimations/no-internet.json')),
        SizedBox(
          height: 30,
        ),
        Text(
          'Koneksi bermasalah',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Padding(
          padding: EdgeInsets.all(30.0),
          child: Text(
            'Sepertinya koneksimu sedang bermasalah. Silahkan coba hubungkan ke Wi-Fi atau nyalakan paket data kamu',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
            ),
          ),
        )
      ],
    );
  }

  Future<bool> onWillPop() {
    DateTime now = DateTime.now();
    if (currentBackPressTime == null ||
        now.difference(currentBackPressTime) > Duration(seconds: 2)) {
      currentBackPressTime = now;
      Fluttertoast.showToast(
          msg: 'tap lagi untuk keluar', backgroundColor: Colors.black);
      return Future.value(false);
    }
    return Future.value(true);
  }

  Future<void> initConnectivity() async {
    ConnectivityResult result = ConnectivityResult.none;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      print(e.toString());
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) {
      return Future.value(null);
    }

    return _updateConnectionStatus(result);
  }

  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    switch (result) {
      case ConnectivityResult.wifi:
      case ConnectivityResult.mobile:
      case ConnectivityResult.none:
        setState(() {
          _connectionStatus = result.toString();
        });
        break;
      default:
        setState(() => _connectionStatus = 'Failed to get connectivity.');
        break;
    }
  }
}
