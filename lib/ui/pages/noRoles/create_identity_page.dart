import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ecommerce/repositories/DatabaseUser.dart';
import 'package:flutter_ecommerce/repositories/user_repository.dart';
import 'package:flutter_ecommerce/ui/pages/user/bottom_navigation_bar.dart';
import 'package:flutter_ecommerce/utils/color_codes.dart';
import 'package:page_transition/page_transition.dart';
import 'package:wc_form_validators/wc_form_validators.dart';

class CreateIdentity extends StatefulWidget {
  final User user;
  final UserRepository userRepository;

  CreateIdentity({
    @required this.user,
    @required this.userRepository,
  });

  @override
  _CreateIdentityState createState() => _CreateIdentityState();
}

class _CreateIdentityState extends State<CreateIdentity> {
  String username;
  String userPhoneNumber;
  String address;
  bool isFilled = false;

  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Form(
        key: _formKey,
        child: ListView(
          physics: ClampingScrollPhysics(),
          children: [
            SizedBox(
              height: 50,
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                'Isi identitas di bawah ini untuk mempermudah penjual mengetahui identitas pembeli',
                textAlign: TextAlign.start,
              ),
            ),
            Padding(
              padding:
                  EdgeInsets.only(top: 20, bottom: 10, right: 20, left: 20),
              child: TextFormField(
                style: TextStyle(fontSize: 20),
                decoration: InputDecoration(
                  prefixIcon: Icon(
                    Icons.person,
                    size: 30,
                  ),
                  hintText: 'Nama Pengguna',
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey, width: 1.0),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.red, width: 2.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: primaryColor, width: 1.0),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: primaryColor, width: 1.0),
                  ),
                ),
                validator: usernameValidator(),
                onChanged: (value) {
                  setState(() {
                    username = value;
                  });
                },
              ),
            ),
            Padding(
              padding:
                  EdgeInsets.only(top: 20, bottom: 10, right: 20, left: 20),
              child: TextFormField(
                keyboardType: TextInputType.number,
                style: TextStyle(fontSize: 20),
                decoration: InputDecoration(
                  prefixIcon: Icon(
                    Icons.phone,
                    size: 30,
                  ),
                  hintText: 'No.HP',
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey, width: 1.0),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.red, width: 2.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: primaryColor, width: 1.0),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: primaryColor, width: 1.0),
                  ),
                  // border: InputBorder.none,
                  errorStyle: TextStyle(),
                ),
                validator: phoneNumberValidator(),
                onChanged: (value) {
                  setState(() {
                    userPhoneNumber = value;
                  });
                },
              ),
            ),
            Padding(
              padding:
                  EdgeInsets.only(top: 20, bottom: 10, right: 20, left: 20),
              child: TextFormField(
                style: TextStyle(fontSize: 20),
                decoration: InputDecoration(
                  prefixIcon: Icon(
                    Icons.person,
                    size: 30,
                  ),
                  hintText: 'Alamat',
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey, width: 1.0),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.red, width: 2.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: primaryColor, width: 1.0),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: primaryColor, width: 1.0),
                  ),
                ),
                validator: addressValidator(),
                onChanged: (value) {
                  setState(() {
                    address = value;
                  });
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: GestureDetector(
        onTap: () => validating(),
        child: Container(
          margin: EdgeInsets.only(bottom: 30),
          height: 50,
          width: 50,
          decoration: BoxDecoration(
            color: primaryColor,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Icon(
              Icons.arrow_forward,
              color: Colors.white,
            ),
          ),
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

  void validating() {
    if (_formKey.currentState.validate()) {
      try {
        widget.userRepository.getCurrentUser().then((value) {
          DatabaseUser.editUsernameAndPhoneNumber(
              username, userPhoneNumber, address, value.uid);
        });
        Navigator.push(
            context,
            PageTransition(
                type: PageTransitionType.fade,
                child: CustomBottomNavigationBar(
                  currentIndex: 0,
                  user: widget.user,
                  userRepository: widget.userRepository,
                )));
      } catch (e) {
        print(e);
      }
    }
  }
}
