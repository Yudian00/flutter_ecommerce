import 'package:flutter/material.dart';
import 'package:flutter_ecommerce/utils/color_codes.dart';

class SplashPage extends StatefulWidget {
  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: primaryColor,
        child: Center(
          child: Container(
            height: 250,
            width: 250,
            child: Image.asset('assets/images/splash-screen-logo.png'),
          ),
        ),
      ),
    );
  }
}
