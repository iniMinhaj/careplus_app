import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'helpers/pump_app.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'register -> otp -> role-select lands on the Home shell; '
    'tab switching preserves branch state; '
    'a full-screen push covers the shell and popping restores it',
    (tester) async {
      await pumpApp(tester);
      await tester.pumpAndSettle();

      // --- Phase 1: register -> otp -> role-select -> Home shell ---
      expect(find.text('Welcome back'), findsOneWidget);
      await tester.tap(find.text("Don't have an account? Register"));
      await tester.pumpAndSettle();

      final fields = find.byType(TextFormField);
      expect(fields, findsNWidgets(4)); // name, email, phone, password
      await tester.enterText(fields.at(0), 'Test User');
      await tester.enterText(fields.at(1), uniqueTestEmail());
      await tester.enterText(fields.at(2), '+8801700000000');
      await tester.enterText(fields.at(3), 'password123');
      await tester.tap(find.text('Send OTP'));
      await tester.pumpAndSettle();

      // Mock backend's verifyOtp() ignores the code and always succeeds.
      expect(find.text('Verify'), findsOneWidget);
      await tester.enterText(find.byType(TextField), '1234');
      await tester.tap(find.text('Verify'));
      await tester.pumpAndSettle();

      expect(find.text('Continue'), findsOneWidget);
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      expect(find.byType(NavigationBar), findsOneWidget);

      // --- Phase 2: StatefulShellRoute.indexedStack preserves branch state ---
      await tester.enterText(
          find.byKey(const Key('home-search-field')), 'cardio');
      await tester.pump();

      await tester.tap(find.text('Appointments'));
      await tester.pumpAndSettle();
      expect(find.text('My Appointments'), findsOneWidget);

      await tester.tap(find.text('Home'));
      await tester.pumpAndSettle();
      expect(find.text('cardio'), findsOneWidget);

      // --- Phase 3: full-screen route covers the shell; pop restores it ---
      await tester.tap(find.byKey(const Key('doctor-card-doc_001')));
      await tester.pumpAndSettle();
      expect(find.byType(NavigationBar), findsNothing);
      expect(find.text('Doctor Details'), findsOneWidget);

      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.text('cardio'), findsOneWidget);
    },
  );
}
