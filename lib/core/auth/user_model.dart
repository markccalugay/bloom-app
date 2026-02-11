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
  final AuthorizationCredentialAppleID _credential;

  AppleAuthenticatedUser(this._credential);

  @override
  String get id => _credential.userIdentifier!;

  @override
  String? get email => _credential.email;

  @override
  String? get displayName {
    final given = _credential.givenName;
    final family = _credential.familyName;
    if (given != null || family != null) {
      return [given, family].where((s) => s != null).join(' ');
    }
    return null;
  }

  @override
  Future<String?> getIdToken() async {
    return _credential.identityToken;
  }

  @override
  Object? get providerUser => _credential;
}
