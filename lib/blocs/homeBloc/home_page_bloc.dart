import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_ecommerce/blocs/homeBloc/home_page_event.dart';
import 'package:flutter_ecommerce/blocs/homeBloc/home_page_state.dart';
import 'package:flutter_ecommerce/repositories/DatabaseUser.dart';
import 'package:flutter_ecommerce/repositories/user_repository.dart';
import 'package:meta/meta.dart';
import 'package:flutter_ecommerce/repositories/cart_list.dart' as cart;

class HomePageBloc extends Bloc<HomePageEvent, HomePageState> {
  UserRepository userRepository;
  static int value = cart.cartProduct.length;

  HomePageBloc({@required UserRepository userRepository})
      : super(LogOutInitial(value)) {
    this.userRepository = userRepository;
  }

  @override
  Stream<HomePageState> mapEventToState(HomePageEvent event) async* {
    if (event is LogOutEvent) {
      print("LOG out Bloc");
      String id = FirebaseAuth.instance.currentUser.uid;
      DatabaseUser.resetTokenUser(id);

      print('=========LOGOUT=========');

      userRepository.signOut();
      yield LogOutSuccessState();
    }
  }
}
