import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ecommerce/repositories/DatabaseServices.dart';
import 'package:flutter_ecommerce/ui/pages/user/payment/gopay/gopay_payment_page.dart';
import 'package:flutter_ecommerce/utils/midtrans_key.dart';
import 'package:flutter_ecommerce/utils/widget_utils.dart';
import 'package:page_transition/page_transition.dart';

class GopayProcessPaymentPage extends StatefulWidget {
  final Map data;
  final String transactionId;

  GopayProcessPaymentPage({
    @required this.transactionId,
    @required this.data,
  });

  @override
  _GopayProcessPaymentPageState createState() =>
      _GopayProcessPaymentPageState();
}

class _GopayProcessPaymentPageState extends State<GopayProcessPaymentPage> {
  // This page is used for payment process and redirect it to status page if done

  void initState() {
    super.initState();
    print(widget.data);
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
            return Center(
              child: loadingAnimation(),
            );
          } else {
            Future.delayed(
              Duration.zero,
              () async {
                Navigator.pushReplacement(
                  context,
                  PageTransition(
                    type: PageTransitionType.rightToLeft,
                    child: GopayPaymentPage(
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

      // create transaction to Firebase

      DatabaseServices.onlinePay(
          widget.transactionId, response.data['order_id'], 'Gopay');
      DatabaseServices.createMidTransDataGopay(
        response.data['order_id'],
        response.data['actions'][0]['url'],
        response.data['actions'][1]['url'],
        widget.transactionId,
        'GOPAY',
      );

      return response.data;
    } catch (e) {
      print(e);
    }
  }
}
