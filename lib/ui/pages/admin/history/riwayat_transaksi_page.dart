import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ecommerce/ui/pages/admin/history/pencarian_transaksi.dart';
import 'package:flutter_ecommerce/ui/pages/admin/konfirmasi/detail_order.dart';
import 'package:flutter_ecommerce/utils/color_codes.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;

import 'package:page_transition/page_transition.dart';

class HistoryTransaction extends StatefulWidget {
  @override
  _HistoryTransactionState createState() => _HistoryTransactionState();
}

class _HistoryTransactionState extends State<HistoryTransaction> {
  String _currentSort = 'created';
  int selectedRadioTile;
  int selectedRadio;

  void initState() {
    super.initState();

    selectedRadio = 0;
    selectedRadioTile = 0;
  }

  @override
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
          'Riwayat Transaksi',
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
        backgroundColor: Colors.white,
        actions: [
          Transform(
            alignment: Alignment.center,
            transform: Matrix4.rotationY(math.pi),
            child: IconButton(
              icon: Icon(
                Icons.sort,
                color: primaryColor,
              ),
              onPressed: () {
                showAlertDialog(context);
              },
            ),
          ),
        ],
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('transaction')
            .orderBy(_currentSort, descending: true)
            .limit(20)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else {
            QuerySnapshot data = snapshot.data;

            return NotificationListener<OverscrollIndicatorNotification>(
              // ignore: missing_return
              onNotification: (overscroll) {
                overscroll.disallowGlow();
              },
              child: ListView(
                children: [
                  Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Container(
                      color: Colors.white,
                      child: TextField(
                        onSubmitted: (value) {
                          if (value.isEmpty || value == '') {
                            return 'search text kosong';
                          } else {
                            Navigator.push(
                              context,
                              PageTransition(
                                type: PageTransitionType.fade,
                                child: SearchTransaction(
                                  itemList: data.docs,
                                  searchItem: value,
                                ),
                              ),
                            );
                          }
                        },
                        style: TextStyle(fontSize: 13),
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.all(10),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          prefixIcon: Icon(Icons.search),
                          hintText: 'Cari transaksi pengguna',
                          hintStyle: TextStyle(
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ),
                  ListView.builder(
                    itemCount: data.docs.length,
                    shrinkWrap: true,
                    physics: ClampingScrollPhysics(),
                    itemBuilder: (context, index) {
                      var date = DateTime.parse(
                          data.docs[index]['created'].toDate().toString());

                      var formatter = DateFormat('dd-MM-yyyy kk:mm');
                      String transactionDate = formatter.format(date);

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              PageTransition(
                                  type: PageTransitionType.rightToLeft,
                                  child: DetailOrder(
                                    snapshot: data.docs[index],
                                  )));
                        },
                        child: Container(
                          height: MediaQuery.of(context).size.height * 0.1,
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.2),
                                spreadRadius: 1,
                                blurRadius: 1,
                                offset:
                                    Offset(0, 3), // changes position of shadow
                              ),
                            ],
                          ),
                          margin: EdgeInsets.all(10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding: EdgeInsets.only(left: 10.0),
                                        child: Text(
                                          data.docs[index]['username'],
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding: EdgeInsets.only(left: 10.0),
                                        child: Text(
                                          transactionDate,
                                          style: TextStyle(fontSize: 12),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding:
                                    EdgeInsets.only(left: 10.0, right: 20.0),
                                child: Text(
                                  data.docs[index]['status'],
                                  style: TextStyle(
                                      fontSize: 13,
                                      color: data.docs[index]['status'] ==
                                                  'Ditolak' ||
                                              data.docs[index]['status'] ==
                                                  'Dibatalkan' ||
                                              data.docs[index]['status'] ==
                                                  'Expired'
                                          ? Colors.red
                                          : data.docs[index]['status'] ==
                                                      'Selesai' ||
                                                  data.docs[index]['status'] ==
                                                      'Pembayaran Lunas'
                                              ? Colors.green
                                              : data.docs[index]['status'] ==
                                                      'Menunggu konfirmasi'
                                                  ? Colors.orange
                                                  : primaryColor),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  showAlertDialog(BuildContext context) {
    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Container(
          child: StatefulBuilder(
            builder: (context, setState) => AlertDialog(
              title: Text('Urutkan Hasil : '),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RadioListTile(
                    value: 'created',
                    groupValue: _currentSort,
                    title: Text("Tanggal"),
                    onChanged: (val) {
                      changeSortValue(val);
                      setState(() {});
                    },
                    activeColor: Colors.blue,
                  ),
                  RadioListTile(
                    value: 'username',
                    groupValue: _currentSort,
                    title: Text("Nama"),
                    onChanged: (val) {
                      changeSortValue(val);
                      setState(() {});
                    },
                    activeColor: Colors.blue,
                  ),
                  RadioListTile(
                    value: 'status',
                    groupValue: _currentSort,
                    title: Text("Status"),
                    onChanged: (val) {
                      changeSortValue(val);
                      setState(() {});
                    },
                    activeColor: Colors.blue,
                  ),
                ],
              ),
              actionsPadding: EdgeInsets.symmetric(horizontal: 10),
            ),
          ),
        );
      },
    );
  }

  changeSortValue(
    var value,
  ) {
    setState(() {
      _currentSort = value;
    });
    print('current sort : ' + value.toString());
  }
}
