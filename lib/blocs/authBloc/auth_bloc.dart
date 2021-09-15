import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_ecommerce/blocs/authBloc/auth_event.dart';
import 'package:flutter_ecommerce/blocs/authBloc/auth_state.dart';
import 'package:flutter_ecommerce/repositories/DatabaseServices.dart';
import 'package:flutter_ecommerce/repositories/user_repository.dart';
import 'package:meta/meta.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  UserRepository userRepository;

  AuthBloc({
    @required this.userRepository,
  }) : super(AuthInitialState()) {
    this.userRepository = userRepository;
  }

  @override
  Stream<AuthState> mapEventToState(AuthEvent event) async* {
    if (event is StartApp) {
      yield* _startAppToState();
    }
    if (event is AppStartedEvent) {
      var isSignedIn = userRepository.isSignedIn();
      print(isSignedIn);
      try {
        if (isSignedIn) {
          var user = await userRepository.getCurrentUser();

          DocumentSnapshot userRole =
              await DatabaseServices.getUserInfo(user.uid);

          var userRoledata = userRole.data();

          print('=========================');
          final Map<String, dynamic> data = Map.from(userRoledata);
          print(data['role']);

          if (data['role'] == 'admin') {
            yield AuthenticatedAdminState(user);
          } else if (data['role'] == 'pengguna') {
            yield AuthenticatedState(user);
          } else if (data['role'] == 'unknown') {
            yield AuthenticatednoRoleState(user);
          }
        } else {
          yield UnauthenticatedState();
        }
      } catch (e) {
        yield UnauthenticatedState();
      }
    }
  }

  Stream<AuthState> _startAppToState() async* {
    print('loading');
    Timer(Duration(seconds: 1), () {
      add(AppStartedEvent());
    });
  }
}
