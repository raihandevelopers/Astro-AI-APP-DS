import 'package:flutter_test/flutter_test.dart';
import 'package:myfuture/theme.dart';
import 'package:flutter/material.dart';

void main() {
  testWidgets('theme builds', (tester) async {
    await tester.pumpWidget(MaterialApp(theme: buildTheme(), home: const Scaffold(body: Text('MyFuture'))));
    expect(find.text('MyFuture'), findsOneWidget);
  });
}
