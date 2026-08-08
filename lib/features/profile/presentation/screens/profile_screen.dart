import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:careplus/core/di/dependency.dart';
import 'package:careplus/core/router/app_routes.dart';
import 'package:careplus/core/theme/app_theme.dart';
import 'package:careplus/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:careplus/features/auth/presentation/bloc/auth_event.dart';
import 'package:careplus/features/auth/presentation/bloc/auth_state.dart';
import 'package:careplus/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:careplus/features/profile/presentation/bloc/profile_event.dart';
import 'package:careplus/features/profile/presentation/bloc/profile_state.dart';
import 'package:careplus/widgets/common_widgets.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _handleLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<AuthBloc>().add(const AuthLogoutRequested());
            },
            child: const Text('Logout', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
  }

  Widget _menuTile(IconData icon, String label, VoidCallback? onTap) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.border),
      ),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary),
        title: Text(label, style: const TextStyle(fontSize: 14)),
        trailing: onTap != null
            ? const Icon(Icons.chevron_right, color: AppColors.textSecondary)
            : null,
        onTap: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ProfileBloc>(
      create: (_) => sl<ProfileBloc>()..add(const ProfileRequested()),
      child: BlocListener<AuthBloc, AuthState>(
        listenWhen: (previous, current) =>
            current.status == AuthStatus.unauthenticated,
        listener: (context, state) => context.go(AppRoutes.login),
        child: Scaffold(
          appBar: AppBar(title: const Text('Profile')),
          body: BlocBuilder<ProfileBloc, ProfileState>(
            builder: (context, state) {
              if (state.status == ProfileStatus.loading ||
                  state.status == ProfileStatus.initial) {
                return const LoadingView();
              }
              if (state.status == ProfileStatus.failure) {
                return ErrorView(
                  message: state.errorMessage ?? 'Could not load profile',
                  onRetry: () =>
                      context.read<ProfileBloc>().add(const ProfileRequested()),
                );
              }

              final user = state.user!;
              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 32,
                        backgroundColor: AppColors.border,
                        backgroundImage: NetworkImage(user.photoUrl),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(user.name,
                                style: const TextStyle(
                                    fontSize: 17, fontWeight: FontWeight.w700)),
                            Text(user.email,
                                style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary)),
                            Text(user.phone,
                                style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary)),
                          ],
                        ),
                      ),
                      IconButton(
                          onPressed: () => context.push(
                                AppRoutes.profileEdit,
                                extra: context.read<ProfileBloc>(),
                              ),
                          icon: const Icon(Icons.edit_outlined)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _menuTile(Icons.folder_shared_outlined, 'Health Records',
                      () => context.push(AppRoutes.healthRecords)),
                  _menuTile(Icons.receipt_long_outlined, 'Payment History',
                      () => context.push(AppRoutes.paymentHistory)),
                  _menuTile(Icons.favorite_border,
                      'Blood Group: ${user.bloodGroup}', null),
                  _menuTile(Icons.location_on_outlined, user.address, null),
                  _menuTile(Icons.notifications_outlined,
                      'Notification Settings', () {}),
                  _menuTile(Icons.help_outline, 'Help & Support', () {}),
                  _menuTile(Icons.info_outline, 'About CarePlus', () {}),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _handleLogout(context),
                      icon: const Icon(Icons.logout, color: AppColors.danger),
                      label: const Text('Logout',
                          style: TextStyle(color: AppColors.danger)),
                      style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.danger)),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
