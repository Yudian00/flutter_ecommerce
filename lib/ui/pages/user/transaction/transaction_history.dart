import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:entry/entry.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ecommerce/repositories/user_repository.dart';
import 'package:flutter_ecommerce/ui/pages/user/transaction/transactionDetail.dart';
import 'package:flutter_ecommerce/utils/color_codes.dart';
import 'package:flutter_ecommerce/utils/widget_utils.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';

class TransactionHistory extends StatefulWidget {
  final String userId;
  final User user;
  final UserRepository userRepository;

  TransactionHistory({
    @required this.userId,
    @required this.user,
    @required this.userRepository,
  });

  @override
  _TransactionHistoryState createState() => _TransactionHistoryState();
}

class _TransactionHistoryState extends State<TransactionHistory> {
  List transactionIdList = [];

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
        iconTheme: IconThemeData(
          color: thirdColor, //change your color here
        ),
        elevation: 1.0,
        title: Text(
          'Riwayat Transaksi ',
          style: GoogleFonts.roboto(
            fontWeight: FontWeight.w500,
            fontSize: 16,
            color: Colors.black87,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            size: 16,
            color: thirdColor,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.white,
      ),
      body: ListView(
        children: [
          StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('transaction')
                .where('userId2', isEqualTo: widget.userId)
                .orderBy('created', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Column(
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.3,
                    ),
                    loadingAnimation(),
                  ],
                );
              } else {
                QuerySnapshot dataSnapshot = snapshot.data;
                List<QueryDocumentSnapshot> dataList = snapshot.data.docs;

                return Entry.opacity(
                  duration: Duration(seconds: 1),
                  child: Container(
                    color: Colors.white,
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: ClampingScrollPhysics(),
                      itemCount: dataSnapshot.docs.length,
                      itemBuilder: (context, index) {
                        //format date
                        Timestamp timestamp = dataList[index]['created'];
                        DateTime date = timestamp.toDate();

                        final DateFormat formatter = DateFormat('dd-MM-yyyy');
                        final String formatted = formatter.format(date);

                        return buildColumn(
                            context, dataSnapshot, index, dataList, formatted);
                      },
                    ),
                  ),
                );
              }
            },
          ),
          SizedBox(
            height: 50,
          ),
        ],
      ),
    );
  }

  Widget buildColumn(
      BuildContext context,
      QuerySnapshot<Object> dataSnapshot,
      int index,
      List<QueryDocumentSnapshot<Object>> dataList,
      String formatted) {
    return Column(
      children: [
        GestureDetector(
          onTap: () => Navigator.push(
            context,
            PageTransition(
              type: PageTransitionType.rightToLeft,
              child: TransactionDetailParent(
                refresh: refresh,
                user: widget.user,
                userRepository: widget.userRepository,
                transactionId: dataSnapshot.docs[index].id,
              ),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.fromLTRB(20, 5, 20, 5),
            child: Container(
              padding: EdgeInsets.fromLTRB(10, 20, 10, 10),
              height: 80,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                color: Colors.white,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          NumberFormat.currency(
                                  locale: 'id', symbol: 'Rp', decimalDigits: 0)
                              .format(dataList[index]['totalPrice2']),
                          style: GoogleFonts.roboto(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          formatted.toString(),
                          style: GoogleFonts.roboto(
                            color: Colors.grey,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.only(right: 10, left: 10),
                    child: Text(
                      dataList[index]['status'],
                      style: GoogleFonts.roboto(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: dataList[index]['status'] == 'Selesai' ||
                                dataList[index]['status'] == 'Pembayaran Lunas'
                            ? Colors.green
                            : dataList[index]['status'] ==
                                        'Menunggu konfirmasi' ||
                                    dataList[index]['status'] ==
                                        'Menunggu Pembayaran'
                                ? Colors.orange
                                : dataList[index]['status'] == 'Dibatalkan' ||
                                        dataList[index]['status'] ==
                                            'Ditolak' ||
                                        dataList[index]['status'] == 'Expired'
                                    ? Colors.red[200]
                                    : Colors.blue,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
        Divider(),
      ],
    );
  }

  //FUNCTION

  void refresh() {
    setState(() {});
  }
}
