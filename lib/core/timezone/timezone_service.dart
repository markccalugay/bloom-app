import 'package:flutter/foundation.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';

class TimezoneService {
  static Future<void> initialize() async {
    // 1. Initialize the timezone database with all world timezones
    tz.initializeTimeZones();

    try {
      // 2. Get the device's local timezone string (e.g., "America/New_York")
      final String currentTimezone = (await FlutterTimezone.getLocalTimezone()).identifier;
      
      // 3. Set the local location so tz.local works correctly
      tz.setLocalLocation(tz.getLocation(currentTimezone));
      
      debugPrint('[TimezoneService] Initialized with: $currentTimezone');
    } catch (e) {
      debugPrint('[TimezoneService] Error setting local location: $e');
      // Fallback to UTC if something goes wrong to avoid crashes
    }
  }
}
