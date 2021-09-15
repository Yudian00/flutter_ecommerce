import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthState extends Equatable {}

class AuthInitialState extends AuthState {
  @override
  List<Object> get props => null;
}

class AuthenticatedState extends AuthState {
  final User user;

  AuthenticatedState(this.user);

  @override
  List<Object> get props => null;
}

class AuthenticatedAdminState extends AuthState {
  final User user;

  AuthenticatedAdminState(this.user);

  @override
  List<Object> get props => null;
}

class AuthenticatednoRoleState extends AuthState {
  final User user;

  AuthenticatednoRoleState(this.user);

  @override
  List<Object> get props => null;
}

class UnauthenticatedState extends AuthState {
  @override
  List<Object> get props => null;
}
