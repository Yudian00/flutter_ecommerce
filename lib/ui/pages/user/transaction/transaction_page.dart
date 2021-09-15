import 'dart:async';

import 'package:carousel_slider/carousel_controller.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:entry/entry.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';
import 'package:flutter_ecommerce/cubit/countdownTimerCubit/countdowntimer_cubit.dart';
import 'package:flutter_ecommerce/cubit/transactionList/transactionlist_cubit.dart';
import 'package:flutter_ecommerce/repositories/user_repository.dart';
import 'package:flutter_ecommerce/ui/pages/user/bottom_navigation_bar.dart';
import 'package:flutter_ecommerce/ui/pages/user/transaction/transactionDetail.dart';
import 'package:flutter_ecommerce/ui/widgets/TransactionWidget/RecentTransaction.dart';
import 'package:flutter_ecommerce/utils/color_codes.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:page_transition/page_transition.dart';

// ignore: must_be_immutable
class TransactionPageParent extends StatelessWidget {
  //userdata
  User user;
  UserRepository userRepository;

  TransactionPageParent({
    @required this.user,
    @required this.userRepository,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TransactionlistCubit(),
      child: BlocProvider(
        create: (context) => CountdowntimerCubit(),
        child: TransactionPage(
          user: user,
          userRepository: userRepository,
        ),
      ),
    );
  }
}

// ignore: must_be_immutable
class TransactionPage extends StatefulWidget {
  //userdata
  User user;
  UserRepository userRepository;

  TransactionPage({
    @required this.user,
    @required this.userRepository,
  });

  @override
  _TransactionPageState createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  //transaction card
  int current = 0;
  List transactionList = [];
  List transactionIdList = [];
  var currentUserId;
  final FirebaseAuth auth = FirebaseAuth.instance;

  bool isOnEffect = true;
  bool isEmpty = false;

  void initState() {
    getcurrentUser();
    getTransactionList();
    getAllTransactionId();

    super.initState();
  }

  void dispose() {
    super.dispose();
  }

  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: BlocListener<TransactionlistCubit, TransactionlistState>(
        listener: (context, state) {
          if (state is TransactionListDeleted) {
            Navigator.pop(context);
            refreshingPage();
          }
        },
        child: Entry.opacity(
          duration: Duration(seconds: 1),
          child: Container(
            child: ListView(
              children: [
                StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('transaction')
                      .where('userId2', isEqualTo: currentUserId)
                      .limit(4)
                      .orderBy('created', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: 300,
                          ),
                          Container(
                            height: 100,
                            width: 100,
                            child: Center(
                              child: LottieBuilder.asset(
                                  'assets/lottieAnimations/loading_animation_2.json'),
                            ),
                          ),
                        ],
                      );
                    } else {
                      List dataList = [];

                      // RIWAYAT TRANSAKSI
                      QuerySnapshot data = snapshot.data;
                      dataList = snapshot.data.docs;

                      if (dataList.length == 0) {
                        return Center(
                          child: Column(
                            children: [
                              Container(
                                margin: EdgeInsets.only(top: 100),
                                height: 300,
                                width: 300,
                                child: LottieBuilder.asset(
                                    'assets/lottieAnimations/emptylost.json'),
                              ),
                              Text(
                                'Riwayat transaksi tidak ditemukan',
                                style: GoogleFonts.roboto(
                                  fontSize: 15,
                                  color: Colors.black54,
                                ),
                              )
                            ],
                          ),
                        );
                      } else {
                        return Container(
                          height: MediaQuery.of(context).size.height,
                          width: MediaQuery.of(context).size.width,
                          child: ListView(
                            children: [
                              FutureBuilder(
                                future: FirebaseFirestore.instance
                                    .collection('transaction')
                                    .where('status',
                                        isEqualTo: 'Menunggu Pelunasan')
                                    .get(),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return Column(
                                      children: [
                                        Container(
                                          height: 50,
                                          width: 50,
                                          child: Center(
                                            child: LottieBuilder.asset(
                                                'assets/lottieAnimations/loading_animation_2.json'),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 30,
                                        ),
                                        Text(
                                          'Sedang mengambil data',
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: Colors.black45,
                                          ),
                                        ),
                                        SizedBox(
                                          height: 30,
                                        ),
                                      ],
                                    );
                                  } else {
                                    List<QueryDocumentSnapshot>
                                        queryDocumentSnapshot =
                                        snapshot.data.docs;

                                    if (snapshot.data.docs.length == 0) {
                                      return Container();
                                    } else {
                                      return buildCountdownPayment(
                                          context, queryDocumentSnapshot);
                                    }
                                  }
                                },
                              ),
                              Container(
                                color: Colors.white,
                                width: MediaQuery.of(context).size.width,
                                child: Padding(
                                  padding: EdgeInsets.all(20.0),
                                  child: Text(
                                    'Transaksi Terbaru',
                                    style: TextStyle(
                                      color: Colors.black54,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              RecentTransaction(
                                user: widget.user,
                                userRepository: widget.userRepository,
                                transactionId: transactionIdList,
                                data: data,
                                recentDataList: dataList,
                                refresh: refreshingPage,
                              ),
                              SizedBox(
                                height: 100,
                              )
                            ],
                          ),
                        );
                      }
                    }
                  },
                ),
                SizedBox(
                  height: 30,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildCountdownPayment(BuildContext context,
      List<QueryDocumentSnapshot<Object>> queryDocumentSnapshot) {
    int currentIndex = 0;
    final CarouselController _controller = CarouselController();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 5, 10),
          child: Text(
            'Menunggu Pelunasan : ',
            style: TextStyle(
              color: Colors.black54,
              fontSize: 14,
              // fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Container(
          height: MediaQuery.of(context).size.height * 0.25,
          width: MediaQuery.of(context).size.width,
          child: CarouselSlider(
            options: CarouselOptions(
              height: MediaQuery.of(context).size.height * 0.25,
              enableInfiniteScroll: false,
              viewportFraction: 1,
              onPageChanged: (index, reason) {
                context.read<CountdowntimerCubit>().changeIndex(index);
              },
            ),
            items: queryDocumentSnapshot.map((i) {
              return Builder(
                builder: (BuildContext context) {
                  String transactionId = i.id;
                  String midtransId = i['midtransId'];
                  return FutureBuilder(
                    future: FirebaseFirestore.instance
                        .collection('midtrans')
                        .where('midtransId', isEqualTo: midtransId)
                        .get(),
                    builder: (context, midtransSnapshot) {
                      if (midtransSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return Container();
                      } else {
                        //timer
                        DateTime currentPhoneDate = DateTime.parse(
                            midtransSnapshot.data.docs[0]['expired_time']
                                .toDate()
                                .toString());
                        Timestamp myTimeStamp =
                            Timestamp.fromDate(currentPhoneDate);

                        return Container(
                          height: MediaQuery.of(context).size.height * 0.35,
                          width: MediaQuery.of(context).size.width,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.fromLTRB(20, 5, 10, 10),
                                child: CountdownTimer(
                                  endTime: myTimeStamp.millisecondsSinceEpoch,
                                  textStyle: GoogleFonts.openSans(
                                    fontSize: 40,
                                    color: primaryColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  onEnd: () {
                                    print('SET EXPIRED FROM TRANSACTION PAGE');

                                    // testing
                                    // FirebaseFirestore.instance
                                    //     .collection('transaction')
                                    //     .doc(i.id)
                                    //     .get()
                                    //     .then((value) {
                                    //   Map data = value.data();
                                    //   print('===============================');
                                    //   print(data);
                                    //   //   print(
                                    //   //       'SET EXPIRED FROM TRANSACTION PAGE');
                                    // });

                                    // DatabaseServices.setExpireTransactionStatus(
                                    //     transactionId);
                                  },
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.fromLTRB(20, 10, 5, 10),
                                child: Text(
                                  'Pembayaran dengan menggunakan ' +
                                      midtransSnapshot.data.docs[0]
                                          ['PaymentType'],
                                  style: TextStyle(
                                    color: Colors.black54,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              Padding(
                                padding: EdgeInsets.only(left: 20.0),
                                child: ConstrainedBox(
                                  constraints: BoxConstraints.tightFor(
                                    width:
                                        MediaQuery.of(context).size.width * 0.4,
                                  ),
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        PageTransition(
                                          type: PageTransitionType.rightToLeft,
                                          child: TransactionDetailParent(
                                              transactionId: transactionId,
                                              user: widget.user,
                                              userRepository:
                                                  widget.userRepository,
                                              refresh: refresh),
                                        ),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      primary: primaryColor,
                                    ),
                                    child: Text(
                                      'Lihat Detail',
                                      style: TextStyle(fontSize: 12),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        );
                      }
                    },
                  );
                },
              );
            }).toList(),
          ),
        ),
        BlocBuilder<CountdowntimerCubit, CountdowntimerState>(
          builder: (context, state) {
            if (state is CountdowntimerInitial) {
              return Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: queryDocumentSnapshot.asMap().entries.map((entry) {
                    return GestureDetector(
                      onTap: () => _controller.animateToPage(entry.key),
                      child: Container(
                        width: 8.0,
                        height: 8.0,
                        margin: EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 4.0),
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color:
                                (Theme.of(context).brightness == Brightness.dark
                                        ? Colors.white
                                        : Colors.black)
                                    .withOpacity(
                                        currentIndex == entry.key ? 0.9 : 0.4)),
                      ),
                    );
                  }).toList(),
                ),
              );
            } else if (state is CountdowntimerChangeIndex) {
              return Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: queryDocumentSnapshot.asMap().entries.map((entry) {
                    return GestureDetector(
                      onTap: () => _controller.animateToPage(entry.key),
                      child: Container(
                        width: 8.0,
                        height: 8.0,
                        margin: EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 4.0),
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color:
                                (Theme.of(context).brightness == Brightness.dark
                                        ? Colors.white
                                        : Colors.black)
                                    .withOpacity(
                                        state.index == entry.key ? 0.9 : 0.4)),
                      ),
                    );
                  }).toList(),
                ),
              );
            } else {
              return Container();
            }
          },
        ),
        SizedBox(height: 30),
      ],
    );
  }

  void getcurrentUser() async {
    final User user = auth.currentUser;
    setState(() {
      currentUserId = user.uid;
    });
  }

  Future getTransactionList() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('transaction')
        .where('status', isEqualTo: 'Menunggu konfirmasi')
        .where('userId2', isEqualTo: currentUserId)
        .orderBy('created', descending: true)
        .get();

    querySnapshot.docs.forEach((result) {
      if (!transactionList.contains(result.id)) {
        setState(() {
          transactionList.add(result.id);
        });
      }
    });
  }

  Future getAllTransactionId() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('transaction')
        .where('userId2', isEqualTo: currentUserId)
        .orderBy('created', descending: true)
        .get();

    querySnapshot.docs.forEach((result) {
      if (!transactionIdList.contains(result.id)) {
        setState(() {
          transactionIdList.add(result.id);
        });
      }
    });
  }

  void refresh(int index) {
    setState(() {
      current = index;
    });
  }

  void refreshingPage() {
    print('refreshing page');
    Navigator.pushReplacement(
      context,
      PageTransition(
        type: PageTransitionType.fade,
        child: CustomBottomNavigationBar(
          currentIndex: 2,
          user: widget.user,
          userRepository: widget.userRepository,
        ),
      ),
    );
  }
}
