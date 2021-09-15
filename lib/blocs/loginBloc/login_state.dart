import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class LoginState extends Equatable {}

class LoginInitialState extends LoginState {
  @override
  List<Object> get props => null;
}

class LoginLoadingState extends LoginState {
  @override
  List<Object> get props => null;
}

class LoginSuccessState extends LoginState {
  final User user;

  LoginSuccessState(this.user);

  @override
  List<Object> get props => null;
}

class LoginSuccessNoRoleState extends LoginState {
  final User user;

  LoginSuccessNoRoleState(this.user);

  @override
  List<Object> get props => null;
}

class LoginAdminSuccessState extends LoginState {
  final User user;

  LoginAdminSuccessState(this.user);

  @override
  List<Object> get props => null;
}

class LoginFailState extends LoginState {
  final String message;

  LoginFailState(this.message);

  @override
  List<Object> get props => null;
}
