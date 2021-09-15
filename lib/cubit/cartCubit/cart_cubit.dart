import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_ecommerce/repositories/cart_list.dart' as cart;

part 'cart_state.dart';

class CartCubit extends Cubit<CartState> {
  CartCubit() : super(CartInitial(cart.totalPrice, cart.cartProduct.length));
  var listCart = cart.cartProduct;

  void addQtyProduct(Map mapCart, Map priceCart, String key, num price) async {
    // //index barang
    mapCart.update(key, (value) => value + 1);
    print(mapCart);

    // print(price);
    // print(key);

    //index harga
    num newPrice = price * mapCart[key];
    priceCart.update(key, (value) => newPrice);
    print(key.toString() + ' newPrice : ' + newPrice.toString());

    //convert to list
    List _list = priceCart.values.toList();

    //total price
    var priceTotal = 0;

    for (var i = 0; i < _list.length; i++) {
      if (_list[i] is String) {
        print(_list[i]);
        priceTotal = priceTotal + int.parse(_list[i]);
      } else {
        print(_list[i]);
        priceTotal = priceTotal + _list[i];
      }
    }

    cart.totalPrice = priceTotal;

    print('===============');

    print(cart.totalPrice);
    print(price);
    print('result : ');
    print('MapCart : ' + mapCart.toString());
    print('priceCart : ' + priceCart.toString());
    print('priceTotal : ' + priceTotal.toString());

    cart.mapCart = mapCart;

    emit(AddCartState(mapCart, priceCart, priceTotal));
    emit(LoadCartState(mapCart, priceCart, priceTotal));
  }

  void minQtyProduct(Map mapCart, Map priceCart, String key, num price) {
    //index barang
    mapCart.update(key, (value) => value - 1);
    print(mapCart);
    //index harga
    var newPrice = price * mapCart[key];
    priceCart.update(key, (value) => newPrice);

    //convert to list
    List _list = priceCart.values.toList();

    //total price
    var priceTotal = 0;

    for (var i = 0; i < _list.length; i++) {
      if (_list[i] is String) {
        priceTotal = priceTotal + int.parse(_list[i]);
      } else {
        priceTotal = priceTotal + _list[i];
      }
    }

    cart.totalPrice = priceTotal;
    cart.mapCart = mapCart;

    emit(RemoveCartState(mapCart, priceCart, priceTotal));
    emit(LoadCartState(mapCart, priceCart, priceTotal));
    print('kurang');
  }
}
