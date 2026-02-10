import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/services.dart';
import 'package:quietline_app/services/first_launch_service.dart';
import 'package:quietline_app/screens/shell/quiet_shell_screen.dart';
import 'package:quietline_app/data/forge/forge_service.dart';
import 'package:quietline_app/widgets/ql_primary_button.dart';
import 'package:quietline_app/screens/forge/widgets/armor_reveal_overlay.dart';
import 'package:quietline_app/core/soundscapes/soundscape_service.dart';

class QuietArmorRoomScreen extends StatefulWidget {
  final ArmorPiece? revealedPiece;
  const QuietArmorRoomScreen({super.key, this.revealedPiece});

  @override
  State<QuietArmorRoomScreen> createState() => _QuietArmorRoomScreenState();
}

class _QuietArmorRoomScreenState extends State<QuietArmorRoomScreen> {
  bool _showOnboarding = false;
  bool _showBeginButton = false;
  
  ArmorPiece? _currentRevealPiece;
  bool _isAnimatingSequence = false;
  bool _showRevealOverlay = false;
  final Set<ArmorPiece> _visuallyUnlockedPieces = {};

  @override
  void initState() {
    super.initState();
    _currentRevealPiece = widget.revealedPiece;
    if (_currentRevealPiece != null) {
      _isAnimatingSequence = true;
      _showRevealOverlay = true;
    }
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
        actions: [
          IconButton(
            icon: const Icon(Icons.bug_report_outlined),
            onPressed: () {
              setState(() {
                _currentRevealPiece = ArmorPiece.helmet;
                _isAnimatingSequence = true;
                _showRevealOverlay = true;
              });
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          IgnorePointer(
            ignoring: _isAnimatingSequence || _showOnboarding,
            child: Padding(
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
                  return _ArmorSetCard(
                    set: set,
                    revealedPiece: _currentRevealPiece,
                    visuallyUnlockedPieces: _visuallyUnlockedPieces,
                    onFittingComplete: () {
                      setState(() {
                        if (_currentRevealPiece != null) {
                          _visuallyUnlockedPieces.add(_currentRevealPiece!);
                        }
                        _isAnimatingSequence = false;
                        _currentRevealPiece = null;
                      });
                    },
                  );
                },
              ),
            ),
          ),
          if (_showOnboarding)
            _buildOnboardingOverlay(),
            
          if (_showRevealOverlay && _currentRevealPiece != null)
            ArmorRevealOverlay(
              set: ForgeService.instance.state.currentSet,
              piece: _currentRevealPiece!,
              onFinish: () {
                setState(() {
                  _showRevealOverlay = false;
                  // The fitting animation continues in the background
                });
              },
            ),
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
                'Armor Room',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "This is where your progress takes shape.\n\n"
                "Each piece here is assembled automatically as you return to QuietLine.\n\n"
                "You don’t need to chase anything.\n"
                "Just keep showing up.\n\n"
                "What’s locked now will unlock over time.",
                textAlign: TextAlign.left,
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
                  label: 'Got it',
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
  final ArmorPiece? revealedPiece;
  final Set<ArmorPiece> visuallyUnlockedPieces;
  final VoidCallback onFittingComplete;

  const _ArmorSetCard({
    required this.set,
    this.revealedPiece,
    required this.visuallyUnlockedPieces,
    required this.onFittingComplete,
  });

  String _capitalize(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    
    final forgeService = ForgeService.instance;
    final isCurrentSet = forgeService.state.currentSet == set;
    
    // If a piece was just revealed, we treat it as NOT yet unlocked for the "fitting" reveal logic
    final unlockedPieces = isCurrentSet ? forgeService.state.unlockedPieces : <ArmorPiece>[];
    
    // But if we're actively revealing it, we want it to start "locked" (opacity 0) then animate in.
    final effectiveUnlocked = List<ArmorPiece>.from(unlockedPieces);
    
    // Add locally unlocked pieces (e.g. from debug)
    for (final p in visuallyUnlockedPieces) {
      if (!effectiveUnlocked.contains(p)) {
        effectiveUnlocked.add(p);
      }
    }

    if (revealedPiece != null && isCurrentSet) {
      effectiveUnlocked.remove(revealedPiece);
    }
    
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
                    isLocked: !effectiveUnlocked.contains(ArmorPiece.chestplate),
                    shouldAnimateReveal: revealedPiece == ArmorPiece.chestplate,
                    onRevealComplete: onFittingComplete,
                  ),
                ),
                Positioned(
                  top: 60,
                  child: _PieceWidget(
                    set: set,
                    piece: ArmorPiece.pauldrons,
                    size: 200,
                    isLocked: !effectiveUnlocked.contains(ArmorPiece.pauldrons),
                    shouldAnimateReveal: revealedPiece == ArmorPiece.pauldrons,
                    onRevealComplete: onFittingComplete,
                  ),
                ),
                Positioned(
                  top: 0,
                  child: _PieceWidget(
                    set: set,
                    piece: ArmorPiece.helmet,
                    size: 100,
                    isLocked: !effectiveUnlocked.contains(ArmorPiece.helmet),
                    shouldAnimateReveal: revealedPiece == ArmorPiece.helmet,
                    onRevealComplete: onFittingComplete,
                  ),
                ),
                Positioned(
                  bottom: 20,
                  right: 20,
                  child: _PieceWidget(
                    set: set,
                    piece: ArmorPiece.tool,
                    size: 80,
                    isLocked: !effectiveUnlocked.contains(ArmorPiece.tool),
                    shouldAnimateReveal: revealedPiece == ArmorPiece.tool,
                    onRevealComplete: onFittingComplete,
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
  final bool shouldAnimateReveal;
  final VoidCallback? onRevealComplete;

  const _PieceWidget({
    required this.set,
    required this.piece,
    this.size = 150,
    this.isLocked = false,
    this.shouldAnimateReveal = false,
    this.onRevealComplete,
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
      duration: const Duration(milliseconds: 1200),
    );

    if (widget.shouldAnimateReveal) {
      _startRevealSequence();
    }
  }

  @override
  void didUpdateWidget(_PieceWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.shouldAnimateReveal && !oldWidget.shouldAnimateReveal) {
      _startRevealSequence();
    }
  }

  Future<void> _startRevealSequence() async {
    // Wait for the overlay to finish its thing (it has its own delays)
    // Actually, the overlay calls onFinish which sets state in parent,
    // which rebuilds this with shouldAnimateReveal = true?
    // Wait, I need a better trigger.
    
    // Let's just start it when it appears.
    await Future.delayed(const Duration(milliseconds: 200));
    if (!mounted) return;

    // Reveal animation
    await _controller.forward();
    if (!mounted) return;

    // Wiggle/Finalize
    HapticFeedback.mediumImpact();
    SoundscapeService.instance.playSfx(ForgeService.instance.getRandomHammerSfx());

    widget.onRevealComplete?.call();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final asset = ForgeService.instance.getPieceAsset(widget.set, widget.piece);
    
    if (widget.shouldAnimateReveal) {
      return AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final fade = CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
          ).value;
          
          final scale = TweenSequence<double>([
            TweenSequenceItem(tween: Tween<double>(begin: 1.5, end: 1.0).chain(CurveTween(curve: Curves.easeOutBack)), weight: 1.0),
          ]).animate(CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.8))).value;

          final wiggle = math.sin(_controller.value * 20) * 0.05 * (1.0 - _controller.value);

          return Opacity(
            opacity: fade,
            child: Transform.scale(
              scale: scale,
              child: Transform.rotate(
                angle: wiggle,
                child: SvgPicture.asset(
                  asset,
                  width: widget.size,
                  height: widget.size,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          );
        },
      );
    }
    
    return GestureDetector(
      onTap: widget.isLocked ? null : () => _showZoomedView(context, asset, widget.piece),
      child: Opacity(
        opacity: widget.isLocked ? 0.3 : 1.0,
        child: Hero(
          tag: asset,
          child: SvgPicture.asset(
            asset,
            width: widget.size,
            height: widget.size,
            fit: BoxFit.contain,
          ),
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
