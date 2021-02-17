import 'package:flutter/material.dart';

class Style {
  static final BoxShadow shadow = BoxShadow(
    color: Colors.grey.withOpacity(0.5),
    spreadRadius: 3,
    blurRadius: 0,

    offset: Offset(0, 1), // changes position of shadow
  );
  static final sizedBox = SizedBox(
    height: 15,
  );
}
