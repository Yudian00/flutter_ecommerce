import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ecommerce/repositories/DatabaseServices.dart';
import 'package:flutter_ecommerce/repositories/DatabaseUser.dart';
import 'package:flutter_ecommerce/repositories/NotificationFCM.dart';
import 'package:flutter_ecommerce/ui/pages/admin/lunas/payment_delivery_detail.dart';
import 'package:flutter_ecommerce/utils/color_codes.dart';
import 'package:flutter_ecommerce/utils/mediaQuery.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';

class DetailOrder extends StatefulWidget {
  final snapshot;

  DetailOrder({
    @required this.snapshot,
  });

  @override
  _DetailOrderState createState() => _DetailOrderState();
}

class _DetailOrderState extends State<DetailOrder> {
  DocumentSnapshot docId;
  bool isOutofStock = false;
  Map stokProductList = {};
  TextEditingController ongkirController = TextEditingController();
  List productIdList = [];
  num ongkir = 0;
  num totalPrice = 0;

  void initState() {
    super.initState();
    docId = widget.snapshot;
    ongkirController.text = widget.snapshot['ongkir'].toString();
    totalPrice = widget.snapshot['totalPrice2'];
  }

  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var date = DateTime.parse(widget.snapshot['created'].toDate().toString());

    // var date = new DateTime.now();
    var formatter = DateFormat('dd-MM-yyyy kk:mm');
    String transactionDate = formatter.format(date);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          'Detail Pesanan',
          style: GoogleFonts.roboto(
              color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 14),
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.black,
          ),
        ),
      ),
      body: ListView(
        children: [
          transactionData(),
          widget.snapshot['metode'] == 'Transfer'
              ? widget.snapshot['status'] == 'Menunggu konfirmasi'
                  ? ongkirController.text == '0'
                      ? Padding(
                          padding: const EdgeInsets.only(
                            left: 20,
                            top: 20,
                          ),
                          child: GestureDetector(
                            onTap: () {
                              addDeliveryFee(context);
                            },
                            child: Row(
                              children: [
                                Icon(
                                  Icons.add,
                                  color: Colors.blue,
                                  size: 15,
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Container(
                                  child: Center(
                                    child: Text(
                                      'Tambahkan Ongkos Kirim',
                                      style: TextStyle(
                                          color: Colors.blue, fontSize: 13),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : Padding(
                          padding: const EdgeInsets.only(
                            left: 20,
                            top: 20,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Biaya Ongkir : ',
                                style: TextStyle(
                                  fontSize: 13,
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(right: 20.0),
                                child: Text(
                                  '+ ' +
                                      NumberFormat.currency(
                                              locale: 'id',
                                              symbol: 'Rp',
                                              decimalDigits: 0)
                                          .format(
                                        int.parse(ongkirController.text),
                                      ),
                                  style: TextStyle(
                                    color: Colors.blue,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                  : Container()
              : Container(),
          SizedBox(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: EdgeInsets.all(20.0),
                child: Text('Total : '),
              ),
              Padding(
                padding: EdgeInsets.all(20.0),
                child: widget.snapshot['status'] == 'Menunggu Pembayaran'
                    ? Text(
                        NumberFormat.currency(
                                locale: 'id', symbol: 'Rp', decimalDigits: 0)
                            .format(
                          widget.snapshot['totalPrice2'],
                        ),
                        style: GoogleFonts.mavenPro(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : ongkirController.text == '0'
                        ? Text(
                            NumberFormat.currency(
                                    locale: 'id',
                                    symbol: 'Rp',
                                    decimalDigits: 0)
                                .format(
                              widget.snapshot['totalPrice2'],
                            ),
                            style: GoogleFonts.mavenPro(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : Text(
                            NumberFormat.currency(
                                    locale: 'id',
                                    symbol: 'Rp',
                                    decimalDigits: 0)
                                .format(
                              widget.snapshot['totalPrice2'] +
                                  int.parse(ongkirController.text),
                            ),
                            style: GoogleFonts.mavenPro(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
              ),
            ],
          ),
          widget.snapshot['note'] != '' || widget.snapshot['note'] != null
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    subHeading('Catatan Pembelian'),
                    Padding(
                      padding: EdgeInsets.only(left: 15.0, bottom: 20),
                      child: Text(
                        widget.snapshot['note'] == ''
                            ? '(kosong)'
                            : widget.snapshot['note'],
                        style: GoogleFonts.roboto(
                          fontStyle: FontStyle.italic,
                          color: Colors.black38,
                        ),
                      ),
                    ),
                  ],
                )
              : Container(
                  child: Text(
                    '-',
                    style: GoogleFonts.roboto(
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
          subHeading('Pembayaran'),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: EdgeInsets.only(left: 20.0, top: 10),
                child: Text(
                  'Nama Pembeli : ',
                  style: GoogleFonts.roboto(color: Colors.black45),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(right: 20.0, top: 10),
                child: Text(widget.snapshot['username'],
                    style: GoogleFonts.roboto(color: Colors.black45)),
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
                  style: GoogleFonts.roboto(color: Colors.black45),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(right: 20.0, top: 10),
                child: Text(widget.snapshot['noHP'],
                    style: GoogleFonts.roboto(color: Colors.black45)),
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
                  style: GoogleFonts.roboto(color: Colors.black45),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(right: 20.0, top: 10),
                child: Text(
                  transactionDate,
                  style: GoogleFonts.roboto(color: Colors.black45),
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
                  'Metode Pembayaran: ',
                  style: GoogleFonts.roboto(color: Colors.black45),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(right: 20.0, top: 10),
                child: Text(
                  widget.snapshot['metode'],
                  style: GoogleFonts.roboto(
                    color: Colors.black45,
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
                  'Status : ',
                  style: GoogleFonts.roboto(color: Colors.black45),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(right: 20.0, top: 10),
                child: Text(
                  widget.snapshot['status'],
                  style: GoogleFonts.roboto(
                    fontWeight: FontWeight.bold,
                    color: widget.snapshot['status'] == 'Selesai' ||
                            widget.snapshot['status'] == 'Pembayaran Lunas'
                        ? Colors.green
                        : widget.snapshot['status'] == 'Menunggu konfirmasi'
                            ? Colors.orange
                            : widget.snapshot['status'] == 'Dibatalkan' ||
                                    widget.snapshot['status'] == 'Expired'
                                ? Colors.red
                                : Colors.blue,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(
            height: 10,
          ),
          widget.snapshot['address'] == null || widget.snapshot['address'] == ''
              ? Container()
              : Column(
                  children: [
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
                              widget.snapshot['address'],
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
          SizedBox(
            height: 20,
          ),
          widget.snapshot['status'] == 'Ditolak'
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(left: 20.0, top: 10),
                        child: Text(
                          'Pesan ditolak : ',
                          style: GoogleFonts.roboto(),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Padding(
                      padding: EdgeInsets.only(right: 20.0, top: 10),
                      child: Text(
                        widget.snapshot['cancelMessage'],
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          color: Colors.black45,
                        ),
                      ),
                    ),
                  ],
                )
              : widget.snapshot['status'] == 'Menunggu konfirmasi'
                  ? Align(
                      alignment: Alignment.bottomCenter,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.all(20),
                              child: GestureDetector(
                                onTap: () => cancelOrderAlert(context),
                                child: Container(
                                  height: getCurrentHeight(context, 50),
                                  width:
                                      MediaQuery.of(context).size.width * 0.4,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border.all(color: Colors.red),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Center(
                                    child: Text(
                                      'Tolak Pesanan',
                                      style: GoogleFonts.roboto(
                                        color: Colors.red,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.all(20),
                              child: GestureDetector(
                                onTap: () => confirmOrder(
                                    context, widget.snapshot['metode']),
                                child: Container(
                                  height: getCurrentHeight(context, 50),
                                  width:
                                      MediaQuery.of(context).size.width * 0.4,
                                  decoration: BoxDecoration(
                                    color: adminMainColor,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Center(
                                    child: Text(
                                      'Proses',
                                      style: GoogleFonts.roboto(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : widget.snapshot['status'] == 'Pembayaran Lunas'
                      ? Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                PageTransition(
                                  type: PageTransitionType.rightToLeft,
                                  child: DeliveryDetail(
                                    transactionId: docId.id,
                                  ),
                                ),
                              );
                            },
                            style:
                                ElevatedButton.styleFrom(primary: Colors.green),
                            child: Text(
                              'Proses ke Pengiriman',
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                        )
                      : Container(),
          SizedBox(
            height: 20,
          ),
        ],
      ),
    );
  }

  Widget transactionData() {
    return ListView.builder(
      shrinkWrap: true,
      physics: ClampingScrollPhysics(),
      itemCount: widget.snapshot['itemList'].length,
      itemBuilder: (context, index) {
        return StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('product')
              .doc(widget.snapshot['itemList'][index])
              .snapshots(),
          builder: (context, productSnapshot) {
            if (productSnapshot.connectionState == ConnectionState.waiting) {
              return Container();
            } else {
              var product = productSnapshot.data;

              stokProductList.putIfAbsent(
                  product.id, () => product['stok barang']);

              if (!productIdList.contains(product.id)) {
                productIdList.add(product.id);
              }

              return StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('transaction')
                    .doc(docId.id)
                    .snapshots(),
                builder: (context, transactionSnapshot) {
                  if (transactionSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return Center(
                      child: Container(),
                    );
                  } else {
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
                                  foregroundDecoration:
                                      productSnapshot.data['status'] ==
                                              'DELETED'
                                          ? BoxDecoration(
                                              color: Colors.grey,
                                              backgroundBlendMode:
                                                  BlendMode.saturation,
                                            )
                                          : BoxDecoration(),
                                  child: Image.network(
                                    productSnapshot.data['url'],
                                    fit: BoxFit.cover,
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
                                        widget.snapshot['ListQty2'][index]
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
                                        widget.snapshot['ListQty2'][index],
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
                        SizedBox(
                          height: 10,
                        ),
                      ],
                    );
                  }
                },
              );
            }
          },
        );
      },
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

  cancelOrderAlert(BuildContext context) {
    var cancelMessage;
    final _formKey = GlobalKey<FormState>();
    TextEditingController cancelMessageController = TextEditingController();
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text('Batalkan Pesanan'),
      content: Container(
        height: MediaQuery.of(context).size.height * 0.1,
        width: MediaQuery.of(context).size.width,
        child: Form(
          key: _formKey,
          child: Center(
            child: TextFormField(
              decoration: InputDecoration(
                hintText: 'Alasan Pembatalan',
                hintStyle: TextStyle(
                  color: Colors.black38,
                  fontSize: 13,
                ),
              ),
              controller: cancelMessageController,
              validator: (value) {
                if (value.isEmpty) {
                  return 'Pesan tidak boleh kosong';
                }
                return null;
              },
              onFieldSubmitted: (value) {
                setState(() {
                  cancelMessage = value;
                });
              },
            ),
          ),
        ),
      ),
      actionsPadding: EdgeInsets.symmetric(horizontal: 30),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Center(
            child: Text(
              "Tidak",
              style:
                  TextStyle(color: Colors.black38, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        TextButton(
          onPressed: () {
            if (_formKey.currentState.validate()) {
              DatabaseServices.adminCancelOrder(docId.id, cancelMessage);
              Navigator.pop(context);
              Navigator.pop(context);
              Fluttertoast.showToast(msg: 'Pesanan sudah ditolak');
            } else {
              return null;
            }
          },
          child: Center(
            child: Text(
              "Ya",
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Container(child: alert);
      },
    );
  }

  confirmOrder(BuildContext context, String metode) {
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text('Proses Pesanan?'),
      content: metode == 'Transfer'
          ? Text(
              'Pesanan akan diproses dengan ongkir yang sudah ditentukan?',
              style: TextStyle(
                fontSize: 13,
                height: 1.5,
              ),
            )
          : Text(
              'Pesanan yang sudah diproses akan dapat diambil di toko.',
              style: TextStyle(
                fontSize: 13,
                height: 1.5,
              ),
            ),
      actionsPadding: EdgeInsets.symmetric(horizontal: 30),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Center(
            child: Text(
              "Tidak",
              style:
                  TextStyle(color: Colors.black38, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        TextButton(
          onPressed: () {
            submit(metode);
          },
          child: Container(
            child: Center(
              child: Text(
                "Ya",
                style:
                    TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Container(child: alert);
      },
    );
  }

  addDeliveryFee(BuildContext context) {
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text('Tambah Ongkir'),
      content: Container(
        height: MediaQuery.of(context).size.height * 0.1,
        width: MediaQuery.of(context).size.width,
        child: Center(
          child: TextField(
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
            decoration: InputDecoration(
              hintText: 'Tambahkan ongkir',
              hintStyle: TextStyle(
                color: Colors.black38,
                fontSize: 13,
              ),
            ),
            controller: ongkirController,
          ),
        ),
      ),
      actionsPadding: EdgeInsets.symmetric(horizontal: 10),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Center(
            child: Text(
              "Batalkan",
              style:
                  TextStyle(color: Colors.black38, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            if (ongkirController.text == '0') {
              Fluttertoast.showToast(msg: 'Tidak ada penambahan ongkir');
            } else {
              Fluttertoast.showToast(msg: 'Telah menambahkan ongkir');
            }
          },
          child: Center(
            child: Text(
              "Tambah",
              style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Container(child: alert);
      },
    );
  }

  void showInSnackBar() {
    final snackBar = SnackBar(
      content: Text('Stok barang tidak cukup'),
      backgroundColor: Colors.red,
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void submit(String metode) {
    for (var i = 0; i < widget.snapshot['itemList'].length; i++) {
      print('stok produk ' + stokProductList[productIdList[i]].toString());

      print(widget.snapshot['ListQty2'][i]);
      int sisaBarang =
          stokProductList[productIdList[i]] - widget.snapshot['ListQty2'][i];

      if (sisaBarang.isNegative) {
        setState(() {
          isOutofStock = true;
        });
      }
    }

    if (isOutofStock) {
      showInSnackBar();
    } else {
      DatabaseUser.getUserToken(widget.snapshot['userId2']).then((value) {
        // get device token first for Notification FCM
        Map<String, dynamic> data = value.data();
        String deviceToken = data['token'];

        NotificationFCM.setNotificationFCM(
          deviceToken,
          titleMessage: 'Order Confirm',
          bodyMessage: 'Pesanan kamu sudah dikonfirmasi',
        );

        // database service
        Fluttertoast.showToast(msg: 'Pesanan sudah diproses');
        DatabaseServices.adminConfirmOrder(
          docId.id,
          metode,
          widget.snapshot['totalPrice2'] + int.parse(ongkirController.text),
          int.parse(ongkirController.text),
          widget.snapshot['itemList'],
          stokProductList,
          widget.snapshot['ListQty2'],
        );

        Navigator.pop(context);
      });
    }

    Navigator.pop(context);
  }
}
