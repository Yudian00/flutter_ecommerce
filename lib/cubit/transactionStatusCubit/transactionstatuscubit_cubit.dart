import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_ecommerce/utils/midtrans_key.dart';
import 'package:http/http.dart' as http;

part 'transactionstatuscubit_state.dart';

class TransactionstatuscubitCubit extends Cubit<TransactionstatuscubitState> {
  TransactionstatuscubitCubit() : super(TransactionstatuscubitInitial());

  void getTransactionStatusCubit(String midtransId) async {
    Dio dio = Dio();
    Response response;

    String getStatusUrl =
        'https://api.sandbox.midtrans.com/v2/' + midtransId + '/status';

    Map<String, String> requestHeaders = {
      'Accept': 'application/json',
      'Authorization': serverKeySB64,
    };

    response = await dio.get(
      getStatusUrl,
      options:
          Options(contentType: 'application/json', headers: requestHeaders),
    );
    emit(TransactionstatuscubitLoad());
    emit(TransactionstatuscubitInitial(response: response));
  }

  Stream<http.Response> getTransactionStatus2(String midtransId) async* {
    yield* Stream.periodic(Duration(seconds: 5), (_) {
      return http.get(
          Uri.parse(
              'https://api.sandbox.midtrans.com/v2/' + midtransId + '/status'),
          headers: {
            'Accept': 'application/json',
            'Authorization': serverKeySB64,
          });
    }).asyncMap((event) async => await event);
  }
}
