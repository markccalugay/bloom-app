import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:quietline_app/services/first_launch_service.dart';
import 'package:quietline_app/screens/shell/quiet_shell_screen.dart';
import 'package:quietline_app/data/forge/forge_service.dart';
import 'package:quietline_app/widgets/ql_primary_button.dart';

class QuietArmorRoomScreen extends StatefulWidget {
  const QuietArmorRoomScreen({super.key});

  @override
  State<QuietArmorRoomScreen> createState() => _QuietArmorRoomScreenState();
}

class _QuietArmorRoomScreenState extends State<QuietArmorRoomScreen> {
  bool _showOnboarding = false;
  bool _showBeginButton = false;

  @override
  void initState() {
    super.initState();
    _checkOnboarding();
  }

  Future<void> _checkOnboarding() async {
    final hasSeen = await FirstLaunchService.instance.hasSeenArmorOnboarding();
    if (!hasSeen && mounted) {
      setState(() => _showOnboarding = true);
      // Delay showing the "Begin" button
      Future.delayed(const Duration(milliseconds: 2500), () {
        if (mounted) {
          setState(() => _showBeginButton = true);
        }
      });
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      color: Colors.black.withValues(alpha: 0.85), // Keep dimming modal dark for focus
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0F141A) : theme.cardColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark ? const Color(0xFF2A3340) : theme.dividerColor,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.shield_rounded, size: 64, color: Color(0xFF2FE6D2)),
              const SizedBox(height: 24),
              Text(
                'The Forge',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "This is where QuietLine tracks consistency.\n\n"
                "Each time you return, iron refines a little more.\n"
                "Raw iron becomes an ingot.\n"
                "An ingot becomes polished iron.\n\n"
                "Polished iron is used to assemble armor.\n"
                "Armor is built slowly, over time.\n\n"
                "There’s no penalty for missing a day.\n"
                "When you come back, you continue.",
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  height: 1.5,
                  color: isDark ? const Color(0xFFB9C3CF) : theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 32),
              AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: _showBeginButton ? 1.0 : 0.0,
                child: QLPrimaryButton(
                  label: 'Begin',
                  onPressed: _showBeginButton ? _dismissOnboarding : () {},
                ),
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

  String _capitalize(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    
    final forgeService = ForgeService.instance;
    final isCurrentSet = forgeService.state.currentSet == set;
    final unlockedPieces = isCurrentSet ? forgeService.state.unlockedPieces : <ArmorPiece>[];
    
    String progressLabel = 'Armor Assembled';
    
    final unlockOrder = [
      ArmorPiece.helmet,
      ArmorPiece.tool,
      ArmorPiece.pauldrons,
      ArmorPiece.chestplate,
    ];

    if (unlockedPieces.length < unlockOrder.length) {
      final nextPiece = unlockOrder[unlockedPieces.length];
      final requirements = {
        ArmorPiece.helmet: 1,
        ArmorPiece.tool: 2,
        ArmorPiece.pauldrons: 3,
        ArmorPiece.chestplate: 5,
      };
      final req = requirements[nextPiece]!;
      final current = forgeService.state.polishedIngotCount;
      progressLabel = '${_capitalize(nextPiece.name)} Requires $req polished iron $current / $req';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.dark 
            ? const Color(0xFF1A1F26) 
            : theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.brightness == Brightness.dark 
              ? const Color(0xFF2A3340) 
              : theme.dividerColor,
        ),
      ),
      child: Column(
        children: [
          Text(
            set.name.toUpperCase(),
            style: textTheme.titleMedium?.copyWith(
              letterSpacing: 1.5,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            progressLabel,
            style: textTheme.bodySmall?.copyWith(
              color: textTheme.bodySmall?.color?.withValues(alpha: 0.5),
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
                  ),
                ),
                Positioned(
                  top: 60,
                  child: _PieceWidget(
                    set: set,
                    piece: ArmorPiece.pauldrons,
                    size: 200,
                    isLocked: !unlockedPieces.contains(ArmorPiece.pauldrons),
                  ),
                ),
                Positioned(
                  top: 0,
                  child: _PieceWidget(
                    set: set,
                    piece: ArmorPiece.helmet,
                    size: 100,
                    isLocked: !unlockedPieces.contains(ArmorPiece.helmet),
                  ),
                ),
                Positioned(
                  bottom: 20,
                  right: 20,
                  child: _PieceWidget(
                    set: set,
                    piece: ArmorPiece.tool,
                    size: 80,
                    isLocked: !unlockedPieces.contains(ArmorPiece.tool),
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

  const _PieceWidget({
    required this.set,
    required this.piece,
    this.size = 150,
    this.isLocked = false,
  });

  @override
  State<_PieceWidget> createState() => _PieceWidgetState();
}

class _PieceWidgetState extends State<_PieceWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _controller.stop();
    _controller.value = 0;

    final asset = ForgeService.instance.getPieceAsset(widget.set, widget.piece);
    
    return GestureDetector(
      onTap: widget.isLocked ? null : () => _showZoomedView(context, asset, widget.piece),
      child: Opacity(
        opacity: widget.isLocked ? 0.3 : 1.0,
        child: SvgPicture.asset(
          asset,
          width: widget.size,
          height: widget.size,
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  void _showZoomedView(BuildContext context, String asset, ArmorPiece piece) {
    final theme = Theme.of(context);
    final inscriptions = {
      ArmorPiece.helmet: "Conquer the mind, and you conquer the world.",
      ArmorPiece.chestplate: "Hardship is the only way to the forge.",
      ArmorPiece.pauldrons: "Bear the weight of your own silence.",
      ArmorPiece.tool: "A tool shaped by discipline.",
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
               style: TextStyle(
                 color: theme.brightness == Brightness.dark ? Colors.white : theme.textTheme.bodyLarge?.color,
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
