import 'dart:async';
import 'package:badges/badges.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_ecommerce/blocs/homeBloc/home_page_bloc.dart';
import 'package:flutter_ecommerce/blocs/homeBloc/home_page_event.dart';
import 'package:flutter_ecommerce/blocs/homeBloc/home_page_state.dart';
import 'package:flutter_ecommerce/cubit/cartCubit/cart_cubit.dart';
import 'package:flutter_ecommerce/repositories/DatabaseServices.dart';
import 'package:flutter_ecommerce/repositories/DatabaseUser.dart';
import 'package:flutter_ecommerce/repositories/cart_list.dart';
import 'package:flutter_ecommerce/ui/pages/user/cart/cart_page.dart';
import 'package:flutter_ecommerce/ui/pages/login_page.dart';
import 'package:flutter_ecommerce/ui/pages/user/search/search_page.dart';
import 'package:flutter_ecommerce/ui/widgets/HomeWidget/DiscountListView.dart';
import 'package:flutter_ecommerce/ui/widgets/HomeWidget/product_tab.dart';
import 'package:flutter_ecommerce/ui/widgets/HomeWidget/tutorial_card.dart';
import 'package:flutter_ecommerce/utils/color_codes.dart';
import 'package:flutter_ecommerce/utils/mediaQuery.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:meta/meta.dart';
import 'package:flutter_ecommerce/repositories/user_repository.dart';
import 'package:tab_indicator_styler/tab_indicator_styler.dart';

class HomePageParent extends StatelessWidget {
  final User user;
  final UserRepository userRepository;

  HomePageParent({@required this.user, @required this.userRepository});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<HomePageBloc>(
      create: (BuildContext context) =>
          HomePageBloc(userRepository: userRepository),
      child: HomePage(
        user: user,
        userRepository: userRepository,
      ),
    );
  }
}

// ignore: must_be_immutable
class HomePage extends StatefulWidget {
  User user;
  UserRepository userRepository;

  HomePage({
    @required this.user,
    @required this.userRepository,
  });

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  HomePageBloc homePageBloc;
  List discountProductID = [];
  List productID = [];
  List itemList = [];
  Map productData = {};
  bool isLoading = true;
  bool isOnEffect = true;
  DocumentSnapshot userSnapshot;
  String searchText;

  int currentMenu = 0;

  //bottom navigation bar index
  int currentIndex = 0;

  //Snackbar
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  void initState() {
    super.initState();
    getToken();
    getCurrentUserInfo();
    getAllProductData();
    getProductData();
  }

  void dispose() {
    print('Disposing home route');
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
    //homebloc
    homePageBloc = BlocProvider.of<HomePageBloc>(context);

    return BlocListener<HomePageBloc, HomePageState>(
      listener: (context, state) {
        if (state is LogOutSuccessState) {
          Navigator.of(context).pop();
          navigateToLoginpPage(context);
        }
      },
      child: DefaultTabController(
        length: 4,
        child: Scaffold(
          appBar: AppBar(
            toolbarHeight: 0.0,
            backgroundColor: Colors.white,
          ),
          backgroundColor: Colors.white,
          key: _scaffoldKey,
          body: _buildInitialUi(),
        ),
      ),
    );
  }

  // **** WIDGET ****

  Widget _buildInitialUi() {
    return BlocProvider(
      create: (BuildContext context) => CartCubit(),
      child: ListView(
        children: <Widget>[
          //SEARCH BAR
          searchBar(),
          subHeading(),
          tabBar(),
          tabBarView(),
          DiscoutListView(user: widget.user, refresh: refresh),
          TutorialCard(),
          SizedBox(
            height: 100,
          ),
        ],
      ),
    );
  }

  Widget searchBar() {
    final _formKey = GlobalKey<FormState>();
    return Form(
      key: _formKey,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(getCurrentHeight(context, 20),
                getCurrentHeight(context, 30), 0, 0),
            child: Container(
              width: MediaQuery.of(context).size.width * 0.6,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextFormField(
                onChanged: (value) {
                  searchText = value;
                },
                validator: (value) {
                  if (value.isEmpty) {
                    return 'kamu belum memasukkan keyword';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  isCollapsed: false,
                  contentPadding:
                      EdgeInsets.only(left: 20, right: 20, bottom: 20),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide(color: Colors.grey, width: 1.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey, width: 1.0),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.red, width: 1.0),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.red, width: 1.0),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  errorStyle: TextStyle(
                    color: Colors.red,
                    fontSize: 12,
                    // backgroundColor: Colors.red,
                  ),
                  hintText: 'Cari apa?',
                ),
              ),
            ),
          ),
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 20.0, left: 20),
                child: GestureDetector(
                  onTap: () {
                    if (_formKey.currentState.validate()) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SearchResultPage(
                            user: widget.user,
                            productData: productData,
                            productID: productID,
                            itemList: itemList,
                            searchItem: searchText.isEmpty ? ' ' : searchText,
                          ),
                        ),
                      );
                    }
                  },
                  child: Icon(
                    Icons.search,
                    color: primaryColor,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20.0, left: 10, right: 20),
                child: IconButton(
                  icon: Badge(
                    badgeContent: Text(
                      cartProduct.length.toString(),
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    child: Icon(
                      Icons.shopping_cart_outlined,
                      color: primaryColor,
                    ),
                    badgeColor: primaryColor,
                  ),
                  onPressed: () => Navigator.of(context)
                      .push(
                        MaterialPageRoute(
                          builder: (context) => CartPageParent(
                            refresh: refresh,
                            user: widget.user,
                            userRepository: widget.userRepository,
                          ),
                        ),
                      )
                      .then((value) => refresh()),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget subHeading() {
    return Container(
      margin: EdgeInsets.fromLTRB(20, 20, 10, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Temukan',
            style: GoogleFonts.karla(
              fontSize: 25,
              color: Colors.black,
            ),
          ),
          Row(
            children: [
              Text(
                'Produk ',
                style: GoogleFonts.karla(
                  fontSize: 25,
                  color: Colors.black,
                ),
              ),
              Text(
                'Terbaru',
                style: GoogleFonts.karla(
                  fontSize: 25,
                  color: primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget tabBar() {
    return Padding(
      padding: EdgeInsets.only(left: 20.0),
      child: TabBar(
        labelColor: Colors.white,
        indicatorColor: primaryColor,
        // indicatorSize: TabBarIndicatorSize.label,
        unselectedLabelColor: Colors.grey[400],
        labelPadding: EdgeInsets.symmetric(horizontal: 30),
        labelStyle: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
        isScrollable: true,
        indicator: RectangularIndicator(
          horizontalPadding: 10,
          verticalPadding: 5,
          color: primaryColor,
          bottomLeftRadius: 100,
          bottomRightRadius: 100,
          topLeftRadius: 100,
          topRightRadius: 100,
        ),
        tabs: [
          Container(
            child: Tab(
              text: 'Wanita',
            ),
          ),
          Container(
            child: Tab(
              text: 'Pria',
            ),
          ),
          Container(
            child: Tab(
              text: 'Kemeja',
            ),
          ),
          Container(
            child: Tab(
              text: 'Celana',
            ),
          ),
        ],
      ),
    );
  }

  Widget tabBarView() {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.55,
      child: TabBarView(
        children: [
          productTab('Wanita'),
          productTab('Pria'),
          Container(),
          Container(),
        ],
      ),
    );
  }

  Widget productTab(String category) {
    return ProductTab(user: widget.user, refresh: refresh, category: category);
  }

  // **** FUNCTION ****

  Future<void> getCurrentUserInfo() async {
    User userData = FirebaseAuth.instance.currentUser;

    // fecth userid information
    DocumentSnapshot snapshot =
        await DatabaseServices.getUserInfo(userData.uid);

    setState(() {
      userSnapshot = snapshot;
    });
  }

  void changeMenuIndex(int index) {
    setState(() {
      currentMenu = index;
    });
  }

  void refresh() {
    print('refreshing cart item(s)');
    setState(() {});
  }

  void getAllProductData() {
    itemList = [];

    final docRef = FirebaseFirestore.instance
        .collection('product')
        .where('status', isEqualTo: 'tersedia')
        .get();

    docRef.then((snapshot) {
      snapshot.docs.forEach((doc) {
        itemList.add(doc.data());
      });
    });
  }

  Future<void> getProductData() async {
    productID = [];
    productData = {};

    QuerySnapshot docRef = await FirebaseFirestore.instance
        .collection('product')
        .where('status', isEqualTo: 'tersedia')
        .get();

    docRef.docs.forEach((result) {
      productID.add(result.id);
    });

    for (var i = 0; i < productID.length; i++) {
      productData.putIfAbsent(productID[i], () => itemList[i]);
    }
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

  showAlertDialog(BuildContext context) {
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text('Keluar'),
      content: Text("kamu yakin ingin keluar sekarang?"),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                "Tidak",
                style:
                    TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(
              width: 40,
            ),
            TextButton(
              onPressed: () {
                homePageBloc.add(LogOutEvent());
              },
              child: Text(
                "Yup!",
                style:
                    TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(
              width: 40,
            ),
          ],
        )
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
}
