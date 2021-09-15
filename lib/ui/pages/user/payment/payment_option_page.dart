import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ecommerce/ui/pages/user/payment/bank_transfer/bank_transfer_process_page.dart';
import 'package:flutter_ecommerce/ui/pages/user/payment/gopay/gopay_process_payment_page.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';

class PaymentOption extends StatefulWidget {
  final String transactionId;
  final List itemDetails;
  final int grossAmount;
  PaymentOption({
    @required this.transactionId,
    @required this.itemDetails,
    @required this.grossAmount,
  });

  @override
  _PaymentOptionState createState() => _PaymentOptionState();
}

class _PaymentOptionState extends State<PaymentOption> {
  Map customerDetails = {};
  void initState() {
    super.initState();
  }

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
          'Opsi Pembayaran',
          style: GoogleFonts.roboto(
            fontWeight: FontWeight.w500,
            fontSize: 16,
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
      body: FutureBuilder(
        future: FirebaseFirestore.instance
            .collection('user')
            .doc(FirebaseAuth.instance.currentUser.uid)
            .get()
            .then((value) {
          customerDetails = {
            "email": value['email'],
            "first_name": value['username'],
            "last_name": "",
            "phone": value['noHP']
          };
        }),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else {
            return ListView(
              children: [
                SizedBox(
                  height: 15,
                ),
                ListTile(
                  onTap: () => showBRIDialog(context),
                  leading: Container(
                    margin: EdgeInsets.only(left: 10),
                    height: 100,
                    width: 100,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(
                          'assets/images/brivia.png',
                        ),
                        fit: BoxFit.fitWidth,
                      ),
                    ),
                  ),
                  title: Text(
                    'BRI Virtual Account',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  subtitle: Text(
                    'Transfer melalui BRI Virtual Account',
                    style: TextStyle(
                      color: Colors.black45,
                      fontSize: 11,
                    ),
                  ),
                ),
                Divider(),
                ListTile(
                  onTap: () => showBCADialog(context),
                  leading: Container(
                    margin: EdgeInsets.only(left: 10),
                    height: 100,
                    width: 100,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(
                          'assets/images/bank BCA.png',
                        ),
                        fit: BoxFit.fitWidth,
                      ),
                    ),
                  ),
                  title: Text(
                    'BCA Virtual Account',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  subtitle: Text(
                    'Transfer melalui BCA Virtual Account',
                    style: TextStyle(
                      color: Colors.black45,
                      fontSize: 11,
                    ),
                  ),
                ),
                Divider(),
                ListTile(
                  onTap: () => showGopayDialog(context),
                  leading: Container(
                    margin: EdgeInsets.only(left: 10),
                    height: 100,
                    width: 100,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(
                          'assets/images/logo-gopay-vector.png',
                        ),
                        fit: BoxFit.fitWidth,
                      ),
                    ),
                  ),
                  title: Text(
                    'Gopay',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  subtitle: Text(
                    'gunakan saldo gopay untuk melakukan pembayaran',
                    style: TextStyle(
                      color: Colors.black45,
                      fontSize: 11,
                    ),
                  ),
                ),
                Divider(),
              ],
            );
          }
        },
      ),
    );
  }

  void payWithGoPay() {
    DateTime currentTime = DateTime.now(); //DateTime
    Timestamp timestamp = Timestamp.fromDate(currentTime);
    Map data = {
      "payment_type": "gopay",
      "transaction_details": {
        "gross_amount": widget.grossAmount,
        "order_id": "order-101c-" + timestamp.seconds.toString(),
      },
      "customer_details": customerDetails,
      "item_details": widget.itemDetails,
    };

    Navigator.pushReplacement(
      context,
      PageTransition(
        type: PageTransitionType.rightToLeft,
        child: GopayProcessPaymentPage(
          data: data,
          transactionId: widget.transactionId,
        ),
      ),
    );
  }

  showGopayDialog(BuildContext context) {
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
        "Pilih",
        style: TextStyle(
          color: Colors.blue,
        ),
      ),
      onPressed: () {
        Navigator.pop(context);
        Navigator.pop(context);
        payWithGoPay();
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Gopay"),
      content: Text(
        "Pilih gopay sebagai media pembayaran?",
        style: TextStyle(
          height: 1.5,
          fontSize: 12,
        ),
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

  showBCADialog(BuildContext context) {
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
        "Pilih",
        style: TextStyle(
          color: Colors.blue,
        ),
      ),
      onPressed: () {
        Navigator.pop(context);
        Navigator.pop(context);
        payWithBankTransfer('bca');
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("BCA Virtual Account"),
      content: Text(
        "Pilih BCA sebagai media pembayaran?",
        style: TextStyle(
          height: 1.5,
          fontSize: 12,
        ),
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

  showBRIDialog(BuildContext context) {
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
        "Pilih",
        style: TextStyle(
          color: Colors.blue,
        ),
      ),
      onPressed: () {
        Navigator.pop(context);
        Navigator.pop(context);
        payWithBankTransfer('bri');
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("BRI Virtual Account"),
      content: Text(
        "Pilih BRI sebagai media pembayaran?",
        style: TextStyle(
          height: 1.5,
          fontSize: 12,
        ),
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

  payWithBankTransfer(String bank) {
    DateTime currentTime = DateTime.now(); //DateTime
    Timestamp timestamp = Timestamp.fromDate(currentTime);
    Map data = {
      "payment_type": 'bank_transfer',
      "bank_transfer": {
        "bank": bank,
      },
      "transaction_details": {
        "gross_amount": widget.grossAmount,
        "order_id": "order-101c-" + timestamp.seconds.toString(),
      },
      "customer_details": customerDetails,
      "item_details": widget.itemDetails,
    };

    Navigator.pushReplacement(
      context,
      PageTransition(
        type: PageTransitionType.rightToLeft,
        child: BankTransferProcess(
          bank: bank,
          data: data,
          transactionId: widget.transactionId,
        ),
      ),
    );
  }
}
