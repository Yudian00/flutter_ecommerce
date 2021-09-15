import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ecommerce/repositories/user_repository.dart';
import 'package:flutter_ecommerce/ui/pages/login_page.dart';
import 'package:flutter_ecommerce/ui/pages/noRoles/create_identity_page.dart';
import 'package:flutter_ecommerce/utils/color_codes.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:page_transition/page_transition.dart';

class RegisterRoles extends StatefulWidget {
  final User user;
  final UserRepository userRepository;

  RegisterRoles({
    @required this.user,
    @required this.userRepository,
  });

  @override
  _RegisterRolesState createState() => _RegisterRolesState();
}

class _RegisterRolesState extends State<RegisterRoles> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ListView(
        physics: ClampingScrollPhysics(),
        children: [
          Container(
            margin: EdgeInsets.only(top: 100),
            height: 200,
            width: 200,
            child: LottieBuilder.asset('assets/lottieAnimations/welcome.json'),
          ),
          Center(
            child: Padding(
              padding: EdgeInsets.only(
                top: 50.0,
              ),
              child: Text(
                'Selamat Datang',
                style: GoogleFonts.roboto(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                'Sepertinya kamu adalah pengguna baru. Yuk, beritahu kami identitas kamu',
                textAlign: TextAlign.center,
                style: GoogleFonts.roboto(
                  fontSize: 15,
                  color: Colors.grey[600],
                ),
              ),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          GestureDetector(
            onTap: () => navigateToCreateIdentity(),
            child: Container(
              height: 50,
              margin: EdgeInsets.symmetric(horizontal: 20),
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white),
                color: primaryColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  'Selanjutnya',
                  style: GoogleFonts.hammersmithOne(color: Colors.white),
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () => logout(),
            child: Container(
              margin: EdgeInsets.all(20),
              child: Center(
                child: Text(
                  'Ganti akun',
                  style: GoogleFonts.hammersmithOne(color: primaryColor),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void logout() async {
    await widget.userRepository.signOut();
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => LoginPageParent(
            userRepository: widget.userRepository,
          ),
        ));
  }

  void navigateToCreateIdentity() {
    Navigator.push(
        context,
        PageTransition(
            type: PageTransitionType.rightToLeft,
            child: CreateIdentity(
              user: widget.user,
              userRepository: widget.userRepository,
            )));
  }
}
