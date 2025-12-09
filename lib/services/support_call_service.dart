import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

class SupportCallService {
  static Future<void> call988() async {
    final uri = Uri(scheme: 'tel', path: '988');

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      debugPrint('Could not open dialer.');
    }
  }
}