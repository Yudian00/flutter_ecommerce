part of 'productdetail_bloc.dart';

abstract class ProductdetailEvent extends Equatable {
  const ProductdetailEvent();
}

class BuyButtonPressed extends ProductdetailEvent {
  @override
  List<Object> get props => [];
}

class CartButtonPressed extends ProductdetailEvent {
  @override
  List<Object> get props => [];
}

class RemoveCartButtonPressed extends ProductdetailEvent {
  @override
  List<Object> get props => [];
}

class FavoriteButtonPressed extends ProductdetailEvent {
  @override
  List<Object> get props => [];
}
