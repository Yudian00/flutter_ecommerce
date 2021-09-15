import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ecommerce/ui/pages/admin/konfirmasi/detail_order.dart';
import 'package:flutter_ecommerce/utils/color_codes.dart';
import 'package:flutter_ecommerce/utils/mediaQuery.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';

class RecentOrder extends StatelessWidget {
  RecentOrder({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('transaction')
          .where('status', isEqualTo: 'Menunggu konfirmasi')
          .limit(2)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Column(
            children: [
              SizedBox(
                height: 100,
              ),
              Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                ),
              ),
            ],
          );
        } else {
          if (snapshot.data.docs.length == 0) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 50.0),
                child: Text(
                  'Belum ada pesanan',
                  style: TextStyle(fontSize: 11, color: Colors.black54),
                ),
              ),
            );
          } else {
            return ListView.builder(
              itemCount: snapshot.data.docs.length,
              shrinkWrap: true,
              physics: ClampingScrollPhysics(),
              itemBuilder: (context, index) {
                var data = snapshot.data.docs;
                Timestamp t = data[index]['created'];
                DateTime date = t.toDate();
                var newdate = DateFormat.yMMMd().add_jm().format(date);

                return GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    PageTransition(
                      type: PageTransitionType.rightToLeft,
                      child: DetailOrder(
                        snapshot: data[index],
                      ),
                    ),
                  ),
                  child: Container(
                    margin: EdgeInsets.only(
                        right: 20, left: 20, bottom: 30, top: 30),
                    height: MediaQuery.of(context).size.height * 0.1,
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      // border: Border.all(color: primaryColor),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 1,
                          blurRadius: 1,
                          offset: Offset(1, 1), // changes position of shadow
                        ),
                      ],
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.white,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: getCurrentHeight(context, 10),
                            ),
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.only(left: 10.0),
                                child: Text(
                                  data[index]['username'],
                                  style: GoogleFonts.roboto(
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
                                  newdate.toString(),
                                  style: GoogleFonts.roboto(
                                    fontSize: 12,
                                    color: Colors.black54,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: EdgeInsets.only(right: 10.0),
                          child: Text(
                            NumberFormat.currency(
                                    locale: 'id',
                                    symbol: 'Rp',
                                    decimalDigits: 0)
                                .format(data[index]['totalPrice2']),
                            style: GoogleFonts.roboto(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        }
      },
    );
  }
}
