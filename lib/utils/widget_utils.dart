library my_prj.globals;

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

Widget loadingAnimation() {
  return Column(
    children: [
      Container(
        height: 100,
        width: 100,
        child: Center(
          child: LottieBuilder.asset(
              'assets/lottieAnimations/loading_animation_2.json'),
        ),
      ),
      SizedBox(
        height: 30,
      ),
    ],
  );
}
