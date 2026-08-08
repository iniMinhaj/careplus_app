import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'helpers/pump_app.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'the BookingBloc created on doctor detail survives the confirm -> '
    'payment -> success pushes, and "Back to Home" returns to the shell',
    (tester) async {
      await pumpApp(tester);
      await tester.pumpAndSettle();

      // LoginScreen's fields are pre-filled with the seeded user's exact
      // credentials, so tapping Login immediately succeeds.
      expect(find.text('Welcome back'), findsOneWidget);
      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle();
      expect(find.byType(NavigationBar), findsOneWidget);

      await tester.tap(find.byKey(const Key('doctor-card-doc_001')));
      await tester.pumpAndSettle();
      expect(find.text('Doctor Details'), findsOneWidget);

      // doc_001's mock data has a bookable slot on 2026-08-15.
      await tester.tap(find.byKey(const Key('slot-date-2026-08-15')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('10:00 AM'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Continue to Book'));
      await tester.pumpAndSettle();
      expect(find.text('Confirm Booking'), findsOneWidget);

      // Same BookingBloc instance, pushed a second time via `extra`.
      await tester.tap(find.text('Proceed to Payment'));
      await tester.pumpAndSettle();
      expect(find.text('Payment'), findsOneWidget);

      await tester.tap(find.byKey(const Key('pay-button')));
      await tester.pumpAndSettle();

      // Booking success reads the SAME bloc instance seeded two pushes
      // earlier back on the doctor-detail screen.
      expect(find.text('Booking Confirmed!'), findsOneWidget);
      expect(find.textContaining('Dr. Farhana Ahmed'), findsWidgets);

      await tester.tap(find.text('Back to Home'));
      await tester.pumpAndSettle();
      expect(find.byType(NavigationBar), findsOneWidget);

      // Log out so this run doesn't leave an authenticated session behind
      // for the next test file / manual run on this device.
      await tester.tap(find.text('Profile'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Logout'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(TextButton, 'Logout'));
      await tester.pumpAndSettle();
      expect(find.text('Welcome back'), findsOneWidget);
    },
  );
}
