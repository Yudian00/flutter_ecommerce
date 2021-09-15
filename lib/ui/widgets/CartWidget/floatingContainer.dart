import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_ecommerce/cubit/cartCubit/cart_cubit.dart';
import 'package:flutter_ecommerce/repositories/user_repository.dart';
import 'package:flutter_ecommerce/utils/color_codes.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

// ignore: must_be_immutable
class FloatingContainer extends StatelessWidget {
  bool isPayAtStoreselected = false;
  bool isTransferSelected = false;

  String username;
  String userPhoneNumber;
  String userId;
  String note;

  User user;
  UserRepository userRepository;

  int initalPrice;

  Function validate;

  FloatingContainer({
    @required this.initalPrice,
    @required this.isPayAtStoreselected,
    @required this.isTransferSelected,
    @required this.username,
    @required this.userPhoneNumber,
    @required this.userId,
    @required this.user,
    @required this.userRepository,
    @required this.validate,
    @required this.note,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: FractionalOffset.bottomCenter,
      child: Container(
        height: MediaQuery.of(context).size.height / 10,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20), topRight: Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: Colors.grey,
              offset: Offset(0.0, 1.0), //(x,y)
              blurRadius: 10.0,
            ),
          ],
        ),
        child: BlocBuilder<CartCubit, CartState>(
          // ignore: missing_return
          builder: (context, state) {
            if (state is CartInitial) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.fromLTRB(30, 0, 30, 0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              'Total : ',
                              style: TextStyle(
                                  fontSize: 17, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              NumberFormat.currency(
                                      locale: 'id',
                                      symbol: 'Rp',
                                      decimalDigits: 0)
                                  .format(initalPrice)
                                  .toString(),
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      state.totalPrice == 0
                          ? _noItemsButtonCheckOut(context)
                          : Expanded(
                              child: buttonCheckOut(context, initalPrice))
                    ],
                  ),
                ],
              );
            } else if (state is LoadCartState) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.fromLTRB(30, 0, 30, 0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(
                              'Total : ',
                              style: TextStyle(
                                  fontSize: 17, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              NumberFormat.currency(
                                      locale: 'id',
                                      symbol: 'Rp',
                                      decimalDigits: 0)
                                  .format(state.totalPrice)
                                  .toString(),
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      state.totalPrice == 0
                          ? _noItemsButtonCheckOut(context)
                          : Expanded(
                              child: buttonCheckOut(context, state.totalPrice))
                    ],
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }

  Widget buttonCheckOut(BuildContext context, int totalPrice) {
    return Container(
      margin: EdgeInsets.only(top: 5, left: 20, right: 20, bottom: 5),
      width: MediaQuery.of(context).size.width / 3,
      height: 40,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          primary: primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(40.0),
            side: BorderSide(color: Colors.grey),
          ),
        ),
        onPressed: () async {
          // validate();
          if (isPayAtStoreselected) {
            validate(totalPrice);
          } else if (isTransferSelected) {
            validate(totalPrice);
          } else {
            showSnackbar(context);
          }
        },
        child: Center(
          child: Text(
            'LANJUT',
            style: GoogleFonts.openSans(
              fontSize: 12,
              letterSpacing: 5,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _noItemsButtonCheckOut(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 5, bottom: 5, right: 15),
      width: MediaQuery.of(context).size.width / 3,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.grey,
        borderRadius: BorderRadius.circular(14.0),
      ),
      child: Center(
        child: Text(
          '-',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }

  showSnackbar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Pilih metode pembayaran dulu..'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
