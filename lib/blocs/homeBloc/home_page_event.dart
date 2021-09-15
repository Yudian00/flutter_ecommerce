import 'package:equatable/equatable.dart';

abstract class HomePageEvent extends Equatable {}

class LogOutEvent extends HomePageEvent {
  @override
  List<Object> get props => null;
}

class HomeButtonPressed extends HomePageEvent {
  @override
  List<Object> get props => null;
}
