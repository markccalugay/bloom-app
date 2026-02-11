import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:quietline_app/core/storekit/storekit_service.dart';
import 'dart:math' as math;
import '../../core/backup/backup_coordinator.dart';
import '../../core/entitlements/premium_entitlement.dart';

enum ArmorSet {
  knight,
  legionary,
  samurai,
}

enum ArmorPiece {
  helmet,
  tool,
  pauldrons,
  chestplate,
  greaves,
}

enum IronStage {
  raw,
  ingot,
  polished,
}

class ForgeState {
  final ArmorSet currentSet;
  final List<ArmorPiece> unlockedPieces;
  final IronStage ironStage;
  final int polishedIngotCount;
  final int totalSessions;
  final List<ArmorPiece> recentlyUnlockedPieces;
  final bool hasSeenExplanation;

  ForgeState({
    required this.currentSet,
    required this.unlockedPieces,
    required this.ironStage,
    required this.polishedIngotCount,
    required this.totalSessions,
    required this.recentlyUnlockedPieces,
    required this.hasSeenExplanation,
  });

  ForgeState copyWith({
    ArmorSet? currentSet,
    List<ArmorPiece>? unlockedPieces,
    IronStage? ironStage,
    int? polishedIngotCount,
    int? totalSessions,
    List<ArmorPiece>? recentlyUnlockedPieces,
    bool? hasSeenExplanation,
  }) {
    return ForgeState(
      currentSet: currentSet ?? this.currentSet,
      unlockedPieces: unlockedPieces ?? this.unlockedPieces,
      ironStage: ironStage ?? this.ironStage,
      polishedIngotCount: polishedIngotCount ?? this.polishedIngotCount,
      totalSessions: totalSessions ?? this.totalSessions,
      recentlyUnlockedPieces: recentlyUnlockedPieces ?? this.recentlyUnlockedPieces,
      hasSeenExplanation: hasSeenExplanation ?? this.hasSeenExplanation,
    );
  }
}

class ForgeService extends ChangeNotifier {
  static final ForgeService instance = ForgeService._internal();
  ForgeService._internal();

  static const String _currentSetKey = 'ql_forge_set';
  static const String _ironStageKey = 'ql_forge_iron_stage';
  static const String _unlockedPiecesKey = 'ql_forge_unlocked_pieces';
  static const String _ingotCountKey = 'ql_forge_ingot_count';
  static const String _totalSessionsKey = 'ql_forge_total_sessions';
  static const String _hasSeenExplanationKey = 'ql_forge_has_seen_explanation';

  late ForgeState _state;
  ForgeState get state => _state;

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;
    final prefs = await SharedPreferences.getInstance();

    final setIdx = prefs.getInt(_currentSetKey) ?? 0;
    final stageIdx = prefs.getInt(_ironStageKey) ?? 0;
    final unlockedPieceNames = prefs.getStringList(_unlockedPiecesKey) ?? [];
    final ingotCount = prefs.getInt(_ingotCountKey) ?? 0;
    final totalSessions = prefs.getInt(_totalSessionsKey) ?? 0;
    final hasSeenExplanation = prefs.getBool(_hasSeenExplanationKey) ?? false;

    _state = ForgeState(
      currentSet: ArmorSet.values[setIdx],
      ironStage: IronStage.values[stageIdx.clamp(0, IronStage.values.length - 1)],
      unlockedPieces: unlockedPieceNames
          .map((name) => ArmorPiece.values.firstWhere((e) => e.name == name))
          .toList(),
      polishedIngotCount: ingotCount,
      totalSessions: totalSessions,
      recentlyUnlockedPieces: [],
      hasSeenExplanation: hasSeenExplanation,
    );

    _initialized = true;
    notifyListeners();
  }

  Future<void> advanceProgress() async {
    final prefs = await SharedPreferences.getInstance();

    final nextTotalSessions = _state.totalSessions + 1;
    
    IronStage nextStage;
    if (nextTotalSessions == 1) {
      nextStage = IronStage.raw;
    } else if (nextTotalSessions == 2) {
      nextStage = IronStage.ingot;
    } else {
      nextStage = IronStage.polished;
    }

    int nextIngotCount = _state.polishedIngotCount;
    if (nextTotalSessions >= 3) {
      nextIngotCount += 1;
    }

    List<ArmorPiece> nextUnlocked = List.from(_state.unlockedPieces);
    
    // Check for automatic unlocks
    final craftingRequirements = {
      ArmorPiece.helmet: 1,
      ArmorPiece.tool: 2,
      ArmorPiece.pauldrons: 3,
      ArmorPiece.chestplate: 5,
      ArmorPiece.greaves: 8,
    };

    // We unlock pieces in a specific order
    final unlockOrder = [
      ArmorPiece.helmet,
      ArmorPiece.tool,
      ArmorPiece.pauldrons,
      ArmorPiece.chestplate,
      ArmorPiece.greaves,
    ];

    List<ArmorPiece> recentlyUnlocked = [];
    final bool isPremium = StoreKitService.instance.isPremium.value;

    for (final piece in unlockOrder) {
      if (!nextUnlocked.contains(piece)) {
        // Restriction check
        if (!isPremium) {
          // Free users can only forge Knight Helmet and Tool
          final isFreePiece = _state.currentSet == ArmorSet.knight && 
                             (piece == ArmorPiece.helmet || piece == ArmorPiece.tool);
          if (!isFreePiece) break;
        }

        final req = craftingRequirements[piece]!;
        if (nextIngotCount >= req) {
          nextIngotCount -= req;
          nextUnlocked.add(piece);
          recentlyUnlocked.add(piece);
        } else {
          // Cannot unlock this or subsequent pieces
          break;
        }
      }
    }

    _state = _state.copyWith(
      ironStage: nextStage,
      unlockedPieces: nextUnlocked,
      polishedIngotCount: nextIngotCount,
      totalSessions: nextTotalSessions,
      recentlyUnlockedPieces: recentlyUnlocked,
    );

    await prefs.setInt(_ironStageKey, _state.ironStage.index);
    await prefs.setStringList(
      _unlockedPiecesKey,
      _state.unlockedPieces.map((e) => e.name).toList(),
    );
    await prefs.setInt(_ingotCountKey, _state.polishedIngotCount);
    await prefs.setInt(_totalSessionsKey, _state.totalSessions);

    // Trigger backup if Premium
    if (PremiumEntitlement.instance.isPremium) {
      BackupCoordinator.instance.runBackup();
    }

    notifyListeners();
  }

  Future<void> clearRecentlyUnlocked() async {
    _state = _state.copyWith(recentlyUnlockedPieces: []);
    notifyListeners();
  }

  Future<void> markExplanationSeen() async {
    final prefs = await SharedPreferences.getInstance();
    _state = _state.copyWith(hasSeenExplanation: true);
    await prefs.setBool(_hasSeenExplanationKey, true);
    notifyListeners();
  }

  Future<void> setCurrentSet(ArmorSet set) async {
    final prefs = await SharedPreferences.getInstance();
    _state = _state.copyWith(currentSet: set);
    await prefs.setInt(_currentSetKey, set.index);

    // Trigger backup if Premium
    if (PremiumEntitlement.instance.isPremium) {
      BackupCoordinator.instance.runBackup();
    }

    notifyListeners();
  }

  // Debug methods
  Future<void> debugReset() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_currentSetKey);
    await prefs.remove(_ironStageKey);
    await prefs.remove(_unlockedPiecesKey);
    await prefs.remove(_ingotCountKey);
    await prefs.remove(_totalSessionsKey);
    await prefs.remove(_hasSeenExplanationKey);
    _initialized = false;
    await initialize();
  }

  Future<void> debugSetStage(IronStage stage) async {
    final prefs = await SharedPreferences.getInstance();
    _state = _state.copyWith(ironStage: stage);
    await prefs.setInt(_ironStageKey, stage.index);
    notifyListeners();
  }

  Future<void> debugAddPiece(ArmorPiece piece) async {
     final prefs = await SharedPreferences.getInstance();
     if (!_state.unlockedPieces.contains(piece)) {
       final nextUnlocked = List<ArmorPiece>.from(_state.unlockedPieces)..add(piece);
       _state = _state.copyWith(unlockedPieces: nextUnlocked);
       await prefs.setStringList(_unlockedPiecesKey, nextUnlocked.map((e) => e.name).toList());
       notifyListeners();
     }
  }

  String get currentAsset {
    if (_state.ironStage == IronStage.raw) return 'assets/tools/iron_raw.svg';
    if (_state.ironStage == IronStage.ingot) return 'assets/tools/iron_ingot.svg';
    if (_state.ironStage == IronStage.polished) return 'assets/tools/iron_polished.svg';
    
    return 'assets/tools/iron_raw.svg';
  }

  String getPieceAsset(ArmorSet set, ArmorPiece piece) {
    if (piece == ArmorPiece.tool) {
      return 'assets/tools/tool_${set.name}_${_getToolName(set)}.svg';
    }
    final setName = set.name;
    final pieceName = piece.name;
    return 'assets/armor/$setName/${setName}_$pieceName.svg';
  }

  String _getToolName(ArmorSet set) {
    switch (set) {
      case ArmorSet.knight: return 'longsword';
      case ArmorSet.legionary: return 'gladius';
      case ArmorSet.samurai: return 'katana';
    }
  }

  String getRandomHammerSfx() {
    final rng = math.Random();
    final n = rng.nextInt(3) + 1;
    return 'sfx/ql_sfx_hammer_anvil_$n.wav';
  }
}
