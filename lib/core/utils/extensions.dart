import 'package:flutter/material.dart';

extension WidgetSpacing on Widget {
  Widget pad(EdgeInsetsGeometry p) => Padding(padding: p, child: this);
}

extension NumPadding on num {
  EdgeInsets get padAll => EdgeInsets.all(toDouble());
  EdgeInsets get padH => EdgeInsets.symmetric(horizontal: toDouble());
  EdgeInsets get padV => EdgeInsets.symmetric(vertical: toDouble());
  SizedBox get vbox => SizedBox(height: toDouble());
  SizedBox get hbox => SizedBox(width: toDouble());
}

extension StringExt on String {
  String get nonEmpty => trim().isEmpty ? '' : trim();
  bool get isEmail => RegExp(r'^[\w.+-]+@[\w-]+\.[\w.-]+$').hasMatch(this);
}
