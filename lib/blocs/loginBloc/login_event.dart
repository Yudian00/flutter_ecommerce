import 'package:equatable/equatable.dart';

abstract class LoginEvent extends Equatable {}

class LoginButtonPressed extends LoginEvent {
  final String email;
  final String password;

  LoginButtonPressed({this.email, this.password});

  @override
  List<Object> get props => throw UnimplementedError();
}

class LoginWithGoogle extends LoginEvent {
  @override
  List<Object> get props => throw UnimplementedError();
}

// import 'package:equatable/equatable.dart';
// import 'package:meta/meta.dart';

// abstract class LoginEvent extends Equatable {}

// class LoginWithEmailEvent extends Equatable {
//   String email, password;

//   LoginWithEmailEvent({@required this.email, @required this.password});

//   @override
//   // TODO: implement props
//   List<Object> get props => null;
// }
