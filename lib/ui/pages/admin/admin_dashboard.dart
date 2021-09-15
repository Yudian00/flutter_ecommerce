import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_ecommerce/blocs/homeBloc/home_page_bloc.dart';
import 'package:flutter_ecommerce/blocs/homeBloc/home_page_event.dart';
import 'package:flutter_ecommerce/blocs/homeBloc/home_page_state.dart';
import 'package:flutter_ecommerce/repositories/DatabaseUser.dart';
import 'package:flutter_ecommerce/repositories/user_repository.dart';
import 'package:flutter_ecommerce/ui/pages/admin/konfirmasi/waiting_transaction.dart';
import 'package:flutter_ecommerce/ui/pages/login_page.dart';
import 'package:flutter_ecommerce/ui/widgets/adminWidget/admin_dashboard_menu.dart';
import 'package:flutter_ecommerce/ui/widgets/adminWidget/recent_order.dart';
import 'package:flutter_ecommerce/utils/color_codes.dart';
import 'package:flutter_ecommerce/utils/mediaQuery.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';

// ignore: must_be_immutable
class AdminDashboard extends StatelessWidget {
  User user;
  UserRepository userRepository;

  AdminDashboard({@required this.user, @required this.userRepository});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomePageBloc(userRepository: userRepository),
      child: AdminScrenn(user: user, userRepository: userRepository),
    );
  }
}

// ignore: must_be_immutable
class AdminScrenn extends StatefulWidget {
  User user;
  UserRepository userRepository;

  AdminScrenn({@required this.user, @required this.userRepository});

  @override
  _AdminScrennState createState() => _AdminScrennState();
}

class _AdminScrennState extends State<AdminScrenn> {
  List transactionIdList = [];

  void initState() {
    super.initState();

    getToken();
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

  void getToken() async {
    String token = await FirebaseMessaging.instance.getToken();

    DatabaseUser.createToken(widget.user.uid, token);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          'Halo, ' + widget.user.displayName,
          style: TextStyle(
            color: Colors.black54,
            fontSize: 14,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.exit_to_app,
              color: Colors.black54,
              size: 20,
            ),
            onPressed: () {
              showAlertDialog(context, widget.user.uid);
            },
          ),
        ],
      ),
      body: Container(
        child: BlocListener<HomePageBloc, HomePageState>(
          listener: (BuildContext context, state) {
            if (state is LogOutSuccessState) {
              Navigator.of(context).pop();
              return navigateToLoginpPage(context);
            }
          },
          child: BlocBuilder<HomePageBloc, HomePageState>(
            builder: (context, state) {
              return NotificationListener<OverscrollIndicatorNotification>(
                // ignore: missing_return
                onNotification: (overscroll) {
                  overscroll.disallowGlow();
                },
                child: ListView(
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.03,
                    ),
                    AdminDashboardMenu(
                      transactionIdList: transactionIdList,
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.03,
                    ),
                    Divider(
                      thickness: 1,
                      indent: 20,
                      endIndent: 20,
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.03,
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height * 0.5,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(left: 20.0, right: 20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Menunggu Konfirmasi',
                                  style: GoogleFonts.roboto(
                                    fontSize: 14,
                                    color: Colors.black54,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => Navigator.push(
                                    context,
                                    PageTransition(
                                      type: PageTransitionType.fade,
                                      child: WaitingTransaction(
                                        metode: '',
                                        transactionIdList: transactionIdList,
                                      ),
                                    ),
                                  ),
                                  child: Text(
                                    'Lihat Semua',
                                    style: GoogleFonts.roboto(
                                      fontSize: 11,
                                      color: Colors.blue,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          RecentOrder(),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void navigateToLoginpPage(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) {
          return LoginPageParent(userRepository: widget.userRepository);
        },
      ),
    );
  }
}

showAlertDialog(BuildContext context, String userId) {
  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    title: Text('Keluar'),
    content: Text("Kamu ingin keluar sebagai admin?"),
    actionsPadding: EdgeInsets.symmetric(horizontal: 10),
    actions: [
      TextButton(
        onPressed: () {
          Navigator.pop(context);
        },
        child: Text(
          "Tidak",
          style: TextStyle(color: Colors.black54, fontWeight: FontWeight.bold),
        ),
      ),
      SizedBox(
        width: 40,
      ),
      TextButton(
        onPressed: () {
          BlocProvider.of<HomePageBloc>(context).add(LogOutEvent());
        },
        child: Container(
          height: getCurrentHeight(context, 40),
          width: getCurrentWidth(context, 80),
          decoration: BoxDecoration(
            color: adminMainColor,
            borderRadius: BorderRadius.circular(5),
          ),
          child: Center(
            child: Text(
              "Ya",
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    ],
  );

  // show the dialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Container(child: alert);
    },
  );
}
