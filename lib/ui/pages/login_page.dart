import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ecommerce/ui/pages/admin/admin_dashboard.dart';
import 'package:flutter_ecommerce/blocs/loginBloc/login_event.dart';
import 'package:flutter_ecommerce/blocs/loginBloc/login_state.dart';
import 'package:flutter_ecommerce/ui/pages/noRoles/register_role.dart';
import 'package:flutter_ecommerce/ui/pages/user/bottom_navigation_bar.dart';
import 'package:flutter_ecommerce/ui/pages/register_page.dart';
import 'package:flutter_ecommerce/utils/color_codes.dart';
import 'package:flutter_ecommerce/utils/mediaQuery.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:meta/meta.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_ecommerce/blocs/loginBloc/login_bloc.dart';
import 'package:flutter_ecommerce/repositories/user_repository.dart';

class LoginPageParent extends StatelessWidget {
  final UserRepository userRepository;

  LoginPageParent({@required this.userRepository});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LoginBloc(userRepository: userRepository),
      child: LoginPage(userRepository: userRepository),
    );
  }
}

// ignore: must_be_immutable
class LoginPage extends StatelessWidget {
  UserRepository userRepository;

  LoginPage({this.userRepository});

  LoginBloc loginBloc;

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    loginBloc = BlocProvider.of<LoginBloc>(context);

    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomInset: false,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              child: BlocListener<LoginBloc, LoginState>(
                listener: (context, state) {
                  if (state is LoginSuccessState) {
                    navigateToHomeScreen(context, state.user);
                  } else if (state is LoginAdminSuccessState) {
                    navigateToAdminScreen(context, state.user);
                  } else if (state is LoginSuccessNoRoleState) {
                    navigateToRegisterRole(context, state.user);
                  }
                },
                child: BlocBuilder<LoginBloc, LoginState>(
                  // ignore: missing_return
                  builder: (context, state) {
                    if (state is LoginInitialState) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          _buildInitialUi(context),
                          // _buildForm(context, false),
                        ],
                      );
                    } else if (state is LoginLoadingState) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          _buildInitialUi(context),
                          // _buildForm(context, true),
                        ],
                      );
                    } else if (state is LoginSuccessState) {
                      return Container(
                        width: 0.0,
                        height: 0.0,
                      );
                    } else if (state is LoginAdminSuccessState) {
                      return Container(
                        width: 0.0,
                        height: 0.0,
                      );
                    } else if (state is LoginSuccessNoRoleState) {
                      return Container(
                        width: 0.0,
                        height: 0.0,
                      );
                    }
                  },
                ),
              ),
            ),
            SizedBox(height: 15.0),
          ],
        ),
      ),
    );
  }

  void navigateToHomeScreen(BuildContext context, User user) {
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) {
      return CustomBottomNavigationBar(
          currentIndex: 0, user: user, userRepository: userRepository);
    }));
  }

  void navigateToAdminScreen(BuildContext context, User user) {
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) {
      return AdminDashboard(user: user, userRepository: userRepository);
    }));
  }

  void navigateToSignUpScreen(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return SignUpPageParent(userRepository: userRepository);
    }));
  }

  void navigateToRegisterRole(BuildContext context, User user) {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return RegisterRoles(
        user: user,
        userRepository: userRepository,
      );
    }));
  }

  Widget _buildInitialUi(context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: ListView(
        children: [
          SizedBox(
            height: getCurrentHeight(context, 30),
          ),
          Padding(
            padding: EdgeInsets.all(20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'Rumah',
                  textAlign: TextAlign.right,
                  style: GoogleFonts.bebasNeue(
                    fontSize: 25,
                    color: primaryColor,
                    letterSpacing: 5.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                Text(
                  'Hijab',
                  textAlign: TextAlign.right,
                  style: GoogleFonts.bebasNeue(
                    fontSize: 25,
                    color: Colors.orange,
                    letterSpacing: 5.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: getCurrentHeight(context, 50),
          ),
          Container(
            margin: EdgeInsets.only(
              left: MediaQuery.of(context).size.width * 0.3,
              right: MediaQuery.of(context).size.width * 0.1,
            ),
            height: MediaQuery.of(context).size.height * 0.4,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/login_illustration.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(20.0),
            child: Text(
              'LOGIN',
              textAlign: TextAlign.right,
              style: GoogleFonts.bebasNeue(
                fontSize: 35,
                color: primaryColor,
                letterSpacing: 5.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(right: 20.0),
            child: Text(
              'Masuk dengan menggunakan akun google',
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 11,
                color: Colors.black38,
              ),
            ),
          ),
          BlocBuilder<LoginBloc, LoginState>(builder: (context, state) {
            if (state is LoginLoadingState) {
              return Container(
                margin: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * 0.04,
                  left: MediaQuery.of(context).size.width * 0.6,
                ),
                width: MediaQuery.of(context).size.width * 0.5,
                height: MediaQuery.of(context).size.width * 0.2,
                child: LottieBuilder.asset(
                    'assets/lottieAnimations/loading_animation_2.json'),
              );
            } else {
              return GestureDetector(
                onTap: () => loginBloc.add(LoginWithGoogle()),
                child: Container(
                  margin: EdgeInsets.only(
                    left: getCurrentWidth(context, 230),
                    top: getCurrentHeight(context, 50),
                    right: getCurrentWidth(context, 20),
                  ),
                  height: getCurrentHeight(context, 50),
                  width: getCurrentWidth(context, 100),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: primaryColor,
                  ),
                  child: Center(
                    child: Text(
                      'Login',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              );
            }
          }),
        ],
      ),
    );
  }
}
