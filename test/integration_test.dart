import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:multiai_hub/app.dart';
import 'package:multiai_hub/ui/webview/webview_screen.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Integration Tests', () {
    testWidgets('App launches and shows home screen', (tester) async {
      await tester.pumpWidget(const MultiAIHubApp());
      await tester.pumpAndSettle();
      expect(find.text('MultiAI Hub'), findsOneWidget);
    });

    testWidgets('Navigate to all screens via bottom nav', (tester) async {
      await tester.pumpWidget(const MultiAIHubApp());
      await tester.pumpAndSettle();

      // Skip onboarding if shown
      if (find.text('Welcome to MultiAI Hub').evaluate().isNotEmpty) {
        await tester.tap(find.text('Get Started'));
        await tester.pumpAndSettle();
      }

      // Navigate through each tab
      final navItems = [
        'Home',
        'Tabs',
        'Ask All',
        'Pipelines',
        'Analytics',
        'Notes',
        'Compare',
        'Settings',
      ];

      for (int i = 0; i < navItems.length; i++) {
        await tester.tap(find.text(navItems[i]));
        await tester.pumpAndSettle();
      }
    });

    testWidgets('Open AI provider in WebView', (tester) async {
      await tester.pumpWidget(const MultiAIHubApp());
      await tester.pumpAndSettle();

      // Skip onboarding
      if (find.text('Welcome to MultiAI Hub').evaluate().isNotEmpty) {
        await tester.tap(find.text('Get Started'));
        await tester.pumpAndSettle();
      }

      // Find first provider card and tap it
      final providerFinder = find.byType(Card).first;
      await tester.tap(providerFinder);
      await tester.pumpAndSettle();

      // Verify WebView screen opens
      expect(find.byType(WebViewScreen), findsOneWidget);
    });

    testWidgets('Add custom provider flow', (tester) async {
      await tester.pumpWidget(const MultiAIHubApp());
      await tester.pumpAndSettle();

      // Skip onboarding
      if (find.text('Welcome to MultiAI Hub').evaluate().isNotEmpty) {
        await tester.tap(find.text('Get Started'));
        await tester.pumpAndSettle();
      }

      // Tap add button
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      // Fill form
      await tester.enterText(find.byType(TextFormField).elementAt(0), 'Test AI');
      await tester.enterText(find.byType(TextFormField).elementAt(1), 'https://test.ai.com');
      await tester.pumpAndSettle();

      // Submit
      await tester.tap(find.text('Add').last);
      await tester.pumpAndSettle();
    });
  });
}
