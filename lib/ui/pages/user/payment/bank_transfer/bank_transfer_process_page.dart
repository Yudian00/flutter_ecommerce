import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ecommerce/repositories/DatabaseServices.dart';
import 'package:flutter_ecommerce/ui/pages/user/payment/bank_transfer/bank_payment_page.dart';
import 'package:flutter_ecommerce/utils/midtrans_key.dart';
import 'package:flutter_ecommerce/utils/widget_utils.dart';
import 'package:page_transition/page_transition.dart';

class BankTransferProcess extends StatefulWidget {
  final Map data;
  final String bank;
  final String transactionId;

  BankTransferProcess({
    @required this.bank,
    @required this.data,
    @required this.transactionId,
  });

  @override
  _BankTransferProcessState createState() => _BankTransferProcessState();
}

class _BankTransferProcessState extends State<BankTransferProcess> {
  void initState() {
    super.initState();
  }

  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: doTransaction(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: loadingAnimation());
          } else {
            Future.delayed(
              Duration.zero,
              () async {
                Navigator.pushReplacement(
                  context,
                  PageTransition(
                    type: PageTransitionType.rightToLeft,
                    child: BankPaymentPage(
                      bank: widget.bank,
                      snapshot: snapshot,
                      transactionId: widget.transactionId,
                    ),
                  ),
                );
              },
            );

            return Container();
          }
        },
      ),
    );
  }

  Future doTransaction() async {
    try {
      Dio dio = Dio();
      Response response;

      Map<String, String> requestHeaders = {
        'Accept': 'application/json',
        'Authorization': serverKeySB64,
      };

      response = await dio.post(
        sandboxUrl,
        data: widget.data,
        options:
            Options(contentType: 'application/json', headers: requestHeaders),
      );

      print(response.data);

      // create transaction to Firebase

      DatabaseServices.onlinePay(
        widget.transactionId,
        response.data['order_id'],
        'Transfer ' + widget.bank,
      );
      DatabaseServices.createMidTransDataBankTransfer(
        response.data['order_id'].toString(),
        response.data['va_numbers'][0]['va_number'].toString(),
        widget.transactionId,
        widget.bank,
      );

      return response.data;
    } catch (e) {
      print(e);
    }
  }
}
