import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ecommerce/ui/pages/admin/ambil/ambil_produk_detail.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';

class TakeOrderList extends StatelessWidget {
  final QuerySnapshot querySnapshot;

  TakeOrderList({
    @required this.querySnapshot,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: querySnapshot.docs.length,
      itemBuilder: (context, index) {
        List<QueryDocumentSnapshot> data = querySnapshot.docs;
        Timestamp t = data[index]['created'];
        DateTime date = t.toDate();
        var newdate = DateFormat.yMMMd().add_jm().format(date);

        return GestureDetector(
          onTap: () => Navigator.push(
            context,
            PageTransition(
              type: PageTransitionType.rightToLeft,
              child: DetailTakeOrder(
                snapshot: data[index],
              ),
            ),
          ),
          child: Container(
            margin: EdgeInsets.all(20),
            height: MediaQuery.of(context).size.height * 0.1,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
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
                      height: 10,
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
                            locale: 'id', symbol: 'Rp', decimalDigits: 0)
                        .format(data[index]['totalPrice2']),
                    style: GoogleFonts.roboto(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
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
