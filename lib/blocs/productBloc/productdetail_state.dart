part of 'productdetail_bloc.dart';

abstract class ProductdetailState extends Equatable {}

class ProductdetailInitial extends ProductdetailState {
  @override
  List<Object> get props => [];
}

// ignore: must_be_immutable
class AddProductToCart extends ProductdetailState {
  bool isInCart = false;
  int items;

  AddProductToCart(this.items);

  @override
  List<Object> get props => [isInCart, items];
}

// ignore: must_be_immutable
class RemoveProductFromCart extends ProductdetailState {
  bool isInCart = true;
  int items;

  RemoveProductFromCart(this.items);

  @override
  List<Object> get props => [isInCart, items];
}

// ignore: must_be_immutable
class BuyProduct extends ProductdetailState {
  Product product;

  BuyProduct({this.product});

  @override
  List<Object> get props => [product];
}

// ignore: must_be_immutable
class FavoriteProduct extends ProductdetailState {
  Product product;

  FavoriteProduct({this.product});

  @override
  List<Object> get props => throw UnimplementedError();
}
