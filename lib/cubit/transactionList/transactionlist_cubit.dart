import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_ecommerce/repositories/DatabaseServices.dart';

part 'transactionlist_state.dart';

class TransactionlistCubit extends Cubit<TransactionlistState> {
  TransactionlistCubit() : super(TransactionlistInitial());

  void deleteTransactionWaitingList(String transactionId) {
    print('Delete transaction id : ' + transactionId);
    DatabaseServices.deleteTransactionData(transactionId);

    emit(TransactionListDeleted());
  }

  void cancelOrder(String transactionId) {
    print('Cancel transaction id : ' + transactionId);
    DatabaseServices.cancelOrder(transactionId);
    emit(TransactionListDeleted());
  }
}
