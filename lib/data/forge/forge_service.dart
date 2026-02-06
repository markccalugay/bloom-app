import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math' as math;

enum ArmorSet {
  knight,
  legionary,
  samurai,
}

enum ArmorPiece {
  helmet,
  chestplate,
  pauldrons,
}

enum IronStage {
  raw,
  forged,
  polished,
  complete,
}

class ForgeState {
  final ArmorSet currentSet;
  final List<ArmorPiece> unlockedPieces;
  final IronStage ironStage;

  ForgeState({
    required this.currentSet,
    required this.unlockedPieces,
    required this.ironStage,
  });

  ForgeState copyWith({
    ArmorSet? currentSet,
    List<ArmorPiece>? unlockedPieces,
    IronStage? ironStage,
  }) {
    return ForgeState(
      currentSet: currentSet ?? this.currentSet,
      unlockedPieces: unlockedPieces ?? this.unlockedPieces,
      ironStage: ironStage ?? this.ironStage,
    );
  }
}

class ForgeService extends ChangeNotifier {
  static final ForgeService instance = ForgeService._internal();
  ForgeService._internal();

  static const String _currentSetKey = 'ql_forge_set';
  static const String _ironStageKey = 'ql_forge_iron_stage';
  static const String _unlockedPiecesKey = 'ql_forge_unlocked_pieces';

  late ForgeState _state;
  ForgeState get state => _state;

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;
    final prefs = await SharedPreferences.getInstance();

    final setIdx = prefs.getInt(_currentSetKey) ?? 0;
    final stageIdx = prefs.getInt(_ironStageKey) ?? 0;
    final unlockedPieceNames = prefs.getStringList(_unlockedPiecesKey) ?? [];

    _state = ForgeState(
      currentSet: ArmorSet.values[setIdx],
      ironStage: IronStage.values[stageIdx],
      unlockedPieces: unlockedPieceNames
          .map((name) => ArmorPiece.values.firstWhere((e) => e.name == name))
          .toList(),
    );

    _initialized = true;
    notifyListeners();
  }

  Future<void> advanceProgress() async {
    final prefs = await SharedPreferences.getInstance();

    IronStage nextStage;
    List<ArmorPiece> nextUnlocked = List.from(_state.unlockedPieces);

    if (_state.ironStage == IronStage.polished) {
      // Unlock next piece
      nextStage = IronStage.raw; // Reset for next piece
      if (nextUnlocked.length < ArmorPiece.values.length) {
        nextUnlocked.add(ArmorPiece.values[nextUnlocked.length]);
      } else {
        // All pieces of current set unlocked? 
        // For now just stay at complete if everything is done.
        nextStage = IronStage.complete;
      }
    } else if (_state.ironStage == IronStage.complete) {
      // Already complete, maybe move to next set?
      // For now stay complete.
      nextStage = IronStage.complete;
    } else {
      nextStage = IronStage.values[_state.ironStage.index + 1];
    }

    _state = _state.copyWith(
      ironStage: nextStage,
      unlockedPieces: nextUnlocked,
    );

    await prefs.setInt(_ironStageKey, _state.ironStage.index);
    await prefs.setStringList(
      _unlockedPiecesKey,
      _state.unlockedPieces.map((e) => e.name).toList(),
    );

    notifyListeners();
  }

  Future<void> setCurrentSet(ArmorSet set) async {
    final prefs = await SharedPreferences.getInstance();
    _state = _state.copyWith(currentSet: set);
    await prefs.setInt(_currentSetKey, set.index);
    notifyListeners();
  }

  // Debug methods
  Future<void> debugReset() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_currentSetKey);
    await prefs.remove(_ironStageKey);
    await prefs.remove(_unlockedPiecesKey);
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
    if (_state.ironStage == IronStage.forged) return 'assets/tools/iron_forged.svg';
    if (_state.ironStage == IronStage.polished) return 'assets/tools/iron_polished.svg';
    
    // If complete or after polished, return the last unlocked piece
    if (_state.unlockedPieces.isNotEmpty) {
      final lastPiece = _state.unlockedPieces.last;
      return getPieceAsset(_state.currentSet, lastPiece);
    }

    return 'assets/tools/iron_raw.svg';
  }

  String getPieceAsset(ArmorSet set, ArmorPiece piece) {
    final setName = set.name;
    final pieceName = piece.name;
    return 'assets/armor/$setName/${setName}_$pieceName.svg';
  }

  String getRandomHammerSfx() {
    final rng = math.Random();
    final n = rng.nextInt(3) + 1;
    return 'sfx/ql_sfx_hammer_anvil_$n.wav';
  }
}
