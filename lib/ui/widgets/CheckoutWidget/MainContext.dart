import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_ecommerce/cubit/transactionCubit/transaction_cubit.dart';
import 'package:flutter_ecommerce/repositories/user_repository.dart';
import 'package:flutter_ecommerce/ui/pages/user/checkout/process_page.dart';
import 'package:flutter_ecommerce/ui/pages/user/termcondition/term_and_condition_page.dart';
import 'package:flutter_ecommerce/utils/color_codes.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';

// ignore: must_be_immutable
class MainContext extends StatelessWidget {
  final String username;
  final String userPhoneNumber;
  final String userId;
  final String note;
  final String kodepos;
  final String address;
  final String detailAddress;
  final String metodePembayaran;
  final int totalPrice;
  final Map mapCart;
  final User user;
  final UserRepository userRepository;
  final Function refresh;
  final List priceList;
  final bool termCondition;
  final Function setTermCondition;

  MainContext({
    @required this.user,
    @required this.userRepository,
    @required this.username,
    @required this.userPhoneNumber,
    @required this.userId,
    @required this.mapCart,
    @required this.totalPrice,
    @required this.note,
    @required this.metodePembayaran,
    @required this.address,
    @required this.detailAddress,
    @required this.kodepos,
    @required this.refresh,
    @required this.priceList,
    @required this.termCondition,
    @required this.setTermCondition,
    Key key,
  }) : super(key: key);

  Map orderData = {};

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TransactionCubit(),
      child: BlocListener<TransactionCubit, TransactionState>(
        listener: (context, state) {
          if (state is TransactionEnd) {
            navigateToProcessingPage(context, state.isSuccess, refresh);
          }
        },
        child: BlocBuilder<TransactionCubit, TransactionState>(
          builder: (context, state) {
            if (state is TransactionInitial) {
              return mainContext(context);
            } else if (state is TransactionEnd) {
              return Container();
            } else {
              return Container();
            }
          },
        ),
      ),
    );
  }

  ListView mainContext(BuildContext context) {
    return ListView(
      physics: ClampingScrollPhysics(),
      children: [
        subHeading('Catatan Pembelian'),

        listItem(mapCart.length, mapCart),
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
                  totalPrice,
                ),
                style: GoogleFonts.mavenPro(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        metodePembayaran == 'Transfer'
            ? Padding(
                padding: EdgeInsets.only(left: 20.0, bottom: 20.0),
                child: RichText(
                  text: TextSpan(
                    text: '* ',
                    style: TextStyle(fontSize: 12.0, color: Colors.red),
                    children: [
                      TextSpan(
                        text: 'Biaya belum termasuk ongkos kirim',
                        style: TextStyle(color: Colors.black45, fontSize: 12.0),
                      ),
                    ],
                  ),
                ),
              )
            : Container(),
        detailAddress == '' || address == '' || kodepos == ''
            ? Container()
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  subHeading('Alamat Pengiriman'),
                  Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          color: Colors.red[400],
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: Text(
                            detailAddress + ' ' + address + ' ' + kodepos,
                            style: TextStyle(
                                fontSize: 13,
                                height: 1.5,
                                color: Colors.black45),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
        note == '' || note == null
            ? Container()
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  subHeading('Catatan Pembelian'),
                  Padding(
                    padding: EdgeInsets.only(left: 20.0, bottom: 20),
                    child: Text(
                      note,
                      style: GoogleFonts.roboto(
                        fontStyle: FontStyle.italic,
                        color: Colors.black45,
                      ),
                    ),
                  ),
                ],
              ),
        subHeading('Informasi Pembelian'),
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
              child: Text(username, style: GoogleFonts.roboto()),
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
              child: Text(userPhoneNumber, style: GoogleFonts.roboto()),
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
                'Metode Pembayaran : ',
                style: GoogleFonts.roboto(),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(right: 20.0, top: 10),
              child: Text(
                metodePembayaran,
                style: GoogleFonts.roboto(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        SizedBox(
          height: 40,
        ),
        Padding(
          padding: EdgeInsets.only(
            left: 10.0,
            right: 10,
          ),
          child: Row(
            children: [
              Checkbox(
                value: termCondition,
                onChanged: (bool value) {
                  setTermCondition(value);
                },
                activeColor: primaryColor,
              ),
              Container(
                width: MediaQuery.of(context).size.width * 0.78,
                height: MediaQuery.of(context).size.height * 0.07,
                child: Center(
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'Saya telah membaca dan menyetujui ',
                          style: TextStyle(
                            fontSize: 13,
                            height: 1.5,
                            color: Colors.black,
                          ),
                        ),
                        TextSpan(
                          text: 'syarat dan ketentuan ',
                          style: TextStyle(
                            fontSize: 13,
                            height: 1.5,
                            color: Colors.blue,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              Navigator.push(
                                context,
                                PageTransition(
                                  type: PageTransitionType.fade,
                                  child: TermAndConditionPage(),
                                ),
                              );
                            },
                        ),
                        TextSpan(
                          text: 'yang berlaku saat ini',
                          style: TextStyle(
                            fontSize: 13,
                            height: 1.5,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 20,
        ),
        Padding(
          padding: EdgeInsets.all(20.0),
          child: ElevatedButton(
            onPressed: () {
              if (!termCondition) {
                final snackBar = SnackBar(
                  content: Text('Syarat dan ketentuan belum dicentang'),
                  duration: Duration(milliseconds: 800),
                );

                ScaffoldMessenger.of(context).showSnackBar(snackBar);
              } else {
                if (metodePembayaran == 'Transfer') {
                  transferMethodcreateMap();

                  //pass to bloc
                  context.read<TransactionCubit>().transfer(orderData);
                } else {
                  payAtStorecreateMap();

                  //pass to bloc
                  context.read<TransactionCubit>().payAtStore(orderData);
                }
              }
            },
            style: ElevatedButton.styleFrom(
              primary: primaryColor,
              elevation: 3.0,
            ),
            child: Container(
              height: 50,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  'LANJUTKAN',
                  style: GoogleFonts.openSans(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ),
          ),
        ),
        SizedBox(
          height: 20,
        ),

        // orderPay(),
        SizedBox(height: 100),
      ],
    );
  }

  Widget listItem(mapCartLength, mapCart) {
    return ListView.builder(
      shrinkWrap: true,
      physics: ClampingScrollPhysics(),
      itemCount: mapCartLength,
      itemBuilder: (context, index) => StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('product')
            .doc(mapCart.keys.elementAt(index))
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Container();
          } else {
            DocumentSnapshot product = snapshot.data;

            // //  calculate a new price after discount
            var discountPrice =
                int.parse(product['harga']) * product['discount_percent'] / 100;
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
                            'x' + mapCart.values.elementAt(index).toString(),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          NumberFormat.currency(
                                  locale: 'id', symbol: 'Rp', decimalDigits: 0)
                              .format(
                            newPrice2 * mapCart.values.elementAt(index),
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
              ],
            );
          }
        },
      ),
    );
  }

  Widget subHeading(String subHeading) {
    return Container(
      margin: EdgeInsets.all(15),
      child: Text(
        subHeading,
        style: GoogleFonts.openSans(fontSize: 15, fontWeight: FontWeight.bold),
      ),
    );
  }

  void navigateToProcessingPage(
      BuildContext context, bool isSuccess, Function refresh) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ProcessPage(
          refresh: refresh,
          user: user,
          userRepository: userRepository,
          isSuccess: isSuccess,
        ),
      ),
    );
  }

  void transferMethodcreateMap() {
    //create data
    orderData.putIfAbsent('userID', () => userId);
    orderData.putIfAbsent('username', () => username);
    orderData.putIfAbsent('userPhoneNumber', () => userPhoneNumber);
    orderData.putIfAbsent('mapCart', () => mapCart);
    orderData.putIfAbsent('totalPrice', () => totalPrice);
    orderData.putIfAbsent('note', () => note);
    orderData.putIfAbsent(
        'address', () => detailAddress + ' ' + address + ' ' + kodepos);
    orderData.putIfAbsent('itemPriceList', () => priceList);
  }

  void payAtStorecreateMap() {
    //create data
    orderData.putIfAbsent('userID', () => userId);
    orderData.putIfAbsent('username', () => username);
    orderData.putIfAbsent('userPhoneNumber', () => userPhoneNumber);
    orderData.putIfAbsent('mapCart', () => mapCart);
    orderData.putIfAbsent('totalPrice', () => totalPrice);
    orderData.putIfAbsent('note', () => note);
    orderData.putIfAbsent('itemPriceList', () => priceList);
  }
}
