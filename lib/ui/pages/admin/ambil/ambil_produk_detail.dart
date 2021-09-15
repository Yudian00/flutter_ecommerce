import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ecommerce/repositories/DatabaseServices.dart';
import 'package:flutter_ecommerce/utils/color_codes.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class DetailTakeOrder extends StatefulWidget {
  final snapshot;

  DetailTakeOrder({
    @required this.snapshot,
  });

  @override
  _DetailTakeOrderState createState() => _DetailTakeOrderState();
}

class _DetailTakeOrderState extends State<DetailTakeOrder> {
  Map itemData = {};
  DocumentSnapshot docId;
  void initState() {
    super.initState();
    docId = widget.snapshot;

    for (var i = 0; i < widget.snapshot['itemList'].length; i++) {
      itemData.putIfAbsent(
          widget.snapshot['itemList'][i], () => widget.snapshot['ListQty2'][i]);
    }
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
            color: Colors.black,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
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
        // shrinkWrap: true,
        // physics: ClampingScrollPhysics(),
        children: [
          SizedBox(
            height: 20,
          ),
          transactionData(),
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
                          locale: 'id', symbol: 'Rp', decimalDigits: 0)
                      .format(
                    widget.snapshot['totalPrice2'],
                  ),
                  style: GoogleFonts.mavenPro(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
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
                        widget.snapshot['note'],
                        style: GoogleFonts.roboto(
                          fontStyle: FontStyle.italic,
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
                  style: GoogleFonts.roboto(),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(right: 20.0, top: 10),
                child: Text(widget.snapshot['username'],
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
                child:
                    Text(widget.snapshot['noHP'], style: GoogleFonts.roboto()),
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
                  'Status : ',
                  style: GoogleFonts.roboto(),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(right: 20.0, top: 10),
                child: Text(
                  widget.snapshot['status'],
                  style: GoogleFonts.roboto(
                    fontWeight: FontWeight.bold,
                    color: widget.snapshot['status'] == 'Selesai'
                        ? Colors.green
                        : widget.snapshot['status'] == 'Menunggu konfirmasi'
                            ? Colors.orange
                            : widget.snapshot['status'] == 'Dibatalkan'
                                ? Colors.red
                                : primaryColor,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(
            height: 30,
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.all(20),
              child: ElevatedButton(
                onPressed: () => confirmOrder(context),
                style: ElevatedButton.styleFrom(primary: primaryColor),
                child: Center(
                  child: Text(
                    'Pesanan Selesai',
                    style: GoogleFonts.roboto(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 50,
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
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Container();
            } else {
              var product = snapshot.data;

              //  calculate a new price after discount
              var discountPrice = int.parse(product['harga']) *
                  product['discount_percent'] /
                  100;
              var discount = int.parse(product['harga']) - discountPrice;
              var newPrice2 = discount.toInt();

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
                                snapshot.data['url'],
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Text(
                              snapshot.data['nama'],
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
                                  widget.snapshot['ListQty2'][index].toString(),
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
                              newPrice2 * widget.snapshot['ListQty2'][index],
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

  confirmOrder(BuildContext context) {
    // set up the buttons
    Widget cancelButton = TextButton(
      child: Text(
        "Tidak",
        style: TextStyle(
          color: Colors.black45,
          fontSize: 12,
        ),
      ),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    Widget continueButton = TextButton(
      child: Container(
        height: 40,
        width: 100,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: primaryColor,
        ),
        child: Center(
          child: Text(
            "Selesaikan",
            style: TextStyle(
              fontSize: 12,
              color: Colors.white,
            ),
          ),
        ),
      ),
      onPressed: () {
        Navigator.pop(context);
        Navigator.pop(context);
        Navigator.pop(context);

        DatabaseServices.finishOrder(
            widget.snapshot.id, itemData, widget.snapshot, showErrorSnackbar);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      content: Text("Selesaikan pesanan?"),
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

  showAlert(BuildContext context) {
    // set up the buttons
    Widget cancelButton = TextButton(
      child: Text(
        "Ok",
        style: TextStyle(
          color: Colors.black45,
        ),
      ),
      onPressed: () {
        Navigator.pop(context);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Oops!"),
      content: Text("Tandai foto yang ingin dihapus terlebih dahulu"),
      actions: [
        cancelButton,
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

  void showErrorSnackbar() {
    final snackBar = SnackBar(
      content: Text('Stok barang tidak cukup'),
      backgroundColor: Colors.red[300],
    );

// Find the ScaffoldMessenger in the widget tree
// and use it to show a SnackBar.
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
