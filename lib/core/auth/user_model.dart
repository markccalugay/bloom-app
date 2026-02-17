import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

/// Abstract class representing an authenticated user from any provider.
abstract class AuthenticatedUser {
  /// Unique identifier from the provider
  String get id;

  /// Email address, if available
  String? get email;

  /// Display name or full name, if available
  String? get displayName;

  /// Retrieves the ID token required for backend authentication
  Future<String?> getIdToken();

  /// Returns the underlying provider user object if needed
  /// (e.g., for specific API calls not covered by this interface)
  Object? get providerUser;
}

class GoogleAuthenticatedUser extends AuthenticatedUser {
  final GoogleSignInAccount _user;

  GoogleAuthenticatedUser(this._user);

  @override
  String get id => _user.id;

  @override
  String? get email => _user.email;

  @override
  String? get displayName => _user.displayName;

  @override
  Future<String?> getIdToken() async {
    final auth = await _user.authentication;
    return auth.idToken;
  }

  @override
  Object? get providerUser => _user;
}

class AppleAuthenticatedUser extends AuthenticatedUser {
  final String _id;
  final String? _email;
  final String? _displayName;
  final AuthorizationCredentialAppleID? _credential;

  AppleAuthenticatedUser(AuthorizationCredentialAppleID credential)
      : _id = credential.userIdentifier!,
        _email = credential.email,
        _displayName = (credential.givenName != null || credential.familyName != null)
            ? [credential.givenName, credential.familyName].where((s) => s != null).join(' ')
            : null,
        _credential = credential;

  /// Internal constructor for cached users
  AppleAuthenticatedUser.cached({
    required String id,
    String? email,
    String? displayName,
  })  : _id = id,
        _email = email,
        _displayName = displayName,
        _credential = null;

  @override
  String get id => _id;

  @override
  String? get email => _email;

  @override
  String? get displayName => _displayName;

  @override
  Future<String?> getIdToken() async {
    return _credential?.identityToken;
  }

  @override
  Object? get providerUser => _credential;
}
