import 'dart:io';

import 'package:dio/dio.dart';

class NotificationFCM {
  static String serverKeyFCM =
      'key=AAAAJ7DAAlk:APA91bG3DTliTNN2F5mbw0EuWnxbU5rgjEhWEqpZiIOgTHSLDX3adTZ3NxRq9UH6u14Atw_Zv-sCbYTKRO7mhnykGt343Vsuqwz16wPjnEsiiqvWe-ObveZkX7QSl9w_h84uQZNgWSH6';

  static void setNotificationFCM(
    String deviceToken, {
    String titleMessage,
    String bodyMessage,
  }) async {
    try {
      Dio dio = Dio();

      var data = {
        "to": deviceToken,
        "collapse_key": "type_a",
        "notification": {"body": bodyMessage, "title": titleMessage},
      };

      var response = await dio.post(
        'https://fcm.googleapis.com/fcm/send',
        data: data,
        options: Options(
          headers: {
            HttpHeaders.contentTypeHeader: "application/json",
            HttpHeaders.authorizationHeader: serverKeyFCM,
          },
        ),
      );

      print(response);
    } catch (e) {
      print(e);
      print('Notification order failed');
    }
  }
}
