import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_ecommerce/blocs/homeBloc/home_page_bloc.dart';
import 'package:flutter_ecommerce/blocs/homeBloc/home_page_event.dart';
import 'package:flutter_ecommerce/blocs/homeBloc/home_page_state.dart';
import 'package:flutter_ecommerce/repositories/user_repository.dart';
import 'package:flutter_ecommerce/ui/pages/login_page.dart';
import 'package:flutter_ecommerce/ui/pages/user/home/home_page.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:meta/meta.dart';

// ignore: must_be_immutable
class DrawerMenuParent extends StatelessWidget {
  //userdata
  User user;
  UserRepository userRepository;

  DocumentSnapshot snapshot;
  int currentIndex = 0;
  Function changeCurrentIndex;
  Function closeDrawer;

  DrawerMenuParent({
    @required this.snapshot,
    @required this.currentIndex,
    @required this.changeCurrentIndex,
    @required this.closeDrawer,
    @required this.user,
    @required this.userRepository,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider<HomePageBloc>(
      create: (context) => HomePageBloc(userRepository: userRepository),
      child: DrawerMenu(
        changeCurrentIndex: changeCurrentIndex,
        closeDrawer: closeDrawer,
        currentIndex: currentIndex,
        snapshot: snapshot,
        user: user,
        userRepository: userRepository,
      ),
    );
  }
}

// ignore: must_be_immutable
class DrawerMenu extends StatelessWidget {
  //userdata
  User user;
  UserRepository userRepository;

  DocumentSnapshot snapshot;
  int currentIndex = 0;
  Function changeCurrentIndex;
  Function closeDrawer;
  HomePageBloc homePageBloc;

  DrawerMenu({
    @required this.snapshot,
    @required this.currentIndex,
    @required this.changeCurrentIndex,
    @required this.closeDrawer,
    @required this.user,
    @required this.userRepository,
  });

  @override
  Widget build(BuildContext context) {
    homePageBloc = BlocProvider.of<HomePageBloc>(context);

    return Scaffold(
      body: BlocListener<HomePageBloc, HomePageState>(
        listener: (context, state) {
          if (state is LogOutSuccessState) {
            navigateToLoginpPage(context);
          }
        },
        child: BlocBuilder<HomePageBloc, HomePageState>(
          // ignore: missing_return
          builder: (context, state) {
            if (state is LogOutInitial) {
              return buildBody(context);
            } else if (state is LogOutSuccessState) {
              return Container();
            }
          },
        ),
      ),
    );
  }

  Container buildBody(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.65,
      color: Color(0xFF504e5e),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          //username info
          Padding(
            padding: const EdgeInsets.only(top: 50, left: 20, right: 20),
            child: Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.green,
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        snapshot == null ? 'user' : snapshot['username'],
                        style: GoogleFonts.openSans(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                      Text(
                        // snapshot['email'],
                        snapshot == null ? 'email' : snapshot['email'],
                        style: GoogleFonts.openSans(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),

          //itemList
          Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: Column(
              children: [
                InkWell(
                  onTap: () {
                    print('direct to home page');
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => HomePageParent(
                                user: user,
                                userRepository: userRepository,
                              )),
                    );
                    changeCurrentIndex(0);
                    closeDrawer();
                  },
                  child: Container(
                    height: 50,
                    child: Row(
                      children: [
                        Container(
                          width: 5,
                          color: currentIndex == 0
                              ? Colors.blue
                              : Colors.transparent,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Icon(
                          Icons.home,
                          color: Colors.white,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          'Beranda',
                          style: GoogleFonts.openSans(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    changeCurrentIndex(1);
                    closeDrawer();
                  },
                  child: Container(
                    height: 50,
                    child: Row(
                      children: [
                        Container(
                          width: 5,
                          color: currentIndex == 1
                              ? Colors.blue
                              : Colors.transparent,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Icon(
                          Icons.assignment,
                          color: Colors.white,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          'Transaksi',
                          style: GoogleFonts.openSans(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),

          //logout button
          BlocBuilder<HomePageBloc, HomePageState>(
            builder: (context, state) => InkWell(
              onTap: () => showAlertDialog(context),
              child: Container(
                margin: EdgeInsets.only(top: 30, left: 15, bottom: 70),
                child: InkWell(
                  child: Row(
                    children: [
                      Icon(
                        Icons.exit_to_app,
                        color: Colors.white,
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        'Keluar',
                        style: GoogleFonts.openSans(color: Colors.white),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void navigateToLoginpPage(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) {
          return LoginPageParent(userRepository: userRepository);
        },
      ),
    );
  }

  showAlertDialog(BuildContext context) {
    Widget cancelButton = GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        margin: EdgeInsets.only(bottom: 20),
        width: 80,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: Colors.blue,
          ),
        ),
        child: Center(
            child: Text(
          "Cancel",
          style: TextStyle(color: Colors.blue),
        )),
      ),
    );

    Widget continueButton = GestureDetector(
      onTap: () => homePageBloc.add(LogOutEvent()),
      child: Container(
        margin: EdgeInsets.only(bottom: 20),
        width: 80,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: Colors.white,
          ),
        ),
        child: Center(
            child: Text(
          "Keluar",
          style: TextStyle(color: Colors.white),
        )),
      ),
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text('Logout'),
      content: Text('Keluar sekarang?'),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
