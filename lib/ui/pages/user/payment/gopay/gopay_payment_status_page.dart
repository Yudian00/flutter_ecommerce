import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';
import 'package:flutter_ecommerce/cubit/transactionStatusCubit/transactionstatuscubit_cubit.dart';
import 'package:flutter_ecommerce/repositories/DatabaseUser.dart';
import 'package:flutter_ecommerce/repositories/NotificationFCM.dart';
import 'package:flutter_ecommerce/utils/color_codes.dart';
import 'package:flutter_ecommerce/utils/midtrans_key.dart';
import 'package:flutter_ecommerce/utils/widget_utils.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

class GopayStatusPage extends StatefulWidget {
  final String midtransId;
  final String transactionId;
  final List itemDetails;
  final int grossAmount;

  GopayStatusPage({
    @required this.midtransId,
    @required this.transactionId,
    @required this.itemDetails,
    @required this.grossAmount,
  });

  @override
  _GopayStatusPageState createState() => _GopayStatusPageState();
}

class _GopayStatusPageState extends State<GopayStatusPage> {
  Stream stream;
  StreamController streamController = StreamController.broadcast();

  void initState() {
    super.initState();
    streamController = StreamController();
    loadPosts();
  }

  void dispose() {
    super.dispose();
    streamController.close();
  }

  Future fetchStatus() async {
    final response = await http.get(
        Uri.parse('https://api.sandbox.midtrans.com/v2/' +
            widget.midtransId +
            '/status'),
        headers: {
          'Accept': 'application/json',
          'Authorization': serverKeySB64,
        });

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load post');
    }
  }

  loadPosts() async {
    fetchStatus().then((res) async {
      streamController.add(res);
      return res;
    });
  }

  Future<Null> _handleRefresh() async {
    fetchStatus().then((res) async {
      streamController.add(res);
      return null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TransactionstatuscubitCubit(),
      child: Scaffold(
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
        body: RefreshIndicator(
          onRefresh: () => _handleRefresh(),
          child: Padding(
            padding: EdgeInsets.all(20),
            child: ListView(
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.03,
                ),
                Container(
                  height: MediaQuery.of(context).size.height * 0.35,
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
                        DateTime currentPhoneDate = DateTime.parse(
                            midtransSnapshot.data.docs[0]['expired_time']
                                .toDate()
                                .toString());
                        Timestamp myTimeStamp =
                            Timestamp.fromDate(currentPhoneDate);

                        return StreamBuilder(
                          stream: streamController.stream,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
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
                              print(snapshot.data);

                              Map mapRes = snapshot.data;

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
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 10.0),
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
                                return Column(
                                  children: [
                                    CountdownTimer(
                                      endTime:
                                          myTimeStamp.millisecondsSinceEpoch,
                                      textStyle: GoogleFonts.openSans(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      onEnd: () {
                                        print(
                                            'SET EXPIRED FROM GOPAY PAYMENT II PAGE');

                                        // testing
                                        // FirebaseFirestore.instance
                                        //     .collection('transaction')
                                        //     .doc(widget.transactionId)
                                        //     .get()
                                        //     .then((value) {
                                        //   Map data = value.data();
                                        //   print(
                                        //       '===============================');
                                        //   print(data);
                                        //   print(
                                        //       'SET EXPIRED FROM GOPAY PAYMENT II PAGE');
                                        // });

                                        // DatabaseServices
                                        //     .setExpireTransactionStatus(
                                        //         widget.transactionId);
                                      },
                                    ),
                                    SizedBox(
                                      height: 30,
                                    ),
                                    ConstrainedBox(
                                      constraints: BoxConstraints(
                                        maxHeight:
                                            MediaQuery.of(context).size.height *
                                                0.2,
                                        maxWidth:
                                            MediaQuery.of(context).size.width *
                                                0.7,
                                      ),
                                      child: ElevatedButton(
                                        onPressed: () async {
                                          String url = midtransSnapshot
                                              .data.docs[0]['deepLinkUrl'];
                                          showAlertDialog(context, url);
                                        },
                                        style: ElevatedButton.styleFrom(
                                          primary: primaryColor,
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.payment,
                                              color: Colors.white,
                                            ),
                                            SizedBox(
                                              width: 10,
                                            ),
                                            Text(
                                              'Bayar Sekarang ',
                                              style: TextStyle(fontSize: 11),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    ConstrainedBox(
                                      constraints: BoxConstraints(
                                        maxHeight:
                                            MediaQuery.of(context).size.height *
                                                0.2,
                                        maxWidth:
                                            MediaQuery.of(context).size.width *
                                                0.7,
                                      ),
                                      child: ElevatedButton(
                                        onPressed: () async {
                                          String url = midtransSnapshot
                                              .data.docs[0]['qrImageUrl'];
                                          showAlertDialog(context, url);
                                        },
                                        style: ElevatedButton.styleFrom(
                                          primary: Colors.grey[100],
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.qr_code_outlined,
                                              color: Colors.black,
                                            ),
                                            SizedBox(
                                              width: 10,
                                            ),
                                            Text(
                                              'Open QR Image',
                                              style: TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.black87),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 30,
                                    ),
                                  ],
                                );
                              }
                            }
                          },
                        );
                      }
                    }),
              ],
            ),
          ),
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

  Future<void> _launchInBrowser(String url) async {
    try {
      if (await canLaunch(url)) {
        await launch(url);
      }
    } catch (e) {
      print(e);
      print('cannot open browser');
    }
  }

  void transactionSuccess() {
    FirebaseFirestore.instance
        .collection('transaction')
        .doc(widget.transactionId)
        .get()
        .then((value) {
      Map data = value.data();

      if (data['status'] == 'Menunggu Pelunasan') {
        FirebaseFirestore.instance
            .collection('transaction')
            .doc(widget.transactionId)
            .update({
          'status': 'Pembayaran Lunas',
        });

        DatabaseUser.userCollection.get().then((value) {
          List<QueryDocumentSnapshot> data = value.docs;
          for (var i = 0; i < data.length; i++) {
            if (data[i]['role'] == 'admin') {
              String deviceToken = data[i]['token'];
              NotificationFCM.setNotificationFCM(deviceToken,
                  titleMessage: 'Order Paid',
                  bodyMessage:
                      'Pelanggan telah berhasil membayar pesanan. Silahkan cek pesanan di dashboard');
            }
          }
        });
      }
    });
  }

  void transactionExpired() {
    print('SET EXPIRED FROM GOPAY PAYMENT STATUS PAGE');
    FirebaseFirestore.instance
        .collection('transaction')
        .doc(widget.transactionId)
        .update({
      'status': 'Expired',
    });
  }

  showAlertDialog(BuildContext context, String url) {
    // set up the buttons
    Widget cancelButton = ElevatedButton(
      style: ElevatedButton.styleFrom(
        primary: Colors.white,
        elevation: 0.0,
      ),
      child: Text(
        "Tidak",
        style: TextStyle(
          color: Colors.red,
        ),
      ),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    Widget continueButton = ElevatedButton(
      style: ElevatedButton.styleFrom(
        primary: Colors.white,
        elevation: 0.0,
      ),
      child: Text(
        "Buka",
        style: TextStyle(
          color: Colors.blue,
        ),
      ),
      onPressed: () {
        Navigator.pop(context);
        _launchInBrowser(url);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text('Pembayaran',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          )),
      content: Text(
        "buka browser untuk memproses?",
        style: TextStyle(height: 1.5, fontSize: 12),
      ),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
