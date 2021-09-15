import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ecommerce/blocs/regBloc/user_reg_bloc.dart';
import 'package:flutter_ecommerce/blocs/regBloc/user_reg_event.dart';
import 'package:flutter_ecommerce/blocs/regBloc/user_reg_state.dart';
import 'package:flutter_ecommerce/repositories/user_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_ecommerce/ui/pages/noRoles/register_role.dart';
import 'package:flutter_ecommerce/ui/pages/user/bottom_navigation_bar.dart';
import 'package:flutter_ecommerce/utils/color_codes.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:meta/meta.dart';

// ignore: must_be_immutable
class SignUpPageParent extends StatelessWidget {
  UserRepository userRepository;
  SignUpPageParent({@required this.userRepository});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => UserRegBloc(userRepository: userRepository),
      child: SignupPage(userRepository: userRepository),
    );
  }
}

// ignore: must_be_immutable
class SignupPage extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();

  String _email;
  String _password;

  String authResult;
  UserRegBloc userRegBloc;
  UserRepository userRepository;
  Color _mainColor = Colors.red;

  SignupPage({@required this.userRepository});

  void _submit() {
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      userRegBloc.add(SignUpButtonPressed(email: _email, password: _password));
    }
  }

  void navigateToHomeScreen(BuildContext context, User user) {
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) {
      return CustomBottomNavigationBar(
        currentIndex: 0,
        user: user,
        userRepository: userRepository,
      );
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

  @override
  Widget build(BuildContext context) {
    userRegBloc = BlocProvider.of<UserRegBloc>(context);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              child: Stack(
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.all(5),
                    child: BlocListener<UserRegBloc, UserRegState>(
                      listener: (context, state) {
                        if (state is UserRegSuccessful) {
                          return navigateToRegisterRole(context, state.user);
                        }
                      },
                      child: BlocBuilder<UserRegBloc, UserRegState>(
                        // ignore: missing_return
                        builder: (context, state) {
                          if (state is UserRegInitial) {
                            return Column(
                              children: <Widget>[
                                _buildInitialUi(),
                                _buildForm(context, false),
                              ],
                            );
                          } else if (state is UserRegLoading) {
                            return Column(
                              children: <Widget>[
                                _buildInitialUi(),
                                _buildForm(context, true),
                              ],
                            );
                          } else if (state is UserRegFailure) {
                            return Column(
                              children: <Widget>[
                                _buildInitialUi(),
                                _buildForm(context, false),
                                _buildFailureUi('Email is already taken'),
                              ],
                            );
                          } else if (state is UserRegSuccessful) {
                            return Container();
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext context, bool isSumbit) {
    return Form(
      key: _formKey,
      child: Container(
        padding: EdgeInsets.only(top: 35.0, left: 20.0, right: 20.0),
        child: Column(
          children: <Widget>[
            TextFormField(
              onSaved: (val) => _email = val,
              validator: (text) => !text.contains('@') ? 'invalid email' : null,
              decoration: InputDecoration(
                  labelText: 'EMAIL',
                  labelStyle: TextStyle(
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.bold,
                      color: Colors.grey),
                  // hintText: 'EMAIL',
                  // hintStyle: ,
                  focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.green))),
            ),
            SizedBox(height: 10.0),
            TextFormField(
              onSaved: (val) => _password = val,
              validator: (text) =>
                  text.length < 6 ? 'password too short' : null,
              decoration: InputDecoration(
                  labelText: 'PASSWORD ',
                  labelStyle: TextStyle(
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.bold,
                      color: Colors.grey),
                  focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.green))),
              obscureText: true,
            ),
            SizedBox(height: 30.0),
            isSumbit ? _buildLoadingUi() : _buildButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(BuildContext context) {
    return Column(
      children: <Widget>[
        _buildRegisterButton(),
        _buildBackButton(context),
      ],
    );
  }

  Widget _buildRegisterButton() {
    return Column(
      children: <Widget>[
        Container(
          padding: EdgeInsets.symmetric(vertical: 25.0),
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              elevation: 5.0,
              padding: EdgeInsets.all(15.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              primary: primaryColor,
            ),
            onPressed: () => _submit(),
            child: Text(
              'Register',
              style: TextStyle(
                color: Colors.white,
                letterSpacing: 1.5,
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
                // fontFamily: 'OpenSans',
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          padding: EdgeInsets.symmetric(vertical: 25.0),
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              elevation: 5.0,
              padding: EdgeInsets.all(15.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              primary: Colors.white,
            ),
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Kembali',
              style: TextStyle(
                color: primaryColor,
                letterSpacing: 1.5,
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
                // fontFamily: 'OpenSans',
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFailureUi(String message) {
    return Text(
      message,
      style: TextStyle(color: _mainColor, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildLoadingUi() {
    return Center(
      child: Container(
        margin: EdgeInsets.only(top: 50),
        child: CircularProgressIndicator(
          valueColor: new AlwaysStoppedAnimation<Color>(Colors.red),
        ),
      ),
    );
  }

  Widget _buildInitialUi() {
    return Container(
      padding: EdgeInsets.fromLTRB(15.0, 110.0, 0.0, 0.0),
      child: Text(
        'REGISTER',
        style: GoogleFonts.hammersmithOne(
            fontSize: 30.0, fontWeight: FontWeight.bold),
      ),
    );
  }
}
