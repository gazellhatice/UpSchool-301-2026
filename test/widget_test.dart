import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kisisel_harcama_kocu_1/core/theme/app_theme.dart';

void main() {
  test('dark theme is configured', () {
    expect(AppTheme.dark.brightness, Brightness.dark);
  });
}
