import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
    
    // FORGE DISABLED: We only track session counts now.
    // All other state (ingots, armor, stage) remains static.

    _state = _state.copyWith(
      totalSessions: nextTotalSessions,
      // Ensure we don't accidentally trigger old unlock UI
      recentlyUnlockedPieces: [], 
    );

    // Only persist the session count
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

}
