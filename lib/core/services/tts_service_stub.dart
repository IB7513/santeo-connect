import 'package:flutter/material.dart';

class TtsService {
  static void speak(String text) {}
  static void stop() {}
  static void runJs(String js) {}

  static Widget buildSpeakButton({
    required String text,
    required Widget child,
    double? width,
    double height = 44,
  }) {
    return SizedBox(width: width, height: height, child: child);
  }
}
