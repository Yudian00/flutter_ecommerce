import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

class EmptyCart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.5,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Container(
              width: MediaQuery.of(context).size.width / 1.2,
              height: MediaQuery.of(context).size.height / 2.4,
              child:
                  LottieBuilder.asset('assets/lottieAnimations/lostWhale.json'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Text(
              'Keranjang kosong',
              textAlign: TextAlign.center,
              style: GoogleFonts.openSans(
                  fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: Text(
              'Kamu belum menambahkan barang disini',
              textAlign: TextAlign.center,
              style: GoogleFonts.openSans(fontSize: 15),
            ),
          )
        ],
      ),
    );
  }
}
