import 'package:bloc/bloc.dart';
import 'package:flutter_ecommerce/blocs/regBloc/user_reg_event.dart';
import 'package:flutter_ecommerce/blocs/regBloc/user_reg_state.dart';
import 'package:flutter_ecommerce/repositories/DatabaseUser.dart';
import 'package:flutter_ecommerce/repositories/user_repository.dart';
import 'package:meta/meta.dart';

class UserRegBloc extends Bloc<UserRegEvent, UserRegState> {
  UserRepository userRepository;

  UserRegBloc({@required UserRepository userRepository})
      : super(UserRegInitial()) {
    this.userRepository = userRepository;
  }

  @override
  Stream<UserRegState> mapEventToState(UserRegEvent event) async* {
    if (event is SignUpButtonPressed) {
      yield UserRegLoading();
      try {
        var user = await userRepository.signUpUserWithEmailPass(
            event.email, event.password);

        DatabaseUser.createUser(userRepository);

        print("BLoC : ${user.email}");
        yield UserRegSuccessful(user);
      } catch (e) {
        yield UserRegFailure(e.toString());
      }
    }
  }
}
