import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../features/appointments/presentation/screens/appointment_detail_screen.dart';
import '../../features/appointments/presentation/screens/appointments_screen.dart';
import '../../features/appointments/presentation/screens/join_call_placeholder_screen.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/booking/domain/entity/appointment.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/otp_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/role_select_screen.dart';
import '../../features/booking/presentation/bloc/booking_bloc.dart';
import '../../features/booking/presentation/screens/booking_confirm_screen.dart';
import '../../features/booking/presentation/screens/booking_payment_screen.dart';
import '../../features/booking/presentation/screens/booking_success_screen.dart';
import '../../features/doctor_detail/presentation/screens/doctor_detail_screen.dart';
import '../../features/health_records/domain/entity/health_record.dart';
import '../../features/health_records/presentation/screens/health_records_screen.dart';
import '../../features/health_records/presentation/screens/record_detail_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/medicine/domain/entity/medicine.dart';
import '../../features/medicine/presentation/bloc/medicine_bloc.dart';
import '../../features/medicine/presentation/screens/add_medicine_screen.dart';
import '../../features/medicine/presentation/screens/adherence_history_screen.dart';
import '../../features/medicine/presentation/screens/medicine_list_screen.dart';
import '../../features/profile/presentation/bloc/profile_bloc.dart';
import '../../features/profile/presentation/bloc/payment_history_bloc.dart';
import '../../features/profile/presentation/bloc/payment_history_event.dart';
import '../../features/profile/presentation/screens/edit_profile_screen.dart';
import '../../features/profile/presentation/screens/payment_history_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../widgets/main_shell.dart';
import '../../features/splash/splash_screen.dart';
import '../di/dependency.dart';
import 'app_routes.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
final _shellNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'shell');

/// Bridges [AuthBloc]'s stream to a [Listenable] so GoRouter re-runs its
/// `redirect` callback whenever auth status changes (login, logout, token
/// expiry) — not just when a navigation call happens.
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<AuthState> stream) {
    _subscription = stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<AuthState> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

GoRouter buildAppRouter(AuthBloc authBloc) {
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: AppRoutes.splash,
    refreshListenable: GoRouterRefreshStream(authBloc.stream),
    // Mirrors the original app's guard surface: only bounce an already
    // authenticated user off the login/register screens. Everything else
    // (splash's own delayed redirect, the post-OTP role-select -> home
    // hop, ProfileScreen's logout listener) is driven by explicit
    // navigation calls, same as before go_router — AuthBloc never actually
    // reaches `authenticated` during the register/OTP flow, only after a
    // real login or a successful status check, so a broader "unauthenticated
    // -> /login" redirect here would incorrectly bounce users straight out
    // of that flow.
    redirect: (context, state) {
      final status = authBloc.state.status;
      final location = state.matchedLocation;
      if (status == AuthStatus.authenticated &&
          (location == AppRoutes.login || location == AppRoutes.register)) {
        return AppRoutes.home;
      }
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: AppRoutes.otp,
        builder: (context, state) => OtpScreen(phone: state.extra as String),
      ),
      GoRoute(
        path: AppRoutes.roleSelect,
        builder: (context, state) => const RoleSelectScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            MainShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            navigatorKey: _shellNavigatorKey,
            routes: [
              GoRoute(
                path: AppRoutes.home,
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.appointments,
                builder: (context, state) => const AppointmentsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.medicines,
                builder: (context, state) => const MedicineListScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.profile,
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.doctorDetail,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => DoctorDetailScreen(
          doctorId: state.pathParameters['doctorId']!,
        ),
      ),
      GoRoute(
        path: AppRoutes.bookingConfirm,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => BlocProvider.value(
          value: state.extra as BookingBloc,
          child: const BookingConfirmScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.bookingPayment,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => BlocProvider.value(
          value: state.extra as BookingBloc,
          child: const BookingPaymentScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.bookingSuccess,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => BlocProvider.value(
          value: state.extra as BookingBloc,
          child: const BookingSuccessScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.appointmentDetail,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => AppointmentDetailScreen(
          appointment: state.extra as Appointment,
        ),
      ),
      GoRoute(
        path: AppRoutes.joinCall,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => JoinCallPlaceholderScreen(
          doctorName: state.extra as String,
        ),
      ),
      GoRoute(
        path: AppRoutes.profileEdit,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => BlocProvider.value(
          value: state.extra as ProfileBloc,
          child: const EditProfileScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.paymentHistory,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => BlocProvider(
          create: (_) =>
              sl<PaymentHistoryBloc>()..add(const PaymentHistoryRequested()),
          child: const PaymentHistoryScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.medicineAdd,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => BlocProvider.value(
          value: state.extra as MedicineBloc,
          child: const AddMedicineScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.medicineAdherence,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => AdherenceHistoryScreen(
          medicines: state.extra as List<Medicine>,
        ),
      ),
      GoRoute(
        path: AppRoutes.healthRecords,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const HealthRecordsScreen(),
      ),
      GoRoute(
        path: AppRoutes.healthRecordDetail,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => RecordDetailScreen(
          record: state.extra as HealthRecord,
        ),
      ),
    ],
  );
}
