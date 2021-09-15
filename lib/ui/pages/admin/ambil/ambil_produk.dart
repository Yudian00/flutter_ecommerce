import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ecommerce/ui/widgets/adminWidget/take_order_list.dart';
import 'package:flutter_ecommerce/utils/color_codes.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

class AmbilProductPage extends StatefulWidget {
  @override
  _AmbilProductPageState createState() => _AmbilProductPageState();
}

class _AmbilProductPageState extends State<AmbilProductPage> {
  void initState() {
    super.initState();
  }

  @override
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
        title: Text(
          'Pesanan Diambil',
          style: GoogleFonts.roboto(
            color: Colors.black,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.black,
          ),
        ),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('transaction')
            .where('status', isEqualTo: 'Ambil di toko')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
              ),
            );
          } else {
            QuerySnapshot querySnapshot = snapshot.data;

            if (querySnapshot.docs.length == 0) {
              return Center(
                child: Column(
                  children: [
                    SizedBox(
                      height: 100,
                    ),
                    Container(
                      height: MediaQuery.of(context).size.height * 0.4,
                      width: MediaQuery.of(context).size.width * 0.5,
                      child: LottieBuilder.asset(
                          'assets/lottieAnimations/empty_illustration_99.json'),
                    ),
                    Text(
                      'Pesanan Kosong',
                      style: GoogleFonts.roboto(
                        color: Colors.black54,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Text(
                      'Belum ada pesanan yang masuk saat ini',
                      style: GoogleFonts.roboto(
                        color: Colors.black45,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              );
            } else {
              return TakeOrderList(
                querySnapshot: querySnapshot,
              );
            }
          }
        },
      ),
    );
  }
}
