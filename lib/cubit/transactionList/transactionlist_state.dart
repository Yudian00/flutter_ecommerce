part of 'transactionlist_cubit.dart';

abstract class TransactionlistState extends Equatable {
  const TransactionlistState();

  @override
  List<Object> get props => [];
}

class TransactionlistInitial extends TransactionlistState {}

class TransactionListDeleted extends TransactionlistState {}
