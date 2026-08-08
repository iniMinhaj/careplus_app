import 'package:careplus/core/di/dependency.dart';
import 'package:careplus/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:careplus/main.dart';
import 'package:flutter_test/flutter_test.dart';

/// Boots the real app exactly like `main()` does (minus `runApp`), against
/// the real local mock backend — no `sl` overrides. `setupDependencies()`
/// registers `AuthBloc` as a `registerLazySingleton`, so guard against
/// double-registration if a previous `pumpApp` call already ran in this
/// process (only relevant if a test file ever adds more than one
/// `testWidgets` block).
Future<void> pumpApp(WidgetTester tester) async {
  if (!sl.isRegistered<AuthBloc>()) {
    await setupDependencies();
  }
  await tester.pumpWidget(const CarePlusApp());
  await tester.pump();
}

/// A per-run-unique email so registration never collides with a user
/// persisted to disk by an earlier test run.
String uniqueTestEmail() =>
    'test.${DateTime.now().millisecondsSinceEpoch}@example.com';
