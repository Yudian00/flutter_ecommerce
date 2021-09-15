part of 'countdowntimer_cubit.dart';

abstract class CountdowntimerState extends Equatable {
  const CountdowntimerState();

  @override
  List<Object> get props => [];
}

class CountdowntimerInitial extends CountdowntimerState {}

class CountdowntimerChangeIndex extends CountdowntimerState {
  final int index;

  CountdowntimerChangeIndex({
    this.index,
  });
}

class ChangeIndexTimer extends CountdowntimerState {}
