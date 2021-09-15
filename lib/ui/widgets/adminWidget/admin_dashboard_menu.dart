import 'package:badges/badges.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ecommerce/ui/pages/admin/ambil/ambil_produk.dart';
import 'package:flutter_ecommerce/ui/pages/admin/history/riwayat_transaksi_page.dart';
import 'package:flutter_ecommerce/ui/pages/admin/kategori/categories_page.dart';
import 'package:flutter_ecommerce/ui/pages/admin/konfirmasi/detail_option.dart';
import 'package:flutter_ecommerce/ui/pages/admin/lunas/payment_complete.dart';
import 'package:flutter_ecommerce/ui/pages/admin/mengirim/mengirim_produk.dart';
import 'package:flutter_ecommerce/ui/pages/admin/menunggu/waiting_payment.dart';
import 'package:flutter_ecommerce/ui/pages/admin/produk/admin_product_page.dart';
import 'package:flutter_ecommerce/utils/mediaQuery.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';

class AdminDashboardMenu extends StatelessWidget {
  final List transactionIdList;

  AdminDashboardMenu({
    @required this.transactionIdList,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      child: GridView.count(
        shrinkWrap: true,
        crossAxisCount: 4,
        children: [
          // Pengiriman
          StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('transaction')
                .where('status', isEqualTo: 'Sedang Mengirim')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.delivery_dining_sharp,
                        color: Colors.deepOrange[300],
                        size: 25,
                      ),
                      SizedBox(
                        height: getCurrentHeight(context, 10),
                      ),
                      Text(
                        'Mengirim',
                        style: GoogleFonts.roboto(
                          fontSize: 13,
                        ),
                      )
                    ],
                  ),
                );
              } else {
                if (snapshot.data.docs.length == 0) {
                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          PageTransition(
                            type: PageTransitionType.fade,
                            child: DeliveryProductPage(),
                          ),
                        );
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.delivery_dining_sharp,
                            color: Colors.deepOrange[300],
                            size: 25,
                          ),
                          SizedBox(
                            height: getCurrentHeight(context, 10),
                          ),
                          Text(
                            'Mengirim',
                            style: GoogleFonts.roboto(
                              fontSize: 13,
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                } else {
                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          PageTransition(
                            type: PageTransitionType.fade,
                            child: DeliveryProductPage(),
                          ),
                        );
                      },
                      child: Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Badge(
                              badgeContent: Text(
                                snapshot.data.docs.length.toString(),
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                              child: Icon(
                                Icons.delivery_dining_sharp,
                                color: Colors.deepOrange[300],
                                size: 25,
                              ),
                            ),
                            SizedBox(
                              height: getCurrentHeight(context, 10),
                            ),
                            Text(
                              'Mengirim',
                              style: GoogleFonts.roboto(
                                fontSize: 13,
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  );
                }
              }
            },
          ),

          // Ambil
          StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('transaction')
                .where('status', isEqualTo: 'Ambil di toko')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.store,
                        color: Colors.blue,
                        size: 25,
                      ),
                      SizedBox(
                        height: getCurrentHeight(context, 10),
                      ),
                      Text(
                        'Ambil',
                        style: GoogleFonts.roboto(
                          fontSize: 13,
                        ),
                      )
                    ],
                  ),
                );
              } else {
                if (snapshot.data.docs.length == 0) {
                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          PageTransition(
                            type: PageTransitionType.fade,
                            child: AmbilProductPage(),
                          ),
                        );
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.store,
                            color: Colors.blue,
                            size: 25,
                          ),
                          SizedBox(
                            height: getCurrentHeight(context, 10),
                          ),
                          Text(
                            'Ambil',
                            style: GoogleFonts.roboto(
                              fontSize: 13,
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                } else {
                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          PageTransition(
                            type: PageTransitionType.fade,
                            child: AmbilProductPage(),
                          ),
                        );
                      },
                      child: Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Badge(
                              badgeContent: Text(
                                snapshot.data.docs.length.toString(),
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                              child: Icon(
                                Icons.store,
                                color: Colors.blue,
                                size: 25,
                              ),
                            ),
                            SizedBox(
                              height: getCurrentHeight(context, 10),
                            ),
                            Text(
                              'Ambil',
                              style: GoogleFonts.roboto(
                                fontSize: 13,
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  );
                }
              }
            },
          ),

          // pembayaran lunas
          StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('transaction')
                .where('status', isEqualTo: 'Pembayaran Lunas')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.task_alt_sharp,
                        color: Colors.green,
                        size: 25,
                      ),
                      SizedBox(
                        height: getCurrentHeight(context, 10),
                      ),
                      Text(
                        'Lunas',
                        style: GoogleFonts.roboto(
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                );
              } else {
                if (snapshot.data.docs.length == 0) {
                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          PageTransition(
                              type: PageTransitionType.rightToLeft,
                              child: PaymentComplete()),
                        );
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.task_alt_sharp,
                            color: Colors.green,
                            size: 25,
                          ),
                          SizedBox(
                            height: getCurrentHeight(context, 10),
                          ),
                          Text(
                            'Lunas',
                            style: GoogleFonts.roboto(
                              fontSize: 13,
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                } else {
                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          PageTransition(
                              type: PageTransitionType.fade,
                              child: PaymentComplete()),
                        );
                      },
                      child: Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Badge(
                              badgeContent: Text(
                                snapshot.data.docs.length.toString(),
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                              child: Icon(
                                Icons.task_alt_sharp,
                                color: Colors.green,
                                size: 25,
                              ),
                            ),
                            SizedBox(
                              height: getCurrentHeight(context, 10),
                            ),
                            Text(
                              'Lunas',
                              style: GoogleFonts.roboto(
                                fontSize: 13,
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  );
                }
              }
            },
          ),

          // Konfirmasi
          StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('transaction')
                .where('status', isEqualTo: 'Menunggu Pembayaran')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.timer,
                        color: Colors.teal,
                        size: 25,
                      ),
                      SizedBox(
                        height: getCurrentHeight(context, 10),
                      ),
                      Text(
                        'Menunggu',
                        style: GoogleFonts.roboto(
                          fontSize: 13,
                        ),
                      )
                    ],
                  ),
                );
              } else {
                if (snapshot.data.docs.length == 0) {
                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          PageTransition(
                              type: PageTransitionType.rightToLeft,
                              child: WaitingPayment()),
                        );
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.timer,
                            color: Colors.teal,
                            size: 25,
                          ),
                          SizedBox(
                            height: getCurrentHeight(context, 10),
                          ),
                          Text(
                            'Menunggu',
                            style: GoogleFonts.roboto(
                              fontSize: 13,
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                } else {
                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          PageTransition(
                              type: PageTransitionType.fade,
                              child: WaitingPayment()),
                        );
                      },
                      child: Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Badge(
                              badgeContent: Text(
                                snapshot.data.docs.length.toString(),
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                              child: Icon(
                                Icons.timer,
                                color: Colors.teal,
                                size: 25,
                              ),
                            ),
                            SizedBox(
                              height: getCurrentHeight(context, 10),
                            ),
                            Text(
                              'Menunggu',
                              style: GoogleFonts.roboto(
                                fontSize: 13,
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  );
                }
              }
            },
          ),

          // Konfirmasi
          StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('transaction')
                .where('status', isEqualTo: 'Menunggu konfirmasi')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.timer,
                        color: Colors.orange,
                        size: 25,
                      ),
                      SizedBox(
                        height: getCurrentHeight(context, 10),
                      ),
                      Text(
                        'Konfirmasi',
                        style: GoogleFonts.roboto(
                          fontSize: 13,
                        ),
                      )
                    ],
                  ),
                );
              } else {
                if (snapshot.data.docs.length == 0) {
                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          PageTransition(
                            type: PageTransitionType.rightToLeft,
                            child: DetailOption(
                              length: snapshot.data.docs.length,
                              transactionIdList: transactionIdList,
                            ),
                          ),
                        );
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.timer,
                            color: Colors.orange,
                            size: 25,
                          ),
                          SizedBox(
                            height: getCurrentHeight(context, 10),
                          ),
                          Text(
                            'Konfirmasi',
                            style: GoogleFonts.roboto(
                              fontSize: 13,
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                } else {
                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                            context,
                            PageTransition(
                                type: PageTransitionType.fade,
                                child: DetailOption(
                                  length: snapshot.data.docs.length,
                                  transactionIdList: transactionIdList,
                                )));
                      },
                      child: Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Badge(
                              badgeContent: Text(
                                snapshot.data.docs.length.toString(),
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                              child: Icon(
                                Icons.timer,
                                color: Colors.orange,
                                size: 25,
                              ),
                            ),
                            SizedBox(
                              height: getCurrentHeight(context, 10),
                            ),
                            Text(
                              'Konfirmasi',
                              style: GoogleFonts.roboto(
                                fontSize: 13,
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  );
                }
              }
            },
          ),

          // Produk
          menuItem(context, () {
            Navigator.push(
              context,
              PageTransition(
                type: PageTransitionType.fade,
                child: AdminProductPage(),
              ),
            );
          }, Icons.checkroom, Colors.indigo, 'Produk'),

          // Riwayat
          menuItem(context, () {
            Navigator.push(
              context,
              PageTransition(
                type: PageTransitionType.fade,
                child: HistoryTransaction(),
              ),
            );
          }, Icons.sticky_note_2_outlined, Colors.orange, 'Riwayat'),

          // Kategori
          menuItem(context, () {
            Navigator.push(
              context,
              PageTransition(
                type: PageTransitionType.fade,
                child: CategoriesPage(),
              ),
            );
          }, Icons.category, Colors.indigo, 'Kategori'),
        ],
      ),
    );
  }

  Widget menuItem(BuildContext context, Function action, IconData icon,
      Color iconColor, String label) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => action(),
        child: Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: iconColor,
                size: 25,
              ),
              SizedBox(
                height: getCurrentHeight(context, 10),
              ),
              Text(
                label,
                style: GoogleFonts.roboto(
                  fontSize: 13,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
