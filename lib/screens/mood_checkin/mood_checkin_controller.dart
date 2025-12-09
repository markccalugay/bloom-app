import 'dart:math';
import 'mood_checkin_strings.dart';

class MoodCheckinController {
  final MoodCheckinMode mode;

  int value = 3; // default slider position (center)
  late final String header;

  // Callbacks the parent screen can pass in
  final void Function(int value)? onSubmit;
  final void Function()? onSkip;

  MoodCheckinController({
    required this.mode,
    this.onSubmit,
    this.onSkip,
  }) {
    // Pick a random header from the appropriate pool
    if (mode == MoodCheckinMode.pre) {
      header = kMCPreHeaders[Random().nextInt(kMCPreHeaders.length)];
    } else {
      header = kMCPostHeaders[Random().nextInt(kMCPostHeaders.length)];
    }
  }

  void setValue(int newValue) {
    value = newValue;
  }

  void submit() {
    if (onSubmit != null) onSubmit!(value);
  }

  void skip() {
    if (mode == MoodCheckinMode.pre && onSkip != null) {
      onSkip!();
    }
  }
}