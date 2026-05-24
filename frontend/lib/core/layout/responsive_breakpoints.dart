import 'package:flutter/material.dart';

abstract final class ResponsiveBreakpoints {
  static const double compact = 600;
  static const double medium = 900;
  static const double expanded = 1200;
  static const double contentMaxWidth = 1200;
  static const double sidebarWidth = 260;

  static bool isWideLayout(BuildContext context) {
    return MediaQuery.sizeOf(context).width >= medium;
  }
}
