import 'package:flutter/material.dart';
import 'package:quietline_app/data/user/user_service.dart';

// --- Shared Avatar Data ---

const List<Map<String, String>> avatarList = [
  {'id': 'viking', 'name': 'The Viking'},
  {'id': 'cowboy', 'name': 'The Cowboy'},
  {'id': 'wizard', 'name': 'The Wizard'},
  {'id': 'worker', 'name': 'The Construction Worker'},
  {'id': 'king', 'name': 'The King'},
  {'id': 'badboy', 'name': 'The Bad Boy'},
  {'id': 'gentle', 'name': 'The Gentlemen'},
  {'id': 'geek', 'name': 'The Geek'},
  {'id': 'oddball', 'name': 'The Oddball'},
];

class QuietEditProfileScreen extends StatefulWidget {
  const QuietEditProfileScreen({super.key});

  @override
  State<QuietEditProfileScreen> createState() => _QuietEditProfileScreenState();
}

class _QuietEditProfileScreenState extends State<QuietEditProfileScreen> {
  final TextEditingController _usernameController = TextEditingController();
  String _selectedAvatarId = 'viking';
  UserProfile? _user;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await UserService.instance.getOrCreateUser();
    if (mounted) {
      setState(() {
        _user = user;
        _usernameController.text = user.username;
        _selectedAvatarId = user.avatarId;
        _isLoading = false;
      });
    }
  }

  Future<void> _handleSave() async {
    if (_user == null) return;

    final updated = UserProfile(
      id: _user!.id,
      username: _usernameController.text.trim(),
      avatarId: _selectedAvatarId,
    );

    await UserService.instance.updateProfile(updated);
    if (mounted) {
      Navigator.of(context).pop(true);
    }
  }

  void _handleShuffle() {
    setState(() {
      _usernameController.text = UserService.generateRandomUsername();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final Color baseTextColor = textTheme.bodyMedium?.color ?? Colors.white;

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Edit Profile')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          TextButton(
            onPressed: _handleSave,
            child: const Text('Save', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Username Field
            Text(
              'USERNAME',
              style: textTheme.labelSmall?.copyWith(
                letterSpacing: 0.8,
                fontWeight: FontWeight.w600,
                color: baseTextColor.withValues(alpha: 0.4),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                filled: true,
                fillColor: theme.colorScheme.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                suffixIcon: IconButton(
                  icon: Icon(
                    Icons.refresh_rounded,
                    color: theme.colorScheme.primary,
                  ),
                  tooltip: 'Shuffle username',
                  onPressed: _handleShuffle,
                ),
              ),
              style: textTheme.bodyLarge,
            ),

            const SizedBox(height: 32),

            // Avatar Section
            Text(
              'SELECT AVATAR',
              style: textTheme.labelSmall?.copyWith(
                letterSpacing: 0.8,
                fontWeight: FontWeight.w600,
                color: baseTextColor.withValues(alpha: 0.4),
              ),
            ),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1,
              ),
              itemCount: avatarList.length,
              itemBuilder: (context, index) {
                final item = avatarList[index];
                final id = item['id']!;
                final emoji = avatarPresets[id]!;
                final isSelected = _selectedAvatarId == id;

                return GestureDetector(
                  onTap: () => setState(() => _selectedAvatarId = id),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected
                          ? theme.colorScheme.primary.withValues(alpha: 0.1)
                          : theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? theme.colorScheme.primary
                            : baseTextColor.withValues(alpha: 0.08),
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        emoji,
                        style: const TextStyle(fontSize: 32),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
