import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_routes.dart';
import '../../core/theme/app_theme.dart';
import '../auth/presentation/bloc/auth_bloc.dart';
import '../auth/presentation/bloc/auth_state.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _redirectWhenReady();
  }

  Future<void> _redirectWhenReady() async {
    final authBloc = context.read<AuthBloc>();

    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;

    var status = authBloc.state.status;
    if (status != AuthStatus.authenticated &&
        status != AuthStatus.unauthenticated) {
      status = await authBloc.stream
          .firstWhere((s) =>
              s.status == AuthStatus.authenticated ||
              s.status == AuthStatus.unauthenticated)
          .then((s) => s.status);
    }
    if (!mounted) return;

    context.go(
      status == AuthStatus.authenticated ? AppRoutes.home : AppRoutes.login,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(Icons.favorite,
                  color: AppColors.primary, size: 48),
            ),
            const SizedBox(height: 20),
            const Text(
              'CarePlus',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your health, one tap away',
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 40),
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                  color: Colors.white, strokeWidth: 2.5),
            ),
          ],
        ),
      ),
    );
  }
}
