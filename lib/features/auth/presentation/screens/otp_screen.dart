import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_color.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class OtpScreen extends StatefulWidget {
  final String phone;
  const OtpScreen({super.key, required this.phone});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _otpController = TextEditingController();
  String? _localError;

  void _handleVerify() {
    if (_otpController.text.length != 4) {
      setState(() => _localError = 'Enter the 4-digit OTP');
      return;
    }
    setState(() => _localError = null);
    context.read<AuthBloc>().add(
          AuthOtpVerified(phone: widget.phone, otp: _otpController.text),
        );
  }

  void _handleResend() {
    setState(() => _localError = null);
    context.read<AuthBloc>().add(AuthOtpRequested(phone: widget.phone));
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listenWhen: (previous, current) =>
          current.status == AuthStatus.otpVerified,
      listener: (context, state) {
        context.pushReplacement(AppRoutes.roleSelect);
      },
      builder: (context, state) {
        final isLoading = state.status == AuthStatus.otpVerifying ||
            (state.status == AuthStatus.loading && state.phone == widget.phone);
        final errorMessage = _localError ??
            (state.status == AuthStatus.failure ? state.errorMessage : null);
        return Scaffold(
          appBar: AppBar(title: const Text('Verify Phone')),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Enter the 4-digit code sent to ${widget.phone}',
                      style: const TextStyle(color: AppColors.textSecondary)),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _otpController,
                    keyboardType: TextInputType.number,
                    maxLength: 4,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 24,
                        letterSpacing: 12,
                        fontWeight: FontWeight.w700),
                    decoration: const InputDecoration(
                        counterText: '', hintText: '----'),
                  ),
                  if (errorMessage != null) ...[
                    const SizedBox(height: 8),
                    Text(errorMessage,
                        style: const TextStyle(
                            color: AppColors.danger, fontSize: 13)),
                  ],
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: isLoading ? null : _handleVerify,
                    child: isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2.5),
                          )
                        : const Text('Verify'),
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: TextButton(
                      onPressed: isLoading ? null : _handleResend,
                      child: const Text('Resend OTP'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
