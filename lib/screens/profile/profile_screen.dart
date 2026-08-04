import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../core/network/mock_api_service.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import '../records/health_records_screen.dart';
import '../profile/payment_history_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserModel? _user;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  // TODO(migration): -> ProfileBloc: ProfileRequested event
  Future<void> _loadUser() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });
    try {
      final user = await MockApiService.instance.getCurrentUser();
      setState(() {
        _user = user;
        _isLoading = false;
      });
    } catch (_) {
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pushNamedAndRemoveUntil(
                context, '/login', (route) => false),
            child:
                const Text('Logout', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: _isLoading
          ? const LoadingView()
          : _hasError
              ? ErrorView(message: 'Could not load profile', onRetry: _loadUser)
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 32,
                          backgroundColor: AppColors.border,
                          backgroundImage: NetworkImage(_user!.photoUrl),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(_user!.name,
                                  style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w700)),
                              Text(_user!.email,
                                  style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary)),
                              Text(_user!.phone,
                                  style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary)),
                            ],
                          ),
                        ),
                        IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.edit_outlined)),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _menuTile(Icons.folder_shared_outlined, 'Health Records',
                        () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const HealthRecordsScreen()));
                    }),
                    _menuTile(Icons.receipt_long_outlined, 'Payment History',
                        () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const PaymentHistoryScreen()));
                    }),
                    _menuTile(Icons.favorite_border,
                        'Blood Group: ${_user!.bloodGroup}', null),
                    _menuTile(Icons.location_on_outlined, _user!.address, null),
                    _menuTile(Icons.notifications_outlined,
                        'Notification Settings', () {}),
                    _menuTile(Icons.help_outline, 'Help & Support', () {}),
                    _menuTile(Icons.info_outline, 'About CarePlus', () {}),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _handleLogout,
                        icon: const Icon(Icons.logout, color: AppColors.danger),
                        label: const Text('Logout',
                            style: TextStyle(color: AppColors.danger)),
                        style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.danger)),
                      ),
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
}
