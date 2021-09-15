import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:entry/entry.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_ecommerce/blocs/homeBloc/home_page_bloc.dart';
import 'package:flutter_ecommerce/blocs/homeBloc/home_page_event.dart';
import 'package:flutter_ecommerce/blocs/homeBloc/home_page_state.dart';
import 'package:flutter_ecommerce/repositories/DatabaseUser.dart';
import 'package:flutter_ecommerce/repositories/user_repository.dart';
import 'package:flutter_ecommerce/ui/pages/login_page.dart';
import 'package:flutter_ecommerce/ui/pages/user/profile/favorite/favorite_page.dart';
import 'package:flutter_ecommerce/utils/color_codes.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';
import 'package:wc_form_validators/wc_form_validators.dart';

class ProfilePageParent extends StatelessWidget {
  final User user;
  final UserRepository userRepository;

  ProfilePageParent({
    @required this.user,
    @required this.userRepository,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider<HomePageBloc>(
      create: (BuildContext context) =>
          HomePageBloc(userRepository: userRepository),
      child: ProfilePage(
        user: user,
        userRepository: userRepository,
      ),
    );
  }
}

class ProfilePage extends StatefulWidget {
  final User user;
  final UserRepository userRepository;

  ProfilePage({
    @required this.user,
    @required this.userRepository,
  });

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool isEditClick = false;
  bool isChanged = false;

  String initialName = '';
  String name;
  String phoneNumber;
  String alamat;
  String userId;

  final _formKey = GlobalKey<FormState>();

  String nameSaved;
  String phoneSaved;
  String addressSaved;

  HomePageBloc homePageBloc;

  void initState() {
    super.initState();
    userId = FirebaseAuth.instance.currentUser.uid;
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
    homePageBloc = BlocProvider.of<HomePageBloc>(context);

    return Scaffold(
      body: BlocListener<HomePageBloc, HomePageState>(
        listener: (context, state) {
          if (state is LogOutSuccessState) {
            Navigator.pop(context);
            navigateToLoginpPage(context);
          }
        },
        child: BlocBuilder<HomePageBloc, HomePageState>(
          builder: (context, state) {
            if (state is LogOutSuccessState) {
              return Container();
            } else {
              return Entry.opacity(
                duration: Duration(milliseconds: 1500),
                child: Stack(
                  children: [
                    streamBuilder(),
                    isChanged
                        ? GestureDetector(
                            onTap: () => validate(),
                            child: Align(
                              alignment: Alignment.bottomCenter,
                              child: Container(
                                height: 50,
                                width: MediaQuery.of(context).size.width,
                                decoration: BoxDecoration(
                                  color: primaryColor,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                margin: EdgeInsets.all(20),
                                child: Center(
                                  child: Text(
                                    'Simpan',
                                    style: GoogleFonts.roboto(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          )
                        : Container(),
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }

  Widget streamBuilder() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('user')
          .doc(FirebaseAuth.instance.currentUser.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: Container(
              height: 30,
              width: 30,
              margin: const EdgeInsets.only(right: 20.0),
              child: CircularProgressIndicator(
                valueColor: new AlwaysStoppedAnimation<Color>(primaryColor),
              ),
            ),
          );
        } else {
          var displayName = snapshot.data['username'];
          var displayPhoneNumber = snapshot.data['noHP'];

          return Form(
            key: _formKey,
            child: ListView(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  padding: EdgeInsets.all(20),
                  child: ListView(
                    physics: ClampingScrollPhysics(),
                    children: [
                      SizedBox(
                        height: 20,
                      ),
                      Row(
                        children: [
                          Container(
                            margin: EdgeInsets.only(left: 10),
                            height: 80,
                            width: 80,
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                image: NetworkImage(widget.user.photoURL),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 30,
                          ),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  displayName,
                                  style: GoogleFonts.roboto(
                                      fontSize: 18, color: Colors.black),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  displayPhoneNumber,
                                  style: GoogleFonts.roboto(
                                      fontSize: 15, color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Divider(
                        height: 70,
                        thickness: 1,
                        color: Colors.black,
                      ),
                      menuItem(context, 'Favorit', Icons.favorite, Colors.red,
                          navigateToFavoritePage),
                      menuItem(
                        context,
                        'Edit Profil',
                        Icons.person,
                        Colors.blue[900],
                        () {
                          setState(() {
                            isEditClick = !isEditClick;
                          });
                        },
                      ),
                      AnimatedContainer(
                        duration: Duration(milliseconds: 500),
                        height: isEditClick ? 300 : 0,
                        width:
                            isEditClick ? MediaQuery.of(context).size.width : 0,
                        child: ListView(
                          physics: ClampingScrollPhysics(),
                          shrinkWrap: true,
                          children: [
                            labelForm('Nama'),
                            Padding(
                              padding: EdgeInsets.fromLTRB(5, 10, 10, 10),
                              child: TextFormField(
                                initialValue: snapshot.data['username'],
                                style: GoogleFonts.roboto(fontSize: 15),
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.all(10),
                                  hintText: 'Masukkan Nama Pengguna',
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(
                                        color: Colors.grey, width: 1.0),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.grey, width: 1.0),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.red, width: 1.0),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  focusedErrorBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.red, width: 1.0),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  errorStyle: TextStyle(
                                    color: Colors.red,
                                    fontSize: 12,
                                    // backgroundColor: Colors.red,
                                  ),
                                ),
                                keyboardType: TextInputType.text,
                                validator: usernameValidator(),
                                onSaved: (newValue) {
                                  setState(() {
                                    nameSaved = newValue;
                                  });
                                },
                                onChanged: (value) {
                                  setState(() {
                                    isChanged = true;
                                  });
                                },
                              ),
                            ),
                            labelForm('No.HP'),
                            Padding(
                              padding: EdgeInsets.fromLTRB(5, 10, 10, 10),
                              child: TextFormField(
                                initialValue: snapshot.data['noHP'],
                                style: GoogleFonts.roboto(fontSize: 15),
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.all(10),
                                  hintText: 'Masukkan No.HP Pengguna',
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(
                                        color: Colors.grey, width: 1.0),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.grey, width: 1.0),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.red, width: 1.0),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  focusedErrorBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.red, width: 1.0),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  errorStyle: TextStyle(
                                    color: Colors.red,
                                    fontSize: 12,
                                    // backgroundColor: Colors.red,
                                  ),
                                ),
                                keyboardType: TextInputType.number,
                                validator: phoneNumberValidator(),
                                onSaved: (newValue) {
                                  setState(() {
                                    phoneSaved = newValue;
                                  });
                                },
                                onChanged: (value) {
                                  setState(() {
                                    isChanged = true;
                                  });
                                },
                              ),
                            ),
                            labelForm('Alamat'),
                            Padding(
                              padding: EdgeInsets.fromLTRB(5, 10, 10, 10),
                              child: TextFormField(
                                initialValue: snapshot.data['alamat'],
                                style: GoogleFonts.roboto(fontSize: 15),
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.all(10),
                                  hintText: 'Masukkan Alamat Pengguna',
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(
                                        color: Colors.grey, width: 1.0),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.grey, width: 1.0),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.red, width: 1.0),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  focusedErrorBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.red, width: 1.0),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  errorStyle: TextStyle(
                                    color: Colors.red,
                                    fontSize: 12,
                                    // backgroundColor: Colors.red,
                                  ),
                                ),
                                keyboardType: TextInputType.text,
                                validator: addressValidator(),
                                onSaved: (newValue) {
                                  setState(() {
                                    addressSaved = newValue;
                                  });
                                },
                                onChanged: (value) {
                                  setState(() {
                                    isChanged = true;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      menuItem(
                        context,
                        'Kontak Admin',
                        Icons.support_agent,
                        Colors.orange,
                        () {},
                      ),
                      menuItem(
                        context,
                        'Keluar',
                        Icons.power_settings_new_outlined,
                        Colors.red,
                        () async {
                          showAlertDialog(context);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }

  Widget labelForm(String label) {
    return Padding(
      padding: EdgeInsets.fromLTRB(5, 10, 10, 0),
      child: Text(
        label,
        style: GoogleFonts.roboto(fontSize: 13, color: Colors.grey),
      ),
    );
  }

  Widget menuItem(BuildContext context, String label, IconData icon,
      Color color, Function function) {
    return InkWell(
      onTap: () async {
        function();
      },
      child: Container(
        height: 50,
        width: MediaQuery.of(context).size.width,
        child: Row(
          children: [
            Icon(
              icon,
              color: color,
            ),
            SizedBox(
              width: 10,
            ),
            Text(
              label,
              style: GoogleFonts.openSans(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  void navigateToFavoritePage() {
    Navigator.push(
      context,
      PageTransition(
        type: PageTransitionType.rightToLeftWithFade,
        alignment: Alignment.bottomCenter,
        child: FavoritePage(
          user: widget.user,
        ),
      ),
    );
  }

  usernameValidator() {
    return Validators.compose([
      Validators.required('Nama Pengguna tidak boleh kosong'),
      Validators.minLength(
          3, 'Nama Pengguna tidak boleh kurang dari 3 karakter'),
      Validators.maxLength(
          16, 'Nama Pengguna tidak boleh lebih dari 16 karakter'),
      Validators.patternRegExp(
          RegExp(r"^[A-Za-z ]+$"), 'Tidak boleh mengandung Angka atau Simbol')
    ]);
  }

  phoneNumberValidator() {
    return Validators.compose([
      Validators.required('Nomor HP tidak boleh kosong'),
      Validators.minLength(10, 'Nomor HP tidak boleh kurang dari 10 karakter'),
      Validators.maxLength(15, 'Nomor HP tidak boleh lebih dari 15 karakter'),
    ]);
  }

  addressValidator() {
    return Validators.compose([
      Validators.required('Alamat Pengguna tidak boleh kosong'),
      Validators.minLength(
          5, 'Alamat Pengguna tidak boleh kurang dari 5 karakter'),
      Validators.maxLength(
          50, 'Alamat Pengguna tidak boleh lebih dari 50 karakter'),
      Validators.patternRegExp(
          RegExp(r"^[A-Za-z .0-9]+$"), 'Tidak boleh mengandung Simbol')
    ]);
  }

  void validate() {
    if (_formKey.currentState.validate()) {
      //set value
      setState(() {
        isChanged = false;
        isEditClick = false;
      });

      //dismiss keyboard view
      FocusScope.of(context).unfocus();

      //show snackbar
      Fluttertoast.showToast(
        msg: 'Menyimpan Data',
        gravity: ToastGravity.SNACKBAR,
        backgroundColor: Colors.black45,
      );
      _formKey.currentState.save();
      DatabaseUser.updateProfile(nameSaved, phoneSaved, addressSaved, userId);

      // print(addressForm);
    }
  }

  String checkUsername(String value) {
    if (value.isEmpty) {
      return 'Kolom tidak boleh kosong';
    } else if (value.length < 5) {
      return 'Nama tidak boleh kurang dari 5 karakter';
    }

    return null;
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
    // set up the buttons
    Widget cancelButton = ElevatedButton(
      style: ElevatedButton.styleFrom(
        primary: Colors.white,
        elevation: 0.0,
      ),
      child: Text(
        "Tidak",
        style: TextStyle(
          color: Colors.red,
        ),
      ),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    Widget continueButton = ElevatedButton(
      style: ElevatedButton.styleFrom(
        primary: Colors.white,
        elevation: 0.0,
      ),
      child: Text(
        "Keluar",
        style: TextStyle(
          color: Colors.blue,
        ),
      ),
      onPressed: () {
        homePageBloc.add(LogOutEvent());
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Logout"),
      content: Text("Apakah kamu yakin ingin logout dari akun ini?"),
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
