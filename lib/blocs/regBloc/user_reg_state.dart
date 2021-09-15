import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class UserRegState extends Equatable {}

class UserRegInitial extends UserRegState {
  @override
  List<Object> get props => throw UnimplementedError();
}

class UserRegLoading extends UserRegState {
  @override
  List<Object> get props => throw UnimplementedError();
}

class UserRegSuccessful extends UserRegState {
  final User user;

  UserRegSuccessful(this.user);

  @override
  List<Object> get props => throw UnimplementedError();
}

class UserRegFailure extends UserRegState {
  final String message;

  UserRegFailure(this.message);

  @override
  List<Object> get props => throw UnimplementedError();
}
