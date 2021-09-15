import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:entry/entry.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_ecommerce/cubit/transactionList/transactionlist_cubit.dart';
import 'package:flutter_ecommerce/repositories/DatabaseServices.dart';
import 'package:flutter_ecommerce/repositories/user_repository.dart';
import 'package:flutter_ecommerce/ui/pages/user/payment/bank_transfer/bank_payment_status_page.dart';
import 'package:flutter_ecommerce/ui/pages/user/payment/gopay/gopay_payment_status_page.dart';
import 'package:flutter_ecommerce/ui/pages/user/payment/payment_option_page.dart';
import 'package:flutter_ecommerce/utils/color_codes.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';

class TransactionDetailParent extends StatelessWidget {
  final String transactionId;
  //userdata
  final User user;
  final UserRepository userRepository;
  final Function refresh;

  TransactionDetailParent({
    @required this.transactionId,
    @required this.user,
    @required this.userRepository,
    @required this.refresh,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TransactionlistCubit(),
      child: TransactionDetailPage(
        refresh: refresh,
        transactionId: transactionId,
        user: user,
        userRepository: userRepository,
      ),
    );
  }
}

class TransactionDetailPage extends StatefulWidget {
  final String transactionId;

  final User user;
  final UserRepository userRepository;
  final Function refresh;

  TransactionDetailPage({
    @required this.transactionId,
    @required this.user,
    @required this.userRepository,
    @required this.refresh,
  });

  @override
  _TransactionDetailPageState createState() => _TransactionDetailPageState();
}

class _TransactionDetailPageState extends State<TransactionDetailPage> {
  List itemDetails = [];
  int grossAmount = 0;

  void initState() {
    super.initState();
    print(widget.transactionId);
  }

  void dispose() {
    print('dispose detail transaction page');
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
          'Detail',
          style: GoogleFonts.roboto(
            fontWeight: FontWeight.w500,
            fontSize: 14,
            color: Colors.black87,
          ),
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
      body: BlocListener<TransactionlistCubit, TransactionlistState>(
        listener: (context, state) {
          if (state is TransactionListDeleted) {
            Fluttertoast.showToast(
              msg: 'Pesanan sudah dibatalkan',
              textColor: Colors.white,
              backgroundColor: thirdColor,
            );
            Navigator.pop(context);
            navigateToDetailPage();
          }
        },
        child: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('transaction')
              .doc(widget.transactionId)
              .snapshots(),
          builder: (context, snapshotTransaction) {
            if (snapshotTransaction.connectionState ==
                ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            } else {
              var transactionData = snapshotTransaction.data;
              var transactionDataLength = transactionData['itemList'].length;

              var date = DateTime.parse(
                  transactionData['created'].toDate().toString());

              // var date = new DateTime.now();
              var formatter = DateFormat('dd-MM-yyyy kk:mm');
              String transactionDate = formatter.format(date);

              // ongkir dan harga belajaan
              int totalBelanjaan =
                  transactionData['totalPrice2'] - transactionData['ongkir'];

              grossAmount = transactionData['totalPrice2'];

              // if (transactionData['status'] == 'Menunggu Pelunasan')
              //   checking(transactionData, widget.transactionId);

              return Entry.opacity(
                duration: Duration(seconds: 1),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      subHeading('Detail Items'),
                      listItem(transactionDataLength, transactionData),
                      transactionData['status'] == 'Menunggu Pembayaran'
                          ? Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.all(20.0),
                                      child: Text(
                                        'Harga Semua Barang : ',
                                        style: TextStyle(fontSize: 13),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(20.0),
                                      child: Text(
                                        NumberFormat.currency(
                                                locale: 'id',
                                                symbol: 'Rp',
                                                decimalDigits: 0)
                                            .format(
                                          totalBelanjaan,
                                        ),
                                        style: GoogleFonts.mavenPro(
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.all(20.0),
                                      child: Text(
                                        'Ongkir : ',
                                        style: TextStyle(fontSize: 13),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(20.0),
                                      child: Text(
                                        '+ ' +
                                            NumberFormat.currency(
                                                    locale: 'id',
                                                    symbol: 'Rp',
                                                    decimalDigits: 0)
                                                .format(
                                              transactionData['ongkir'],
                                            ),
                                        style: GoogleFonts.mavenPro(
                                          fontSize: 13,
                                          color: Colors.blue,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            )
                          : Container(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: EdgeInsets.all(20.0),
                            child: Text('Total : '),
                          ),
                          Padding(
                            padding: EdgeInsets.all(20.0),
                            child: Text(
                              NumberFormat.currency(
                                      locale: 'id',
                                      symbol: 'Rp',
                                      decimalDigits: 0)
                                  .format(
                                transactionData['totalPrice2'],
                              ),
                              style: GoogleFonts.mavenPro(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      transactionData['address'] == '' ||
                              transactionData['address'] == null
                          ? Container()
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                subHeading('Alamat Pengiriman'),
                                Padding(
                                  padding: EdgeInsets.all(20.0),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.location_on,
                                        color: Colors.red[400],
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Expanded(
                                        child: Text(
                                          transactionData['address'],
                                          style: TextStyle(
                                              fontSize: 13,
                                              height: 1.5,
                                              color: Colors.black45),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                      transactionData['note'] == '' ||
                              transactionData['note'] == null
                          ? Container()
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                subHeading('Catatan Pembelian'),
                                Padding(
                                  padding:
                                      EdgeInsets.only(left: 15.0, bottom: 20),
                                  child: Text(
                                    transactionData['note'],
                                    style: GoogleFonts.roboto(
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                      subHeading('Pembayaran'),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(left: 20.0, top: 10),
                            child: Text(
                              'Nama Pembeli : ',
                              style: GoogleFonts.roboto(),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(right: 20.0, top: 10),
                            child: Text(transactionData['username'],
                                style: GoogleFonts.roboto()),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(left: 20.0, top: 10),
                            child: Text(
                              'Nomor HP : ',
                              style: GoogleFonts.roboto(),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(right: 20.0, top: 10),
                            child: Text(transactionData['noHP'],
                                style: GoogleFonts.roboto()),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(left: 20.0, top: 10),
                            child: Text(
                              'Waktu pembelian : ',
                              style: GoogleFonts.roboto(),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(right: 20.0, top: 10),
                            child: Text(
                              transactionDate,
                              style: GoogleFonts.roboto(),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(left: 20.0, top: 10),
                            child: Text(
                              'Metode Pembayaran : ',
                              style: GoogleFonts.roboto(),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(right: 20.0, top: 10),
                            child: Text(
                              transactionData['metode'],
                              style: GoogleFonts.roboto(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(left: 20.0, top: 10),
                            child: Text(
                              'Status Transaksi : ',
                              style: GoogleFonts.roboto(),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(right: 20.0, top: 10),
                            child: Text(
                              transactionData['status'],
                              style: GoogleFonts.roboto(
                                fontWeight: FontWeight.bold,
                                color: transactionData['status'] == 'Selesai' ||
                                        transactionData['status'] ==
                                            'Pembayaran Lunas'
                                    ? Colors.green
                                    : transactionData['status'] ==
                                                'Menunggu konfirmasi' ||
                                            transactionData['status'] ==
                                                'Menunggu Pelunasan'
                                        ? Colors.orange
                                        : transactionData['status'] ==
                                                    'Dibatalkan' ||
                                                transactionData['status'] ==
                                                    'Ditolak' ||
                                                transactionData['status'] ==
                                                    'Expired'
                                            ? Colors.red[200]
                                            : Colors.blue,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      transactionData['status'] == 'Ditolak'
                          ? Column(
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(left: 20.0, top: 10),
                                  child: Text(
                                    'Pesan ditolak : ',
                                    style: GoogleFonts.roboto(),
                                  ),
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                Padding(
                                  padding: EdgeInsets.only(left: 20.0, top: 10),
                                  child: Text(
                                    transactionData['cancelMessage'],
                                    style: TextStyle(
                                      fontStyle: FontStyle.italic,
                                      color: Colors.black45,
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : transactionData['status'] == 'Menunggu konfirmasi'
                              ? GestureDetector(
                                  onTap: () => showDialog(widget.transactionId),
                                  child: Container(
                                    margin: EdgeInsets.all(20),
                                    height: 50,
                                    width: MediaQuery.of(context).size.width,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: secondaryColor,
                                    ),
                                    child: Center(
                                      child: Text(
                                        'Batalkan Pesanan',
                                        style: GoogleFonts.roboto(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              : transactionData['status'] ==
                                      'Menunggu Pembayaran'
                                  ? Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        ConstrainedBox(
                                          constraints: BoxConstraints.tightFor(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.4,
                                          ),
                                          child: ElevatedButton(
                                            onPressed: () {
                                              showDialog(widget.transactionId);
                                            },
                                            style: ElevatedButton.styleFrom(
                                                primary: Colors.white,
                                                elevation: 0.3,
                                                side: BorderSide(
                                                  width: 1.0,
                                                  color: Colors.black12,
                                                )),
                                            child: Text(
                                              'Batalkan',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.black54,
                                              ),
                                            ),
                                          ),
                                        ),
                                        ConstrainedBox(
                                          constraints: BoxConstraints.tightFor(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.4,
                                          ),
                                          child: ElevatedButton(
                                            onPressed: () {
                                              navigateToPaymentOption();
                                            },
                                            style: ElevatedButton.styleFrom(
                                              primary: primaryColor,
                                            ),
                                            child: Text(
                                              'Bayar',
                                              style: TextStyle(fontSize: 12),
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                  : transactionData['status'] ==
                                          'Menunggu Pelunasan'
                                      ? Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            ConstrainedBox(
                                              constraints:
                                                  BoxConstraints.tightFor(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.4,
                                              ),
                                              child: ElevatedButton(
                                                onPressed: () {
                                                  showDialog(
                                                      widget.transactionId);
                                                },
                                                style: ElevatedButton.styleFrom(
                                                    primary: Colors.white,
                                                    elevation: 0.3,
                                                    side: BorderSide(
                                                      width: 1.0,
                                                      color: Colors.black12,
                                                    )),
                                                child: Text(
                                                  'Batalkan',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.black54,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            ConstrainedBox(
                                              constraints:
                                                  BoxConstraints.tightFor(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.4,
                                              ),
                                              child: ElevatedButton(
                                                onPressed: () {
                                                  if (transactionData[
                                                          'metode'] ==
                                                      'Gopay') {
                                                    navigateToGopayStatus(
                                                        transactionData[
                                                            'midtransId']);
                                                  } else {
                                                    navigateToBankTransferStatus(
                                                        transactionData[
                                                            'midtransId']);
                                                  }
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  primary: primaryColor,
                                                ),
                                                child: Text(
                                                  'Lihat status',
                                                  style:
                                                      TextStyle(fontSize: 12),
                                                ),
                                              ),
                                            ),
                                          ],
                                        )
                                      : Container(),
                      SizedBox(
                        height: 20,
                      ),
                      transactionData['status'] == 'Sedang Mengirim'
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                subHeading('Pengiriman'),
                                FutureBuilder(
                                  future: FirebaseFirestore.instance
                                      .collection('delivery')
                                      .where('transaction_id',
                                          isEqualTo: widget.transactionId)
                                      .get(),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return LinearProgressIndicator();
                                    } else {
                                      var data = snapshot.data.docs;
                                      QueryDocumentSnapshot
                                          queryDocumentSnapshot = data[0];

                                      Map map = queryDocumentSnapshot.data();

                                      return Padding(
                                        padding: EdgeInsets.only(left: 18.0),
                                        child: Text(map['status_pengiriman ']),
                                      );
                                    }
                                  },
                                ),
                              ],
                            )
                          : Container(),
                      SizedBox(
                        height: 30,
                      ),
                    ],
                  ),
                ),
              );
            }
          },
        ),
      ),
    );
  }

  //WIDGET
  Widget listItem(transactionDataLength, transactionData) {
    itemDetails = [];
    itemDetails.add({
      "id": 'ONGKIR',
      "price": transactionData['ongkir'],
      "quantity": 1,
      "name": 'ONGKIR',
    });

    return ListView.builder(
      shrinkWrap: true,
      physics: ClampingScrollPhysics(),
      itemCount: transactionDataLength,
      itemBuilder: (context, index) => StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('product')
            .doc(transactionData['itemList'][index])
            .snapshots(),
        builder: (context, productSnapshot) {
          if (productSnapshot.connectionState == ConnectionState.waiting) {
            return Container();
          } else {
            return StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('transaction')
                  .doc(widget.transactionId)
                  .snapshots(),
              builder: (context, transactionSnapshot) {
                if (transactionSnapshot.connectionState ==
                    ConnectionState.waiting) {
                  return Center(
                    child: Container(),
                  );
                } else {
                  if (!itemDetails.contains({
                    "id": productSnapshot.data.id,
                    "price": transactionSnapshot.data['itemBasePrice'][index],
                    "quantity": transactionData['ListQty2'][index],
                    "name": productSnapshot.data['nama'],
                  })) {
                    // item
                    itemDetails.add({
                      "id": productSnapshot.data.id,
                      "price": transactionSnapshot.data['itemBasePrice'][index],
                      "quantity": transactionData['ListQty2'][index],
                      "name": productSnapshot.data['nama'],
                    });
                  }

                  return Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(10.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Container(
                                height: 60,
                                width: 60,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.network(
                                    productSnapshot.data['url'],
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Text(
                                  productSnapshot.data['nama'],
                                  style: GoogleFonts.roboto(
                                    height: 2,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(left: 30.0),
                                child: Text(
                                  'x' +
                                      transactionData['ListQty2'][index]
                                          .toString(),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                NumberFormat.currency(
                                        locale: 'id',
                                        symbol: 'Rp',
                                        decimalDigits: 0)
                                    .format(
                                  transactionSnapshot.data['itemBasePrice']
                                          [index] *
                                      transactionData['ListQty2'][index],
                                ),
                                style: GoogleFonts.mavenPro(fontSize: 15),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Divider(
                        indent: 20,
                        endIndent: 20,
                        color: fourthColor,
                      ),
                    ],
                  );
                }
              },
            );
          }
        },
      ),
    );
  }

  Widget subHeading(String subHeading) {
    return Row(
      children: [
        Container(
          margin: EdgeInsets.fromLTRB(15, 15, 5, 15),
          child: Text(
            subHeading,
            style:
                GoogleFonts.openSans(fontSize: 15, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  navigateToDetailPage() {
    Navigator.pop(context);
    widget.refresh();
  }

  navigateToPaymentOption() {
    Navigator.push(
        context,
        PageTransition(
            type: PageTransitionType.rightToLeft,
            child: PaymentOption(
              transactionId: widget.transactionId,
              itemDetails: itemDetails,
              grossAmount: grossAmount,
            )));
  }

  navigateToGopayStatus(String midtransId) {
    Navigator.push(
        context,
        PageTransition(
            type: PageTransitionType.rightToLeft,
            child: GopayStatusPage(
              transactionId: widget.transactionId,
              itemDetails: itemDetails,
              grossAmount: grossAmount,
              midtransId: midtransId,
            )));
  }

  navigateToBankTransferStatus(String midtransId) {
    Navigator.push(
        context,
        PageTransition(
            type: PageTransitionType.rightToLeft,
            child: BankPaymentStatusPage(
              transactionId: widget.transactionId,
              itemDetails: itemDetails,
              grossAmount: grossAmount,
              midtransId: midtransId,
            )));
  }

  void checking(var data, String transactionId) {
    // FirebaseFirestore.instance.collection('collectionPath')
    print('midtrans id : ' + data['midtransId']);

    FirebaseFirestore.instance
        .collection('midtrans')
        .where('midtransId', isEqualTo: data['midtransId'])
        .get()
        .then((value) {
      DateTime expiredTime =
          DateTime.parse(value.docs[0]['expired_time'].toDate().toString());

      if (!expiredTime.isAfter(DateTime.now())) {
        DatabaseServices.setExpireTransactionStatus(transactionId);
      }
    });
  }

  //FUNCTION
  void showDialog(String transactionId) {
    showGeneralDialog(
      barrierLabel: "Cancel Order",
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: Duration(milliseconds: 500),
      context: context,
      pageBuilder: (_, __, ___) {
        return Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            height: MediaQuery.of(context).size.height / 3.66,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              color: Colors.white,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Batalkan Pesanan ini?',
                  style: GoogleFonts.roboto(
                      fontSize: 16,
                      color: Colors.black,
                      decoration: TextDecoration.none),
                ),
                SizedBox(
                  height: 30,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        height: MediaQuery.of(context).size.height / 14.64,
                        width: MediaQuery.of(context).size.width / 3.2,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.black54),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            'Tidak',
                            style: GoogleFonts.roboto(
                              fontSize: 15,
                              decoration: TextDecoration.none,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => context
                          .read<TransactionlistCubit>()
                          .cancelOrder(transactionId),
                      child: Container(
                        height: MediaQuery.of(context).size.height / 14.64,
                        width: MediaQuery.of(context).size.width / 3.2,
                        decoration: BoxDecoration(
                          color: secondaryColor,
                          border: Border.all(color: Colors.white),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            'Ya',
                            style: GoogleFonts.roboto(
                              fontSize: 15,
                              decoration: TextDecoration.none,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        );
      },
      transitionBuilder: (_, anim, __, child) {
        return SlideTransition(
          position: Tween(begin: Offset(0, 1), end: Offset(0, 0)).animate(anim),
          child: child,
        );
      },
    );
  }
}
