import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:quietline_app/services/first_launch_service.dart';
import 'package:quietline_app/screens/shell/quiet_shell_screen.dart';
import 'package:quietline_app/data/forge/forge_service.dart';
import 'package:quietline_app/widgets/ql_primary_button.dart';
import 'package:quietline_app/theme/ql_theme.dart';

class QuietArmorRoomScreen extends StatefulWidget {
  const QuietArmorRoomScreen({super.key});

  @override
  State<QuietArmorRoomScreen> createState() => _QuietArmorRoomScreenState();
}

class _QuietArmorRoomScreenState extends State<QuietArmorRoomScreen> {
  bool _showOnboarding = false;

  @override
  void initState() {
    super.initState();
    _checkOnboarding();
  }

  Future<void> _checkOnboarding() async {
    final hasSeen = await FirstLaunchService.instance.hasSeenArmorOnboarding();
    if (!hasSeen && mounted) {
      setState(() => _showOnboarding = true);
    }
  }

  Future<void> _dismissOnboarding() async {
    await FirstLaunchService.instance.markArmorOnboardingSeen();
    if (!mounted) return;
    setState(() => _showOnboarding = false);
    
    // As per user request: "After that, then close the window and bring the user back home."
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const QuietShellScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Armor Room'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 1,
                childAspectRatio: 0.8,
                mainAxisSpacing: 24,
              ),
              itemCount: ArmorSet.values.length,
              itemBuilder: (context, index) {
                final set = ArmorSet.values[index];
                return _ArmorSetCard(set: set);
              },
            ),
          ),
          if (_showOnboarding)
            _buildOnboardingOverlay(),
        ],
      ),
    );
  }

  Widget _buildOnboardingOverlay() {
    return Container(
      color: Colors.black.withValues(alpha: 0.85),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF0F141A),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF2A3340)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.shield_rounded, size: 64, color: Color(0xFF2FE6D2)),
              const SizedBox(height: 24),
              const Text(
                'Forge Your Resilience',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Every day you show up is a strike of the hammer. Daily practice hardens your mind and unlocks pieces of legendary armor.\n\nKeep growing, and your progress will become visible here.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  height: 1.5,
                  color: Color(0xFFB9C3CF),
                ),
              ),
              const SizedBox(height: 32),
              QLPrimaryButton(
                label: 'Begin Journey',
                onPressed: _dismissOnboarding,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ArmorSetCard extends StatelessWidget {
  final ArmorSet set;

  const _ArmorSetCard({required this.set});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    
    // Check which pieces are unlocked for THIS set
    // Simplified: our ForgeService currently only tracks a single "currentSet".
    // For MVP, we'll assume the user is working on one set at a time or 
    // we'll filter unlocked pieces by set name if we store them globally.
    final forgeService = ForgeService.instance;
    final isCurrentSet = forgeService.state.currentSet == set;
    final unlockedPieces = isCurrentSet ? forgeService.state.unlockedPieces : <ArmorPiece>[];
    final progressLabel = '${unlockedPieces.length}/3 pieces unlocked';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F26),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF2A3340)),
      ),
      child: Column(
        children: [
          Text(
            set.name.toUpperCase(),
            style: textTheme.titleMedium?.copyWith(
              letterSpacing: 1.5,
              fontWeight: FontWeight.bold,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            progressLabel,
            style: textTheme.bodySmall?.copyWith(
              color: Colors.white38,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Display pieces
                Positioned(
                  top: 60,
                  child: _PieceWidget(
                    set: set,
                    piece: ArmorPiece.chestplate,
                    size: 200,
                    isLocked: !unlockedPieces.contains(ArmorPiece.chestplate),
                    isNew: isCurrentSet && forgeService.state.ironStage == IronStage.raw && unlockedPieces.isNotEmpty && unlockedPieces.last == ArmorPiece.chestplate,
                  ),
                ),
                Positioned(
                  top: 60,
                  child: _PieceWidget(
                    set: set,
                    piece: ArmorPiece.pauldrons,
                    size: 200,
                    isLocked: !unlockedPieces.contains(ArmorPiece.pauldrons),
                    isNew: isCurrentSet && forgeService.state.ironStage == IronStage.raw && unlockedPieces.isNotEmpty && unlockedPieces.last == ArmorPiece.pauldrons,
                  ),
                ),
                Positioned(
                  top: 0,
                  child: _PieceWidget(
                    set: set,
                    piece: ArmorPiece.helmet,
                    size: 100,
                    isLocked: !unlockedPieces.contains(ArmorPiece.helmet),
                    isNew: isCurrentSet && forgeService.state.ironStage == IronStage.raw && unlockedPieces.isNotEmpty && unlockedPieces.last == ArmorPiece.helmet,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PieceWidget extends StatefulWidget {
  final ArmorSet set;
  final ArmorPiece piece;
  final double size;
  final bool isLocked;
  final bool isNew;

  const _PieceWidget({
    required this.set,
    required this.piece,
    this.size = 150,
    this.isLocked = false,
    this.isNew = false,
  });

  @override
  State<_PieceWidget> createState() => _PieceWidgetState();
}

class _PieceWidgetState extends State<_PieceWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isNew) {
      _controller.stop();
      _controller.value = 0;
    } else {
      if (!_controller.isAnimating) _controller.repeat(reverse: true);
    }

    final asset = ForgeService.instance.getPieceAsset(widget.set, widget.piece);
    
    return GestureDetector(
      onTap: widget.isLocked ? null : () => _showZoomedView(context, asset, widget.piece),
      child: ScaleTransition(
        scale: widget.isNew ? _scaleAnimation : const AlwaysStoppedAnimation(1.0),
        child: Opacity(
          opacity: widget.isLocked ? 0.3 : 1.0,
          child: SvgPicture.asset(
            asset,
            width: widget.size,
            height: widget.size,
            fit: BoxFit.contain,
            colorFilter: ColorFilter.mode(
              widget.isLocked ? QLColors.armorLockedFill : QLColors.armorIronSaturated,
              BlendMode.srcIn,
            ),
          ),
        ),
      ),
    );
  }

  void _showZoomedView(BuildContext context, String asset, ArmorPiece piece) {
    final inscriptions = {
      ArmorPiece.helmet: "Conquer the mind, and you conquer the world.",
      ArmorPiece.chestplate: "Hardship is the only way to the forge.",
      ArmorPiece.pauldrons: "Bear the weight of your own silence.",
    };

    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
             Hero(
               tag: asset,
               child: SvgPicture.asset(asset, width: 300, height: 300),
             ),
             const SizedBox(height: 24),
             Text(
               inscriptions[piece] ?? "",
               textAlign: TextAlign.center,
               style: const TextStyle(
                 color: Colors.white,
                 fontSize: 18,
                 fontStyle: FontStyle.italic,
                 fontFamily: 'serif',
               ),
             ),
             const SizedBox(height: 32),
             QLPrimaryButton(
               label: 'Close',
               onPressed: () => Navigator.pop(context),
             ),
          ],
        ),
      ),
    );
  }
}
