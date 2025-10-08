import 'package:flutter/material.dart';

double fontScaler(BuildContext context, double base) {
  final textScaler = MediaQuery.of(context).textScaler;
  return textScaler.scale(base); // ✅ correct call
}
