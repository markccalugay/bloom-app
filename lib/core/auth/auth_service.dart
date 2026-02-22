import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:bloom_app/core/auth/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  static final AuthService instance = AuthService._internal();

  // TODO: Move these to a secure configuration or environment variable in production
  static const String _kClientId = '';
  static const String _kServerClientId = '';
  static const String _kAppleUserIdKey = 'apple_user_id';
  static const String _kAppleEmailKey = 'apple_email';
  static const String _kAppleDisplayNameKey = 'apple_display_name';

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: _kClientId,
    serverClientId: _kServerClientId,
  );

  GoogleSignIn get googleSignIn => _googleSignIn;

  // Track users independently
  AuthenticatedUser? _googleUser;
  AuthenticatedUser? _appleUser;

  // Notifier for UI updates - triggers whenever ANY auth state changes
  final ValueNotifier<List<AuthenticatedUser>> _connectedUsersNotifier = ValueNotifier([]);
  ValueNotifier<List<AuthenticatedUser>> get connectedUsersNotifier => _connectedUsersNotifier;

  // Computed properties
  AuthenticatedUser? get googleUser => _googleUser;
  AuthenticatedUser? get appleUser => _appleUser;
  
  // Returns primary user for display (Apple preferred if available, else Google)
  AuthenticatedUser? get currentUser => _appleUser ?? _googleUser;
  
  // Backwards compatibility for ValueNotifier<AuthenticatedUser?> if needed elsewhere, 
  // but we should migrate to connectedUsersNotifier or specific streams.
  // For now, let's keep a separate notifier for 'currentUser' to minimize breakage, 
  // but strictly it's better to rely on specific getters.
  final ValueNotifier<AuthenticatedUser?> _currentUserNotifier = ValueNotifier<AuthenticatedUser?>(null);
  ValueNotifier<AuthenticatedUser?> get currentUserNotifier => _currentUserNotifier;

  AuthService._internal() {
    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount? account) async {
      if (account != null) {
        _googleUser = GoogleAuthenticatedUser(account);
      } else {
        _googleUser = null;
      }
      _updateState();
      
      _updateState();
      
      // Removed auto-sync to allow UI to handle conflict resolution (RemoteDataFoundScreen)
      // if (account != null) {
      //   _triggerSync();
      // }
    });
  }

  void _updateState() {
    final users = <AuthenticatedUser>[];
    if (_appleUser != null) users.add(_appleUser!);
    if (_googleUser != null) users.add(_googleUser!);
    
    _connectedUsersNotifier.value = users;
    _currentUserNotifier.value = currentUser;
  }

  // void _triggerSync() {
  //   debugPrint('[AUTH] User signed in. Triggering initial restore/backup.');
  //   try {
  //     BackupCoordinator.instance.runRestore();
  //     BackupCoordinator.instance.runBackup();
  //   } catch (e, stack) {
  //     debugPrint('[AUTH] Error during initial restore/backup: $e\n$stack');
  //   }
  // }

  // Supabase User
  User? get supabaseUser => Supabase.instance.client.auth.currentUser;
  Session? get supabaseSession => Supabase.instance.client.auth.currentSession;

  Future<AuthenticatedUser?> signInWithGoogle() async {
    // Disconnected from QuietLine. Return null until new project is configured.
    debugPrint('[AUTH] Google Sign-In is currently disabled.');
    return null;
  }

  Future<AuthenticatedUser?> signInWithApple() async {
    // Disconnected from QuietLine. Return null until new project is configured.
    debugPrint('[AUTH] Apple Sign-In is currently disabled.');
    return null;
  }

  Future<void> signOutGoogle() async {
    try {
      await _googleSignIn.signOut();
      // Listener handles state update
    } catch (e) {
      debugPrint('[AUTH] Google Sign-Out Error: $e');
    }
  }

  Future<void> signOutApple() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_kAppleUserIdKey);
      await prefs.remove(_kAppleEmailKey);
      await prefs.remove(_kAppleDisplayNameKey);
      _appleUser = null;
      _updateState();
    } catch (e) {
      debugPrint('[AUTH] Apple Sign-Out Error: $e');
    }
  }

  /// Signs out of ALL providers
  Future<void> signOut() async {
    await signOutGoogle();
    await signOutApple();
    await Supabase.instance.client.auth.signOut();
  }

  Future<void> silentSignIn() async {
    // Silently bypass until new project is configured.
    debugPrint('[AUTH] Silent Sign-In bypassed.');
    return;
  }
}
