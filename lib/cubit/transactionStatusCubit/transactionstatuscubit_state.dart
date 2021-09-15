part of 'transactionstatuscubit_cubit.dart';

abstract class TransactionstatuscubitState extends Equatable {
  const TransactionstatuscubitState();

  @override
  List<Object> get props => [];
}

class TransactionstatuscubitInitial extends TransactionstatuscubitState {
  final dynamic response;

  TransactionstatuscubitInitial({
    this.response,
  });
}

class TransactionstatuscubitLoad extends TransactionstatuscubitState {}
