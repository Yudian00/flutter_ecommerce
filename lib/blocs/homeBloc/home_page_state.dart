import 'package:equatable/equatable.dart';

abstract class HomePageState extends Equatable {}

// ignore: must_be_immutable
class LogOutInitial extends HomePageState {
  int value;

  LogOutInitial(this.value);

  @override
  List<Object> get props => null;
}

class LogOutSuccessState extends HomePageState {
  @override
  List<Object> get props => null;
}
