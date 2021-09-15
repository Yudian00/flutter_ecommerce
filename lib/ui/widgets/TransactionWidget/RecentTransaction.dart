import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ecommerce/repositories/DatabaseServices.dart';
import 'package:flutter_ecommerce/repositories/user_repository.dart';
import 'package:flutter_ecommerce/ui/pages/user/transaction/transactionDetail.dart';
import 'package:flutter_ecommerce/ui/pages/user/transaction/transaction_history.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';

class RecentTransaction extends StatelessWidget {
  final QuerySnapshot data;
  final List recentDataList;
  final List transactionId;
  final User user;
  final UserRepository userRepository;
  final Function refresh;

  RecentTransaction({
    @required this.data,
    @required this.recentDataList,
    @required this.transactionId,
    @required this.user,
    @required this.userRepository,
    @required this.refresh,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: ListView.builder(
        shrinkWrap: true,
        physics: ClampingScrollPhysics(),
        itemCount: recentDataList.length,
        itemBuilder: (context, index) {
          //format date
          Timestamp timestamp = recentDataList[index]['created'];
          DateTime date = timestamp.toDate();

          final DateFormat formatter = DateFormat('dd-MM-yyyy');
          final String formatted = formatter.format(date);

          if (index == recentDataList.length - 1 && recentDataList.length > 2) {
            return Padding(
              padding: EdgeInsets.all(5.0),
              child: ListTile(
                onTap: () => Navigator.push(
                  context,
                  PageTransition(
                    type: PageTransitionType.rightToLeft,
                    child: TransactionHistory(
                      user: user,
                      userRepository: userRepository,
                      userId: user.uid,
                    ),
                  ),
                ).then((value) => refresh()),
                title: Center(
                  child: Text(
                    'Lihat Semua',
                    style: GoogleFonts.openSans(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            );
          }

          return Column(
            children: [
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  PageTransition(
                    type: PageTransitionType.rightToLeft,
                    child: TransactionDetailParent(
                        refresh: refresh,
                        user: user,
                        userRepository: userRepository,
                        transactionId: transactionId[index]),
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
                      borderRadius: BorderRadius.circular(10),
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
                                        locale: 'id',
                                        symbol: 'Rp',
                                        decimalDigits: 0)
                                    .format(
                                        recentDataList[index]['totalPrice2']),
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
                            recentDataList[index]['status'],
                            style: GoogleFonts.roboto(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: recentDataList[index]['status'] ==
                                          'Selesai' ||
                                      recentDataList[index]['status'] ==
                                          'Pembayaran Lunas'
                                  ? Colors.green
                                  : recentDataList[index]['status'] ==
                                              'Menunggu konfirmasi' ||
                                          recentDataList[index]['status'] ==
                                              'Menunggu Pelunasan'
                                      ? Colors.orange
                                      : recentDataList[index]['status'] ==
                                                  'Dibatalkan' ||
                                              recentDataList[index]['status'] ==
                                                  'Ditolak' ||
                                              recentDataList[index]['status'] ==
                                                  'Expired'
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
        },
      ),
    );
  }

  Future<void> futureCheck(int index) {
    FirebaseFirestore.instance
        .collection('midtrans')
        .where('midtransId', isEqualTo: data.docs[index]['midtransId'])
        .get()
        .then((value) {
      DateTime expiredTime =
          DateTime.parse(value.docs[0]['expired_time'].toDate().toString());

      if (!expiredTime.isAfter(DateTime.now())) {
        DatabaseServices.setExpireTransactionStatus(transactionId[index]);
      }
    });
    return null;
  }
}
