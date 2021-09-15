import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ecommerce/repositories/user_repository.dart';
import 'package:flutter_ecommerce/ui/pages/user/checkout/checkout_page.dart';
import 'package:flutter_ecommerce/utils/color_codes.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';
import 'package:wc_form_validators/wc_form_validators.dart';

class DetailAddressDelivery extends StatefulWidget {
  final User user;
  final UserRepository userRepository;
  final String userId;
  final String provinsi;
  final String kabupaten;
  final String kecamatan;
  final Map mapCart;
  final int totalPrice;

  DetailAddressDelivery({
    @required this.user,
    @required this.userId,
    @required this.userRepository,
    @required this.kabupaten,
    @required this.kecamatan,
    @required this.provinsi,
    @required this.mapCart,
    @required this.totalPrice,
  });

  @override
  _DetailAddressDeliveryState createState() => _DetailAddressDeliveryState();
}

class _DetailAddressDeliveryState extends State<DetailAddressDelivery> {
  String initialAlamat;
  String initialNama;

  var userData;
  final _formKey = GlobalKey<FormState>();

  String _alamat;
  String _namaPenerima;
  String _noHp;

  TextEditingController kodePosController = TextEditingController();
  TextEditingController catatanController = TextEditingController();

  void initState() {
    super.initState();
  }

  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Pengiriman',
          style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 21, color: Colors.black),
        ),
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: NotificationListener<OverscrollIndicatorNotification>(
        // ignore: missing_return
        onNotification: (overscroll) {
          overscroll.disallowGlow();
        },

        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(new FocusNode());
          },
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: FutureBuilder(
              future: futureUserData().then((snapshot) {
                userData = snapshot.data();
              }),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                } else {
                  return Form(
                    key: _formKey,
                    child: ListView(
                      physics: ClampingScrollPhysics(),
                      children: [
                        Row(
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
                                'Lokasi pengiriman : ' +
                                    widget.kecamatan +
                                    ', ' +
                                    widget.kabupaten +
                                    ', ' +
                                    widget.provinsi,
                                style: TextStyle(
                                    color: Colors.black45,
                                    fontSize: 13,
                                    height: 1.5),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 30,
                        ),
                        Text(
                          'Detail Alamat Pengiriman',
                          style: TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        TextFormField(
                          keyboardType: TextInputType.number,
                          maxLength: 7,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          decoration: InputDecoration(
                            hintText: 'Kode Pos',
                            hintStyle: TextStyle(
                              fontSize: 11,
                              color: Colors.black45,
                            ),
                            border: OutlineInputBorder(),
                          ),
                          controller: kodePosController,
                          validator: Validators.compose([
                            Validators.required('Kode pos tidak boleh kosong'),
                            Validators.minLength(
                                4, 'Format kode pos tidak benar')
                          ]),
                          onSaved: (newValue) {
                            kodePosController.text = newValue;
                          },
                        ),
                        SizedBox(
                          height: 30,
                        ),
                        TextFormField(
                          initialValue: userData['alamat'],
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.black87,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Alamat Lengkap',
                            hintStyle: TextStyle(
                              fontSize: 11,
                              color: Colors.black45,
                            ),
                            border: OutlineInputBorder(),
                          ),
                          validator: Validators.compose([
                            Validators.required('Alamat tidak boleh kosong'),
                          ]),
                          onSaved: (newValue) {
                            _alamat = newValue;
                          },
                        ),
                        SizedBox(
                          height: 50,
                        ),
                        Text(
                          'Detail Informasi Penerima',
                          style: TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        TextFormField(
                          initialValue: userData['username'],
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.black87,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Nama Penerima',
                            hintStyle: TextStyle(
                              fontSize: 11,
                              color: Colors.black45,
                            ),
                            border: OutlineInputBorder(),
                          ),
                          onSaved: (newValue) {
                            _namaPenerima = newValue;
                          },
                          validator: Validators.compose([
                            Validators.required(
                                'Nama penerima tidak boleh kosong'),
                          ]),
                        ),
                        SizedBox(
                          height: 50,
                        ),
                        TextFormField(
                          keyboardType: TextInputType.number,
                          maxLength: 13,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          initialValue: userData['noHP'],
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.black87,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Nomor HP',
                            hintStyle: TextStyle(
                              fontSize: 11,
                              color: Colors.black45,
                            ),
                            border: OutlineInputBorder(),
                          ),
                          onSaved: (newValue) {
                            _noHp = newValue;
                          },
                          validator: Validators.compose([
                            Validators.required('Nomor HP tidak boleh kosong'),
                            Validators.min(10, 'Nomor HP tidak sesuai format')
                          ]),
                        ),
                        SizedBox(
                          height: 50,
                        ),
                        Text(
                          'Catatan Pemesanan',
                          style: TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        TextFormField(
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.black87,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Catatan Pemesanan',
                            hintStyle: TextStyle(
                              fontSize: 11,
                              color: Colors.black45,
                            ),
                            border: OutlineInputBorder(),
                          ),
                          controller: catatanController,
                          onSaved: (newValue) {
                            catatanController.text = newValue;
                          },
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          'Catatan Pemesanan dapat dikosongkan jika tidak ada tambahan atau permintaan khusus',
                          style: TextStyle(
                            color: Colors.black45,
                            fontSize: 10,
                            height: 1.5,
                          ),
                        ),
                        SizedBox(
                          height: 30,
                        ),
                        ElevatedButton(
                          onPressed: () => validate(),
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
                        SizedBox(
                          height: 50,
                        ),
                      ],
                    ),
                  );
                }
              },
            ),
          ),
        ),
      ),
    );
  }

  void validate() {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      print('DOL');
      print(_namaPenerima);

      print(_noHp);

      print(_alamat);

      print(kodePosController);

      print(catatanController);

      print('=====================');

      print(widget.mapCart);
      print(widget.totalPrice);

      String address =
          widget.kecamatan + ', ' + widget.kabupaten + ', ' + widget.provinsi;
      // If the form is valid, display a snackbar. In the real world,
      // you'd often call a server or save the information in a database.
      Navigator.push(
        context,
        PageTransition(
          type: PageTransitionType.rightToLeft,
          child: ConfirmationPage(
            metodePembayaran: 'Transfer',
            address: address,
            detailAlamat: _alamat,
            kodepos: kodePosController.text,
            note: catatanController.text,
            refresh: refresh,
            user: widget.user,
            userRepository: widget.userRepository,
            username: _namaPenerima,
            userPhoneNumber: _noHp,
            userId: widget.userId,
            mapCart: widget.mapCart,
            totalPrice: widget.totalPrice,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Form tidak boleh kosong'),
          backgroundColor: Colors.red[300],
        ),
      );
    }
  }

  void refresh() {
    setState(() {});
  }

  Future<DocumentSnapshot> futureUserData() {
    final FirebaseAuth auth = FirebaseAuth.instance;

    final User user = auth.currentUser;
    final uid = user.uid;

    Future<DocumentSnapshot> userData =
        FirebaseFirestore.instance.collection('user').doc(uid).get();

    return userData;
  }
}
