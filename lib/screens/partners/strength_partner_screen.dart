import 'package:flutter/material.dart';
import 'package:bloom_app/core/auth/auth_service.dart';
import 'package:bloom_app/data/pairs/pair_repository.dart';
import 'package:bloom_app/theme/bloom_theme.dart';
import 'package:bloom_app/core/theme/theme_service.dart';
import 'package:timeago/timeago.dart' as timeago;

class StrengthPartnerScreen extends StatefulWidget {
  const StrengthPartnerScreen({super.key});

  @override
  State<StrengthPartnerScreen> createState() => _StrengthPartnerScreenState();
}

class _StrengthPartnerScreenState extends State<StrengthPartnerScreen> {
  final _repo = PairRepository();
  bool _isLoading = true;
  Map<String, dynamic>? _activePair;
  String? _inviteCode;
  final _codeController = TextEditingController();
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _checkStatus();
  }

  @override
  void dispose() {
    _codeController.dispose();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
  
  // Refresh status
  Future<void> _checkStatus() async {
    setState(() => _isLoading = true);
    try {
      final pair = await _repo.getActivePair();
      if (mounted) {
        setState(() {
          _activePair = pair;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _createInvite() async {
    setState(() => _isLoading = true);
    try {
      final code = await _repo.createInvite();
      if (mounted) {
        setState(() {
          _inviteCode = code;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _joinPair() async {
    if (_codeController.text.length != 6) return;
    setState(() => _isLoading = true);
    try {
      await _repo.joinPair(_codeController.text.toUpperCase());
      await _checkStatus();
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty || _activePair == null) return;
    
    final content = _messageController.text.trim();
    _messageController.clear();
    
    try {
      await _repo.sendMessage(_activePair!['id'], content);
      // Scroll to bottom after sending
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0, // Items are reversed
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to send: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = AuthService.instance.supabaseUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Strength Partner'),
        backgroundColor: Colors.transparent,
        foregroundColor: theme.colorScheme.onSurface,
        actions: [
          if (_activePair != null)
            IconButton(
              icon: const Icon(Icons.settings_outlined),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Disconnect Partner?'),
                    content: const Text('This will remove your current partner and clear the chat history.'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _repo.leavePair().then((_) => _checkStatus());
                        },
                        child: const Text('Disconnect', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
      extendBodyBehindAppBar: true,
      // Resize to avoid keyboard covering input
      resizeToAvoidBottomInset: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: BloomGradients.getHomeGradient(ThemeService.instance.variant),
        ),
        child: SafeArea(
          child: user == null ? _buildSignInCta() : _buildContent(theme),
        ),
      ),
    );
  }

  Widget _buildSignInCta() {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 64, color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
          const SizedBox(height: 16),
          Text(
            'Sign In to Find a Partner',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurface,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(200, 44),
            ),
            child: const Text('Go to Account Settings'),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(ThemeData theme) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Colors.white));
    }

    if (_activePair != null) {
      return _buildChatInterface(theme);
    }

    return _buildPairingView(theme);
  }

  Widget _buildPairingView(ThemeData theme) {
    // Determine input fill color based on brightness
    final isDark = theme.brightness == Brightness.dark;
    final inputFill = isDark ? Colors.white10 : Colors.grey.shade100;
    final containerFill = isDark ? Colors.white10 : Colors.white;
    final containerBorder = isDark ? Colors.white24 : Colors.black12;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 20),
          Text(
            'Create a Bond',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'Pair with a friend to share streaks and practice together.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),

          // Option A: Generate Code
          if (_inviteCode != null) ...[
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: containerFill,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: containerBorder),
              ),
              child: Column(
                children: [
                  Text('Your Invite Code', 
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6)
                    )
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _inviteCode!,
                    style: TextStyle(
                      fontSize: 32, 
                      fontWeight: FontWeight.bold, 
                      letterSpacing: 4, 
                      color: theme.colorScheme.primary
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ] else ...[
             ElevatedButton(
              onPressed: _createInvite,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
              ),
              child: const Text('Generate Invite Code'),
            ),
             const SizedBox(height: 32),
             Row(children: [
               Expanded(child: Divider(color: theme.dividerColor)), 
               Padding(padding: const EdgeInsets.all(8), child: Text('OR', style: TextStyle(color: theme.disabledColor))), 
               Expanded(child: Divider(color: theme.dividerColor))
             ]),
             const SizedBox(height: 32),
          ],

          // Option B: Enter Code
          TextField(
            controller: _codeController,
            style: theme.textTheme.titleMedium?.copyWith(
              letterSpacing: 2,
              color: theme.colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              hintText: 'ENTER 6-DIGIT CODE',
              hintStyle: theme.textTheme.bodyMedium?.copyWith(
                color: theme.hintColor,
                letterSpacing: 1,
              ),
              filled: true,
              fillColor: inputFill,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
            maxLength: 6,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _joinPair,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: isDark ? Colors.white24 : Colors.black.withValues(alpha: 0.05),
              foregroundColor: theme.colorScheme.onSurface,
              minimumSize: const Size.fromHeight(52), // Match theme buttons
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
            child: const Text('Connect Partner'),
          ),
        ],
      ),
    );
  }

  Widget _buildChatInterface(ThemeData theme) {
    if (_activePair == null) return const SizedBox.shrink();

    final myId = AuthService.instance.supabaseUser?.id;
    final partner1 = _activePair!['partner_1'];
    final partner2 = _activePair!['partner_2'];
    
    // Identify partner
    // If I am user_id_1, my partner is user_id_2 (partner2)
    final isMeUser1 = _activePair!['user_id_1'] == myId;
    final partnerData = isMeUser1 ? partner2 : partner1;
    final partnerId = isMeUser1 ? _activePair!['user_id_2'] : _activePair!['user_id_1'];
    
    final partnerName = partnerData?['username'] ?? 'Partner';
    
    final isDark = theme.brightness == Brightness.dark;
    final inputFill = isDark ? Colors.white10 : Colors.grey.shade200;
    
    return Column(
      children: [
        // 1. Partner Status Header
        if (partnerId != null)
          _buildPartnerStatusHeader(partnerId, partnerName, theme),
          
        Divider(height: 1, color: theme.dividerColor),

        // 2. Chat List
        Expanded(
          child: StreamBuilder<List<Map<String, dynamic>>>(
            stream: _repo.messagesStream(_activePair!['id']),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('Error loading messages', style: TextStyle(color: theme.disabledColor)));
              }
              
              if (!snapshot.hasData) {
                return Center(child: CircularProgressIndicator(color: theme.disabledColor));
              }

              final messages = snapshot.data!;
              
              if (messages.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.chat_bubble_outline, size: 48, color: theme.disabledColor),
                      const SizedBox(height: 16),
                      Text('Start your conversation', style: TextStyle(color: theme.hintColor)),
                    ],
                  ),
                );
              }

              return ListView.builder(
                controller: _scrollController,
                reverse: true, // Show newest at bottom
                padding: const EdgeInsets.all(16),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final msg = messages[index];
                  final isMe = msg['sender_id'] == myId;
                  return _buildMessageBubble(msg, isMe, theme);
                },
              );
            },
          ),
        ),

        // 3. Input Area
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor, 
            border: Border(top: BorderSide(color: theme.dividerColor)),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _messageController,
                  style: theme.textTheme.bodyMedium,
                  decoration: InputDecoration(
                    hintText: 'Message $partnerName...',
                    hintStyle: TextStyle(color: theme.hintColor),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: inputFill,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    isDense: true,
                  ),
                  textCapitalization: TextCapitalization.sentences,
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.send_rounded),
                color: theme.colorScheme.primary,
                onPressed: _sendMessage,
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildPartnerStatusHeader(String partnerId, String partnerName, ThemeData theme) {
    return StreamBuilder<Map<String, dynamic>?>(
      stream: _repo.partnerPresenceStream(partnerId),
      builder: (context, snapshot) {
        final presence = snapshot.data;
        final isActive = presence != null && presence['status'] == 'breathing';
        
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          color: theme.dividerColor.withValues(alpha: 0.1),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 8, height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isActive ? Colors.greenAccent : theme.disabledColor,
                  boxShadow: isActive ? [BoxShadow(color: Colors.greenAccent.withValues(alpha: 0.5), blurRadius: 6)] : null,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                isActive ? '$partnerName is breathing now' : '$partnerName is offline',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isActive ? theme.colorScheme.onSurface : theme.disabledColor,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> msg, bool isMe, ThemeData theme) {
    // Parse time
    final createdAt = DateTime.tryParse(msg['created_at'].toString()) ?? DateTime.now();
    
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        constraints: const BoxConstraints(maxWidth: 280),
        decoration: BoxDecoration(
          color: isMe ? theme.colorScheme.primary : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: isMe ? const Radius.circular(16) : const Radius.circular(2),
            bottomRight: isMe ? const Radius.circular(2) : const Radius.circular(16),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              msg['content'] ?? '',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isMe ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              timeago.format(createdAt, locale: 'en_short'),
              style: theme.textTheme.labelSmall?.copyWith(
                color: (isMe ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface).withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
