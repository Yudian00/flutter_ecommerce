import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_ecommerce/models/product_model.dart';
import 'package:flutter_ecommerce/repositories/cart_list.dart' as cart;

part 'productdetail_event.dart';
part 'productdetail_state.dart';

class ProductdetailBloc extends Bloc<ProductdetailEvent, ProductdetailState> {
  String productID;
  ProductdetailBloc({this.productID}) : super(ProductdetailInitial());

  @override
  Stream<ProductdetailState> mapEventToState(
    ProductdetailEvent event,
  ) async* {
    try {
      if (event is CartButtonPressed) {
        var document = await FirebaseFirestore.instance
            .collection('product')
            .doc(productID)
            .get();

        //calculate a new price after discount
        var discountPrice =
            int.parse(document['harga']) * document['discount_percent'] / 100;
        var newPrice = int.parse(document['harga']) - discountPrice;
        var newPrice2 = newPrice.toInt();

        _check(productID, newPrice2);

        int totalItems = cart.cartProduct.length;
        print(totalItems);

        yield AddProductToCart(totalItems);
      } else if (event is RemoveCartButtonPressed) {
        var document = await FirebaseFirestore.instance
            .collection('product')
            .doc(productID)
            .get();

        //calculate a new price after discount
        var discountPrice =
            int.parse(document['harga']) * document['discount_percent'] / 100;
        var newPrice = int.parse(document['harga']) - discountPrice;
        var newPrice2 = newPrice.toInt();

        _check(productID, newPrice2);

        int totalItems = cart.cartProduct.length;
        print(totalItems);

        yield RemoveProductFromCart(totalItems);
      }
    } catch (e) {}
  }

  //Checking condition and add to cartList
  void _check(productID, value) {
    if (cart.cartProduct.contains(productID)) {
      cart.cartProduct.remove(productID);
      cart.price.remove(productID);
      print(cart.price);
    } else {
      cart.cartProduct.add(productID);
      cart.price.putIfAbsent(productID, () => value);
      print(cart.price);
    }

    //create a total price cart
    var values = cart.price.values;
    int sum = values.fold(0, (p, c) => p + c);

    //set total Price
    cart.totalPrice = sum;
    print(cart.totalPrice);
  }
}
