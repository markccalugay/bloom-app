import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:quietline_app/core/auth/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class AuthService {
  static final AuthService instance = AuthService._internal();

  // TODO: Move these to a secure configuration or environment variable in production
  static const String _kClientId = '1054446804161-o24asbiksgbqas4th02cl0hhqul8epce.apps.googleusercontent.com';
  static const String _kServerClientId = '1054446804161-pj7ndvtml1ls7hadgplvd9ak697iu92g.apps.googleusercontent.com';
  static const String _kAppleUserIdKey = 'apple_user_id';

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

  Future<AuthenticatedUser?> signInWithGoogle() async {
    try {
      final account = await _googleSignIn.signIn();
      // _googleUser is updated by listener
      return account != null ? GoogleAuthenticatedUser(account) : null;
    } catch (e) {
      debugPrint('[AUTH] Google Sign-In Error: $e');
      return null;
    }
  }

  Future<AuthenticatedUser?> signInWithApple() async {
    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final user = AppleAuthenticatedUser(credential);
      _appleUser = user;
      
      // Persist Apple User ID
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_kAppleUserIdKey, user.id);
      } catch (e) {
        debugPrint('[AUTH] Failed to save Apple User ID: $e');
      }

      _updateState();
      // _triggerSync(); // Handled by UI now
      return user;
    } catch (e) {
      debugPrint('[AUTH] Apple Sign-In Error: $e');
      return null;
    }
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
  }

  Future<void> silentSignIn() async {
    // 1. Check Apple State
    try {
      final prefs = await SharedPreferences.getInstance();
      final appleUserId = prefs.getString(_kAppleUserIdKey);
      if (appleUserId != null) {
        final credentialState = await SignInWithApple.getCredentialState(appleUserId);
        if (credentialState == CredentialState.authorized) {
           debugPrint('[AUTH] Apple User ID found and authorized. Waiting for explicit sign-in for token.');
           // Note: We don't restore _appleUser object here because we don't have the credential/token.
           // User needs to tap button again.
        } else {
          await prefs.remove(_kAppleUserIdKey);
        }
      }
    } catch (e) {
      debugPrint('[AUTH] Apple Silent Check Error: $e');
    }

    // 2. Try Google Silent Sign In
    try {
      await _googleSignIn.signInSilently();
    } catch (e) {
      debugPrint('[AUTH] Google Silent Sign-In Error: $e');
    }
  }
}
