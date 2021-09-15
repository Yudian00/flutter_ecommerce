import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_ecommerce/cubit/transactionCubit/transaction_cubit.dart';
import 'package:flutter_ecommerce/repositories/user_repository.dart';
import 'package:flutter_ecommerce/ui/pages/user/checkout/process_page.dart';
import 'package:flutter_ecommerce/utils/color_codes.dart';
import 'package:google_fonts/google_fonts.dart';

// ignore: must_be_immutable
class ActionButton extends StatelessWidget {
  final String username;
  final String userPhoneNumber;
  final String userId;
  final int totalPrice;
  final Map mapCart;
  final Function refresh;
  final String note;

  final User user;
  final UserRepository userRepository;

  Map orderData = {};

  ActionButton({
    @required this.refresh,
    @required this.username,
    @required this.userPhoneNumber,
    @required this.userId,
    @required this.mapCart,
    @required this.totalPrice,
    @required this.user,
    @required this.userRepository,
    @required this.note,
    Key key,
  }) : super(key: key);

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

  void createMap() {
    //create data
    orderData.putIfAbsent('userID', () => userId);
    orderData.putIfAbsent('username', () => username);
    orderData.putIfAbsent('userPhoneNumber', () => userPhoneNumber);
    orderData.putIfAbsent('mapCart', () => mapCart);
    orderData.putIfAbsent('totalPrice', () => totalPrice);
    orderData.putIfAbsent('note', () => note);
  }

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
          // ignore: missing_return
          builder: (context, state) {
            if (state is TransactionInitial) {
              return mainContext(context);
            } else if (state is TransactionEnd) {
              return Container();
            }
          },
        ),
      ),
    );
  }

  Widget mainContext(BuildContext context) {
    return InkWell(
      onTap: () {
        //create map
        createMap();

        //pass to bloc
        // context.read()<TransactionCubit>().order(orderData);
        // context.read<TransactionCubit>().order(orderData);

        print(orderData);
      },
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: 50,
        margin: EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: primaryColor,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_cart,
              color: Colors.white,
            ),
            SizedBox(
              width: 10,
            ),
            Text(
              'PESAN BARANG',
              style: GoogleFonts.openSans(
                fontSize: 14,
                // letterSpacing: 3,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
