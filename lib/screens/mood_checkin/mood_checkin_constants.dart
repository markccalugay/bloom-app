import 'package:flutter/material.dart';
import 'package:quietline_app/theme/ql_theme.dart';

// -------------------------------------------------------------
// Mood Check-In • Constants
// -------------------------------------------------------------
// Mirrors quiet_breath_constants.dart → readable, tweakable,
// and SAFE to import into all mood check-in files.
// -------------------------------------------------------------

// ===== Colors =====
const kMCBackgroundColor = QLColors.background;
const kMCPrimaryTeal = QLColors.primaryTeal;
const kMCTrackColor = Color(0xFFE5E7EA);
const kMCLowLabelColor = Color(0xFFBFC5C9); // light gray text
const kMCTextColor = Colors.white;

// ===== Slider Settings =====
const double kMCSliderThumbSize = 28.0;
const double kMCSliderTrackHeight = 4.0;
const double kMCSliderTickSize = 10.0;
const double kMCSliderLabelHorizontalInset = 14.0;

// ===== Layout =====
const double kMCHeaderTopGap = 140; // px from safe area to header
const double kMCHeaderToQuestionGap = 80;
const double kMCQuestionToSliderGap = 40;
const double kMCSliderToLabelsGap = 12;

const double kMCButtonHeight = 56.0;
const double kMCButtonWidth = 220.0;

const double kMCSkipTopGap = 16.0; // gap below button

// Vertical spacing between the header and the slider section.
// Tweak this value to move the slider lower on the screen.
const double kMCMoodSliderTopSpacing = 64.0;
