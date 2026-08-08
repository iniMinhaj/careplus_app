import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'helpers/pump_app.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    // Guarantees this scenario is deterministic regardless of a session left
    // over from a prior manual run or another test file on this device.
    await const FlutterSecureStorage().deleteAll();
  });

  testWidgets('fresh unauthenticated launch redirects splash -> login',
      (tester) async {
    await pumpApp(tester);
    await tester.pumpAndSettle();

    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
  });
}
