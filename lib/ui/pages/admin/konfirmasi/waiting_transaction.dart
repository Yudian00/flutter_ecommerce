import 'package:flutter/material.dart';
import 'package:flutter_ecommerce/ui/widgets/adminWidget/waiting_list.dart';

import 'package:google_fonts/google_fonts.dart';

class WaitingTransaction extends StatefulWidget {
  final List transactionIdList;
  final String metode;

  WaitingTransaction({
    @required this.transactionIdList,
    @required this.metode,
  });

  @override
  _WaitingTransactionState createState() => _WaitingTransactionState();
}

class _WaitingTransactionState extends State<WaitingTransaction> {
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
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          'Pesanan Menunggu',
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
      body: WaitingList(
        metode: widget.metode,
      ),
    );
  }
}
