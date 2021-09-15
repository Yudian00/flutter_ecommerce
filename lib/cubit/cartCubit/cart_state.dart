part of 'cart_cubit.dart';

abstract class CartState extends Equatable {
  const CartState();
}

// ignore: must_be_immutable
class CartInitial extends CartState {
  int totalPrice;
  int totalItems;

  CartInitial(this.totalPrice, this.totalItems);

  @override
  List<Object> get props => [totalPrice];
}

// ignore: must_be_immutable
class RemoveCartState extends CartState {
  Map priceCart;
  Map map;
  num totalPrice;

  RemoveCartState(this.map, this.priceCart, this.totalPrice);

  @override
  List<Object> get props => [priceCart, map, totalPrice];
}

// ignore: must_be_immutable
class AddCartState extends CartState {
  Map priceCart;
  Map map;
  num totalPrice;

  AddCartState(this.map, this.priceCart, this.totalPrice);

  @override
  List<Object> get props => [priceCart, map, totalPrice];
}

// ignore: must_be_immutable
class LoadCartState extends CartState {
  Map priceCart;
  Map map;
  num totalPrice;

  LoadCartState(this.map, this.priceCart, this.totalPrice);

  @override
  List<Object> get props => [priceCart, map, totalPrice];
}

class DeleteFromCart extends CartState {
  @override
  List<Object> get props => [];
}
