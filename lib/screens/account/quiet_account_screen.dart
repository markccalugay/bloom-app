import 'package:flutter/material.dart';
import 'package:quietline_app/theme/ql_theme.dart';
import 'package:quietline_app/data/user/user_service.dart';

/// Simple MVP account screen.
/// Shows the anonymous user's display name.
class QuietAccountScreen extends StatefulWidget {
  const QuietAccountScreen({super.key});

  @override
  State<QuietAccountScreen> createState() => _QuietAccountScreenState();
}

class _QuietAccountScreenState extends State<QuietAccountScreen> {
  late final Future<UserProfile> _userFuture;

  @override
  void initState() {
    super.initState();
    _userFuture = UserService.instance.getOrCreateUser();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your account'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: FutureBuilder<UserProfile>(
          future: _userFuture,
          builder: (context, snapshot) {
            // -------- Loading state --------
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            // -------- Error state (very simple for MVP) --------
            if (snapshot.hasError || !snapshot.hasData) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Text(
                    'We had trouble loading your account details.\n'
                    'You\'re still anonymous and can use QuietLine as normal.',
                    textAlign: TextAlign.center,
                    style: textTheme.bodyMedium,
                  ),
                ),
              );
            }

            final user = snapshot.data!;
            final displayName = user.username;

            // -------- Normal content --------
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 32),

                    // Avatar
                    CircleAvatar(
                      radius: 32,
                      backgroundColor:
                          QLColors.primaryTeal.withValues(alpha: 0.2),
                      child: const Icon(
                        Icons.person_rounded,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Display name
                    Text(
                      displayName,
                      textAlign: TextAlign.center,
                      style: textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Caption
                    Text(
                      'You’re anonymous to other members.\n'
                      'You can customize this later.',
                      textAlign: TextAlign.center,
                      style: textTheme.bodySmall?.copyWith(
                        color: (textTheme.bodySmall?.color ?? Colors.white)
                            .withValues(alpha: 0.8),
                      ),
                    ),

                    const SizedBox(height: 48),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}