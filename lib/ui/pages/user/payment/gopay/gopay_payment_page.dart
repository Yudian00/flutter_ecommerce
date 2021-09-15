import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';
import 'package:flutter_ecommerce/utils/color_codes.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

class GopayPaymentPage extends StatefulWidget {
  final String transactionId;
  final snapshot;

  GopayPaymentPage({
    @required this.transactionId,
    @required this.snapshot,
  });

  @override
  _GopayPaymentPageState createState() => _GopayPaymentPageState();
}

class _GopayPaymentPageState extends State<GopayPaymentPage> {
  void initState() {
    super.initState();
  }

  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Pembayaran',
          style: GoogleFonts.roboto(
            fontWeight: FontWeight.w500,
            fontSize: 16,
            color: Colors.black87,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.black,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        elevation: 1.0,
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: ListView(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.03,
            ),
            Container(
              height: MediaQuery.of(context).size.height * 0.4,
              child: LottieBuilder.asset(
                  'assets/lottieAnimations/transaction.json'),
            ),
            SizedBox(
              height: 50,
            ),
            Text(
              'Pembayaran dengan Gopay telah dipilih',
              textAlign: TextAlign.center,
              style: GoogleFonts.openSans(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                'Silahkan lakukan pembayaran gopay sebelum jatuh tempo',
                textAlign: TextAlign.center,
                style: GoogleFonts.openSans(
                  color: Colors.black38,
                  fontSize: 11,
                ),
              ),
            ),
            SizedBox(
              height: 30,
            ),
            StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('midtrans')
                  .where('midtransId',
                      isEqualTo: widget.snapshot.data['order_id'])
                  .snapshots(),
              builder: (context, midtransSnapshot) {
                if (midtransSnapshot.connectionState ==
                    ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                } else {
                  // print(midtransSnapshot.data.docs[0]['expired_time']);
                  DateTime currentPhoneDate = DateTime.parse(midtransSnapshot
                      .data.docs[0]['expired_time']
                      .toDate()
                      .toString());
                  Timestamp myTimeStamp = Timestamp.fromDate(currentPhoneDate);

                  print(myTimeStamp.millisecondsSinceEpoch);

                  return Center(
                    child: CountdownTimer(
                      endTime: myTimeStamp.millisecondsSinceEpoch,
                      textStyle: GoogleFonts.openSans(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      onEnd: () {
                        // FirebaseFirestore.instance
                        //     .collection('transaction')
                        //     .doc(widget.transactionId)
                        //     .get()
                        //     .then((value) {
                        //   Map data = value.data();

                        //   if (data['status'] == 'Menunggu Pelunasan') {
                        //     print('SET EXPIRED FROM GOPAY PAYMENT PAGE');

                        //     DatabaseServices.setExpireTransactionStatus(
                        //         widget.transactionId);
                        //   } else {
                        //     print('TRANSACTION FIXED');
                        //   }
                        // });
                      },
                      endWidget: Text(
                        'Expired',
                        style: GoogleFonts.openSans(
                          color: Colors.red[300],
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                }
              },
            ),
            SizedBox(
              height: 30,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              child: ConstrainedBox(
                constraints: BoxConstraints.tightFor(
                  width: MediaQuery.of(context).size.width * 0.3,
                ),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                      primary: primaryColor,
                      elevation: 0.3,
                      side: BorderSide(
                        width: 1.0,
                        color: Colors.black12,
                      )),
                  child: Text(
                    'Kembali',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
