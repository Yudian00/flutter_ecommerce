import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ecommerce/repositories/user_repository.dart';
import 'package:flutter_ecommerce/ui/pages/user/transaction/transactionDetail.dart';
import 'package:flutter_ecommerce/utils/color_codes.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';

// ignore: must_be_immutable
class ConfirmationWaitingList extends StatelessWidget {
  ConfirmationWaitingList({
    Key key,
    @required this.data,
    @required this.transactionList,
    @required this.current,
    @required this.refresh,
    @required this.showDialog,
    @required this.currentUser,
    @required this.user,
    @required this.userRepository,
  }) : super(key: key);

  var data;
  var currentUser;
  List transactionList;
  int current;
  Function refresh;
  Function showDialog;
  final User user;
  final UserRepository userRepository;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: EdgeInsets.only(top: 20, left: 20),
          child: Text(
            'Menunggu Konfirmasi',
            style: GoogleFonts.roboto(
                fontWeight: FontWeight.w500, fontSize: 18, color: thirdColor),
          ),
        ),
        GestureDetector(
          onTap: () => Navigator.push(
              context,
              PageTransition(
                  type: PageTransitionType.rightToLeft,
                  child: TransactionDetailParent(
                      refresh: refresh,
                      userRepository: userRepository,
                      user: user,
                      transactionId: transactionList[current]))),
          child: Container(
            height: MediaQuery.of(context).size.height / 4,
            width: MediaQuery.of(context).size.width,
            child: CarouselSlider.builder(
              itemCount: data.length,
              options: CarouselOptions(
                height: MediaQuery.of(context).size.height / 4.88,
                enableInfiniteScroll: false,
                autoPlay: false,
                initialPage: 0,
                enlargeCenterPage: false,
                viewportFraction: 1,
                onPageChanged: (index, reason) {
                  refresh(index);
                  print(index);
                },
              ),
              itemBuilder: (context, index, itemIndex) {
                //initialize data
                Timestamp t = data[index]['created'];
                DateTime d = t.toDate();

                final f = new DateFormat('hh:mm yyyy-MM-dd');
                var date = f.format(d);

                return data == null
                    ? Container(
                        margin: EdgeInsets.only(left: 20, right: 20),
                        width: MediaQuery.of(context).size.width / 1.02,
                        height: MediaQuery.of(context).size.height / 4.9,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: thirdColor,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Container(
                                  margin: EdgeInsets.fromLTRB(15, 15, 15, 5),
                                  child: Text(
                                    NumberFormat.currency(
                                            locale: 'id',
                                            symbol: 'Rp',
                                            decimalDigits: 0)
                                        .format(data[index]['totalPrice2']),
                                    style: GoogleFonts.openSans(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.fromLTRB(15, 5, 15, 5),
                                  child: Text(
                                    date.toString(),
                                    style: GoogleFonts.openSans(
                                      color: Colors.white,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.fromLTRB(15, 5, 15, 5),
                                  child: Text(
                                    data[index]['status'],
                                    style: GoogleFonts.openSans(
                                      color: Colors.white,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width / 7.2,
                              decoration: BoxDecoration(
                                color: thirdColor,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: IconButton(
                                  icon: Icon(
                                    Icons.close,
                                    color: Colors.white,
                                  ),
                                  onPressed: () {
                                    // print(transactionList[index]);
                                    showDialog(transactionList[index]);
                                  },
                                ),
                              ),
                            )
                          ],
                        ),
                      )
                    : Container();
              },
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: transactionList.map((currentIndex) {
            int index = transactionList.indexOf(currentIndex);
            return Container(
              width: 8.0,
              height: 8.0,
              margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 5.0),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: current == index
                    ? Color.fromRGBO(0, 0, 0, 0.9)
                    : Color.fromRGBO(0, 0, 0, 0.4),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
