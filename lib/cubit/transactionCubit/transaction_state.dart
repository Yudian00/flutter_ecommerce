part of 'transaction_cubit.dart';

abstract class TransactionState extends Equatable {
  const TransactionState();

  @override
  List<Object> get props => [];
}

class TransactionInitial extends TransactionState {}

// ignore: must_be_immutable
class TransactionEnd extends TransactionState {
  bool isSuccess;

  TransactionEnd({
    @required this.isSuccess,
  });
}
