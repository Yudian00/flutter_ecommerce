import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';
import 'package:flutter_ecommerce/repositories/DatabaseServices.dart';
import 'package:flutter_ecommerce/utils/color_codes.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

class BankPaymentPage extends StatefulWidget {
  final String transactionId;
  final String bank;
  final snapshot;

  BankPaymentPage({
    @required this.snapshot,
    @required this.bank,
    @required this.transactionId,
  });

  @override
  _BankPaymentPageState createState() => _BankPaymentPageState();
}

class _BankPaymentPageState extends State<BankPaymentPage> {
  void initState() {
    super.initState();
  }

  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              height: MediaQuery.of(context).size.height * 0.3,
              child: LottieBuilder.asset(
                  'assets/lottieAnimations/transaction.json'),
            ),
            SizedBox(
              height: 30,
            ),
            Text(
              'Pembayaran dengan Bank ' +
                  widget.bank.toUpperCase() +
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
                  height: 1.5,
                  fontSize: 11,
                ),
              ),
            ),
            SizedBox(
              height: 30,
            ),
            Center(
              child: Text(
                widget.snapshot.data['va_numbers'][0]['va_number'],
                textAlign: TextAlign.center,
                style: GoogleFonts.openSans(
                  letterSpacing: 2,
                  wordSpacing: 3,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.blue,
                ),
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
                        DatabaseServices.setExpireTransactionStatus(
                            widget.transactionId);
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
