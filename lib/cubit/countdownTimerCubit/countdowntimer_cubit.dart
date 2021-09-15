import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'countdowntimer_state.dart';

class CountdowntimerCubit extends Cubit<CountdowntimerState> {
  CountdowntimerCubit() : super(CountdowntimerInitial());

  void changeIndex(int index) {
    emit(ChangeIndexTimer());
    emit(CountdowntimerChangeIndex(index: index));
  }
}
