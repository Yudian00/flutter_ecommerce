import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_ecommerce/repositories/user_repository.dart';

part 'logout_state.dart';

class LogoutCubit extends Cubit<LogoutState> {
  LogoutCubit() : super(LogoutInitial());

  void logout(UserRepository userRepository) async {
    print('logout cubit success');
    userRepository.signOut();
    emit(LogoutSuccess());
  }
}
