import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';
import 'package:flutter_ecommerce/repositories/DatabaseServices.dart';
import 'package:flutter_ecommerce/utils/color_codes.dart';
import 'package:flutter_ecommerce/utils/midtrans_key.dart';
import 'package:flutter_ecommerce/utils/widget_utils.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:http/http.dart' as http;

class BankPaymentStatusPage extends StatefulWidget {
  final String midtransId;
  final String transactionId;

  final List itemDetails;
  final int grossAmount;

  BankPaymentStatusPage({
    @required this.grossAmount,
    @required this.itemDetails,
    @required this.midtransId,
    @required this.transactionId,
  });

  @override
  _BankPaymentStatusPageState createState() => _BankPaymentStatusPageState();
}

class _BankPaymentStatusPageState extends State<BankPaymentStatusPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Status Pembayaran',
          style: GoogleFonts.roboto(
            fontWeight: FontWeight.w500,
            fontSize: 16,
            color: Colors.black87,
          ),
        ),
        elevation: 1.0,
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
      body: Padding(
        padding: EdgeInsets.all(20),
        child: ListView(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.03,
            ),
            Container(
              height: MediaQuery.of(context).size.height * 0.3,
              child: LottieBuilder.asset(
                  'assets/lottieAnimations/transaction.json'),
            ),
            SizedBox(
              height: 30,
            ),
            FutureBuilder(
              future: FirebaseFirestore.instance
                  .collection('midtrans')
                  .where('midtransId', isEqualTo: widget.midtransId)
                  .get(),
              builder: (context, midtransSnapshot) {
                if (midtransSnapshot.connectionState ==
                    ConnectionState.waiting) {
                  return Column(
                    children: [
                      SizedBox(
                        height: 30,
                      ),
                      Center(
                        child: loadingAnimation(),
                      ),
                    ],
                  );
                } else {
                  // print(midtransSnapshot.data.docs[0]['expired_time']);
                  DateTime currentPhoneDate = DateTime.parse(midtransSnapshot
                      .data.docs[0]['expired_time']
                      .toDate()
                      .toString());
                  Timestamp myTimeStamp = Timestamp.fromDate(currentPhoneDate);

                  return StreamBuilder<http.Response>(
                    stream: getTransactionStatus2(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Column(
                          children: [
                            SizedBox(
                              height: 30,
                            ),
                            Center(
                              child: loadingAnimation(),
                            ),
                          ],
                        );
                      } else {
                        http.Response data = snapshot.data;
                        Map mapRes = jsonDecode(data.body);

                        if (mapRes['transaction_status'] == 'expire') {
                          transactionExpired();
                          return Center(
                            child: Text(
                              'Expired',
                              style: GoogleFonts.openSans(
                                color: Colors.red[300],
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        } else if (mapRes['transaction_status'] ==
                            'settlement') {
                          transactionSuccess();
                          return Center(
                            child: Column(
                              children: [
                                Text(
                                  'Berhasil',
                                  style: GoogleFonts.openSans(
                                    color: Colors.green,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(
                                  height: 30,
                                ),
                                Padding(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 10.0),
                                  child: Text(
                                    'Pembayaran sudah lunas. Admin akan segera memproses pengiriman pesanan kamu',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.openSans(
                                      color: Colors.black54,
                                      fontSize: 12,
                                      height: 1.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        } else {
                          return ListView(
                            shrinkWrap: true,
                            children: [
                              Text(
                                'Pembayaran dengan Bank ' +
                                    mapRes['va_numbers'][0]['bank']
                                        .toString()
                                        .toUpperCase() +
                                    ' telah dipilih',
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
                                  'Silahkan lakukan pembayaran dengan menggunakan nomor Virtual Account berikut : ',
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
                              Text(
                                mapRes['va_numbers'][0]['va_number'],
                                textAlign: TextAlign.center,
                                style: GoogleFonts.openSans(
                                  letterSpacing: 2,
                                  wordSpacing: 3,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  color: Colors.blue,
                                ),
                              ),
                              SizedBox(
                                height: 30,
                              ),
                              Text(
                                'Berlaku sampai dengan : ',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.black38,
                                  fontSize: 11,
                                ),
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              Center(
                                child: CountdownTimer(
                                  endTime: myTimeStamp.millisecondsSinceEpoch,
                                  textStyle: GoogleFonts.openSans(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  onEnd: () {
                                    DatabaseServices.setExpireTransactionStatus(
                                        widget.transactionId);
                                  },
                                ),
                              ),
                              SizedBox(
                                height: 30,
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 20.0),
                                child: ConstrainedBox(
                                  constraints: BoxConstraints.tightFor(
                                    width:
                                        MediaQuery.of(context).size.width * 0.3,
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
                          );
                        }
                      }
                    },
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Stream<http.Response> getTransactionStatus2() async* {
    yield* Stream.periodic(Duration(seconds: 5), (_) {
      return http.get(
          Uri.parse('https://api.sandbox.midtrans.com/v2/' +
              widget.midtransId +
              '/status'),
          headers: {
            'Accept': 'application/json',
            'Authorization': serverKeySB64,
          });
    }).asyncMap((event) async => await event);
  }

  void transactionSuccess() {
    FirebaseFirestore.instance
        .collection('transaction')
        .doc(widget.transactionId)
        .update({
      'status': 'Pembayaran Lunas',
    });
  }

  void transactionExpired() {
    FirebaseFirestore.instance
        .collection('transaction')
        .doc(widget.transactionId)
        .update({
      'status': 'Expired',
    });
  }

  String splitVirtualAccount(String vaNumber) {
    final splitSize = 3;
    RegExp exp = new RegExp(r"\d{" + "$splitSize" + "}");
    String str = vaNumber;
    Iterable<Match> matches = exp.allMatches(str);
    var list = matches.map((m) => int.tryParse(m.group(0)));
    print(list);

    String newVirtualNumber =
        list.toString().replaceAll(new RegExp(r'[^\w\s]+'), '');
    print(newVirtualNumber);

    return newVirtualNumber;
  }
}
