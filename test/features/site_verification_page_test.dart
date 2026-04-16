import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yealico/features/site_session/presentation/site_verification_page.dart';

void main() {
  testWidgets('renders custom web view builder and supports done action', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: SiteVerificationPage(
          siteName: 'Demo Site',
          url: 'https://example.com',
          webViewBuilder: (context, url) {
            return Text('webview:$url');
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Demo Site Verify Session'), findsOneWidget);
    expect(find.text('webview:https://example.com'), findsOneWidget);
    expect(find.text('Done and Refresh'), findsOneWidget);
  });

  testWidgets('shows invalid url message when url is malformed', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: SiteVerificationPage(
          siteName: 'Demo Site',
          url: 'invalid-url',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Verification URL is invalid.'), findsOneWidget);
  });
}
