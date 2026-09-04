import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yeni_oyun_sablon/main.dart';

void main() {
  testWidgets('OyunSablonApp duman testi - Uygulama çökmeden açılır', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: OyunSablonApp(),
      ),
    );

    // Temel MaterialApp widget'ının varlığını doğrula
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
