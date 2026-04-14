import 'package:flutter_test/flutter_test.dart';
import 'package:yealico/app/app.dart';
import 'package:yealico/core/config/app_config.dart';
import 'package:yealico/core/config/app_flavor.dart';

void main() {
  testWidgets('renders shell details for dev flavor', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const YealicoApp(
        config: AppConfig(
          flavor: AppFlavor.dev,
          appName: 'Yealico (Dev)',
          enableVerboseLogging: true,
        ),
      ),
    );

    expect(find.text('Project Shell'), findsOneWidget);
    expect(find.text('DEV'), findsOneWidget);
    expect(find.text('Android, Web'), findsOneWidget);
    expect(find.text('Enabled'), findsOneWidget);
    expect(find.text('Import Rule (T04)'), findsOneWidget);
  });
}
