import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  static final AuthService instance = AuthService._internal();

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: '1054446804161-o24asbiksgbqas4th02cl0hhqul8epce.apps.googleusercontent.com',
    serverClientId: '1054446804161-pj7ndvtml1ls7hadgplvd9ak697iu92g.apps.googleusercontent.com',
  );

  GoogleSignIn get googleSignIn => _googleSignIn;

  final ValueNotifier<GoogleSignInAccount?> _currentUser = ValueNotifier<GoogleSignInAccount?>(null);
  ValueNotifier<GoogleSignInAccount?> get currentUserNotifier => _currentUser;
  GoogleSignInAccount? get currentUser => _currentUser.value;

  AuthService._internal() {
    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount? account) {
      _currentUser.value = account;
    });
  }

  Future<GoogleSignInAccount?> signIn() async {
    try {
      final account = await _googleSignIn.signIn();
      // _currentUser.value is updated by the onCurrentUserChanged listener
      return account;
    } catch (e) {
      // ignore: avoid_print
      print('Google Sign-In Error: $e');
      return null;
    }
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      // _currentUser.value is updated by the onCurrentUserChanged listener
    } catch (e) {
      // ignore: avoid_print
      print('Google Sign-Out Error: $e');
    }
  }

  Future<void> silentSignIn() async {
    try {
      await _googleSignIn.signInSilently();
      // _currentUser.value is updated by the onCurrentUserChanged listener
    } catch (e) {
      // ignore: avoid_print
      print('Google Silent Sign-In Error: $e');
    }
  }
}
