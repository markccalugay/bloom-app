import 'package:flutter/material.dart';
import 'package:bloom_app/data/user/user_service.dart';

// --- Shared Avatar Data ---

const List<Map<String, String>> avatarList = [
  {'id': 'flower', 'name': 'Flower'},
  {'id': 'sun', 'name': 'Sun'},
  {'id': 'moon', 'name': 'Moon'},
  {'id': 'butterfly', 'name': 'Butterfly'},
  {'id': 'sparkles', 'name': 'Sparkles'},
  {'id': 'leaf', 'name': 'Leaf'},
  {'id': 'swan', 'name': 'Swan'},
  {'id': 'cloud', 'name': 'Cloud'},
  {'id': 'heart', 'name': 'Heart'},
];

class BloomEditProfileScreen extends StatefulWidget {
  const BloomEditProfileScreen({super.key});

  @override
  State<BloomEditProfileScreen> createState() => _BloomEditProfileScreenState();
}

class _BloomEditProfileScreenState extends State<BloomEditProfileScreen> {
  final TextEditingController _usernameController = TextEditingController();
  String _selectedAvatarId = 'flower';
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
      createdAt: _user!.createdAt,
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
    final Color baseTextColor = theme.colorScheme.onSurface;

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
