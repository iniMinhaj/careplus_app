import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_color.dart';

/// Honest placeholder for the real-time video consultation experience.
/// Live video calling is explicitly out of scope for this build — this
/// screen exists so the "Join Call" entry point is visible and truthful
/// about its state instead of being silently omitted.
class JoinCallPlaceholderScreen extends StatelessWidget {
  final String doctorName;

  const JoinCallPlaceholderScreen({super.key, required this.doctorName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Join Call')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.videocam_outlined,
                    color: AppColors.primary, size: 40),
              ),
              const SizedBox(height: 20),
              const Text(
                'Video calling is coming soon',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                'This is a placeholder for the real-time consultation experience '
                'with $doctorName. Live video calling is intentionally out of '
                'scope for this build.',
                style: const TextStyle(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => context.pop(),
                  child: const Text('Back to appointment'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
