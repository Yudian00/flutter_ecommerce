import 'package:flutter/material.dart';
import 'package:flutter_ecommerce/ui/pages/admin/konfirmasi/detail_order.dart';
import 'package:flutter_ecommerce/utils/color_codes.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';

class SearchTransaction extends StatefulWidget {
  final String searchItem;
  final List itemList;

  SearchTransaction({
    @required this.itemList,
    @required this.searchItem,
  });

  @override
  _SearchTransactionState createState() => _SearchTransactionState();
}

class _SearchTransactionState extends State<SearchTransaction> {
  List resultList = [];
  void initState() {
    super.initState();
    getSearchedTransaction();
  }

  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            'Hasil Pencarian Transaksi',
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
        ),
        body: ListView.builder(
          itemCount: resultList.length,
          shrinkWrap: true,
          itemBuilder: (context, index) {
            var date = DateTime.parse(
                resultList[index]['created'].toDate().toString());

            var formatter = DateFormat('dd-MM-yyyy kk:mm');
            String transactionDate = formatter.format(date);

            return GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    PageTransition(
                        type: PageTransitionType.rightToLeft,
                        child: DetailOrder(
                          snapshot: resultList[index],
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
                      offset: Offset(0, 3), // changes position of shadow
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
                                resultList[index]['username'],
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
                      padding: EdgeInsets.only(left: 10.0, right: 20.0),
                      child: Text(
                        resultList[index]['status'],
                        style: TextStyle(
                            fontSize: 13,
                            color: resultList[index]['status'] == 'Ditolak' ||
                                    resultList[index]['status'] ==
                                        'Dibatalkan' ||
                                    resultList[index]['status'] == 'Expired'
                                ? Colors.red
                                : resultList[index]['status'] == 'Selesai' ||
                                        resultList[index]['status'] ==
                                            'Pembayaran Lunas'
                                    ? Colors.green
                                    : resultList[index]['status'] ==
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
        ));
  }

  void getSearchedTransaction() {
    String searchItem = widget.searchItem.toLowerCase();
    List itemList = widget.itemList;

    for (var i = 0; i < itemList.length; i++) {
      print(itemList[i]['username'] +
          ' : ' +
          itemList[i]['username']
              .toString()
              .toLowerCase()
              .contains(searchItem)
              .toString());
      if (itemList[i]['username']
          .toString()
          .toLowerCase()
          .contains(searchItem)) {
        resultList.add(itemList[i]);
      }

      // log(resultList[i]);
    }
    print('=========================');
    print(resultList[0]['username'].toString());
  }
}
