import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_ecommerce/blocs/loginBloc/login_event.dart';
import 'package:flutter_ecommerce/blocs/loginBloc/login_state.dart';
import 'package:flutter_ecommerce/repositories/DatabaseUser.dart';
import 'package:flutter_ecommerce/repositories/user_repository.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:meta/meta.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  UserRepository userRepository;

  LoginBloc({@required UserRepository userRepository})
      : super(LoginInitialState()) {
    this.userRepository = userRepository;
  }

  static Future<DocumentSnapshot> getUserInfo(var userID) async {
    var userInfo =
        await FirebaseFirestore.instance.collection('user').doc(userID).get();

    return userInfo;
  }

  @override
  Stream<LoginState> mapEventToState(LoginEvent event) async* {
    if (event is LoginWithGoogle) {
      yield LoginLoadingState();
      try {
        // var user = await userRepository.signInWithGoogleAccount();
        // DocumentSnapshot userRole = await LoginBloc.getUserInfo(user.uid);
        // var userRoledata = userRole.data();

        final GoogleSignIn googleSignIn = GoogleSignIn();
        final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
        final GoogleSignInAccount googleUser = await googleSignIn.signIn();

        if (googleUser == null) {
          yield LoginInitialState();
        }

        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;

        final AuthCredential authCredential = GoogleAuthProvider.credential(
          idToken: googleAuth.idToken,
          accessToken: googleAuth.accessToken,
        );

        UserCredential result =
            await firebaseAuth.signInWithCredential(authCredential);

        final User user = result.user;

        DocumentSnapshot userRole = await LoginBloc.getUserInfo(user.uid);
        var userRoledata = userRole.data();

        if (userRoledata == null) {
          DatabaseUser.createUser(userRepository);
          yield LoginSuccessNoRoleState(user);
        }

        print('=========================');
        final Map<String, dynamic> data = Map.from(userRoledata);
        print(data['role']);

        if (data['role'] == 'admin') {
          yield LoginAdminSuccessState(user);
        } else if (data['role'] == 'pengguna') {
          yield LoginSuccessState(user);
        } else {
          DatabaseUser.createUser(userRepository);
          yield LoginSuccessNoRoleState(user);
        }
      } catch (e) {
        print(e);
        yield LoginInitialState();
      }
    }
  }
}
