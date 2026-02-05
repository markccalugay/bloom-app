import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

/// Centralized helper for opening external URLs (website, legal, support).
class WebLaunchService {
  // TODO: replace these with your real URLs when the website is live.
  static final Uri _websiteUri = Uri.parse('https://quietline.app/');
  static final Uri _aboutUri = Uri.parse('https://quietline.app/what-is-quietline/');
  static final Uri _supportUri = Uri.parse('https://quietline.app/support/');
  static final Uri _privacyUri = Uri.parse(
    'https://quietline.app/privacy-policy/',
  );
  static final Uri _termsUri = Uri.parse(
    'https://quietline.app/terms-of-service/',
  );

  Future<void> openWebsite() => _open(_websiteUri);
  Future<void> openAbout() => _open(_aboutUri);
  Future<void> openSupport() => _open(_supportUri);
  Future<void> openPrivacy() => _open(_privacyUri);
  Future<void> openTerms() => _open(_termsUri);

  Future<void> _open(Uri uri) async {
    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched) {
        debugPrint('[WebLaunchService] Could not launch $uri');
      }
    } catch (e) {
      debugPrint('[WebLaunchService] Error launching $uri: $e');
    }
  }
}
