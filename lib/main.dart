import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/di/dependency.dart';
import 'core/notifications/notification_service.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupDependencies();
  await sl<NotificationService>().init();
  runApp(const CarePlusApp());
}

class CarePlusApp extends StatelessWidget {
  const CarePlusApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authBloc = sl<AuthBloc>()..add(const AuthStatusChecked());
    return BlocProvider<AuthBloc>.value(
      value: authBloc,
      child: MaterialApp.router(
        title: 'CarePlus',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        routerConfig: buildAppRouter(authBloc),
      ),
    );
  }
}
