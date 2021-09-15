library my_prj.globals;

import 'package:flutter/cupertino.dart';

double getCurrentHeight(BuildContext context, double height) {
  var size = MediaQuery.of(context).size.height / height;
  var finalHeight = MediaQuery.of(context).size.height / size;

  return finalHeight;
}

double getCurrentWidth(BuildContext context, double width) {
  var size = MediaQuery.of(context).size.width / width;
  var finalWidth = MediaQuery.of(context).size.width / size;

  return finalWidth;
}
