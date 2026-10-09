import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:travelindo/config/routes.dart';
import 'package:travelindo/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('app launches and shows loading or home', (tester) async {
    app.main();
    await tester.pump();
    await tester.pumpAndSettle(const Duration(seconds: 8));
    expect(find.byType(MaterialApp), findsWidgets);
  });

  testWidgets('router paths are defined for V11 routes', (tester) async {
    expect(AppRoutePaths.favorites, '/favorites');
    expect(AppRoutePaths.following, '/following');
    expect(AppRoutePaths.loyaltyHistory, '/loyalty/history');
    expect(AppRoutePaths.mitraTourPackages, '/mitra/tour-packages');
    expect(AppRoutePaths.mitraPublicProfile('abc'), '/mitra-stores/abc');
  });
}
