import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:santeo_connect/main.dart';
import 'package:santeo_connect/providers/app_providers.dart';

void main() {
  testWidgets('SanteoApp loads correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AppProvider(),
        child: const SanteoApp(),
      ),
    );
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
