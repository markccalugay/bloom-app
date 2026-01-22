import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:quietline_app/theme/ql_theme.dart';

// -----------------------------------------------------------------------------
// Quiet Breath • Constants
// -----------------------------------------------------------------------------
// Goal: keep names stable for the codebase, but make every value EASY to tweak.
// Notes on style:
// • Units are called out (px, seconds, 0..1) so you know what to change.
// • Grouped by purpose: Visual Palette → Geometry → Ring → Timing → Layout.
// • No renames to avoid breaking imports; this is a readability pass only.
// -----------------------------------------------------------------------------

// ===== Visual Palette =====
// Screen background + brand tones used across the Quiet Breath screen.
const kQBBackgroundColor = QLColors.background;    // Unified app background
const kQBWaveColorMain   = QLColors.primaryTeal;   // Brand primary teal
const kQBWaveColorDim    = Color(0xFF3F8E89); // Same hue; lower alpha in painter
const kQBTextColor       = Colors.white;      // Primary text on dark bg

// Ellipse background fill (behind waves). Steel gray for neutral contrast.
const kQBEllipseBackgroundColor = Color(0xFF5E6874);

// ===== Ellipse & Water Geometry =====
// Size and behavior of the main breathing ellipse and water fill.
const double kQBCircleSize         = 300.0; // px diameter of ellipse
const double kQBWaterMin           = 0.10;  // 0..1: min fill height (bottom)
const double kQBWaterMax           = 1.10;  // 0..1: max fill height (top overshoot)

// ===== Wave Look & Motion =====
// Taller amplitude = bigger crests/troughs; frequency/cycles = spacing of waves.
const double kQBWaveAmplitude      = 20.0;           // px height of wave peaks
const double kQBWaveBackYOffset    = -30.0;          // px vertical offset of BACK wave (stacking)
const double kQBWaveFrequencyBase  = 2 * math.pi;    // radians base (leave as-is)
const double kQBWaveCyclesAcross   = 2.6;            // ~how many peaks across ellipse width
const double kQBWavePhaseShift     = math.pi;        // radians: 180° -> fills the gaps visually

// Wave layering/opacity — adjust only if you want visual dominance changes.
const double kQBFrontWaveAlpha     = 1.0;   // 0..1 opacity: front wave fully opaque
const double kQBBackWaveAlpha      = 0.60;  // 0..1 opacity: back wave slightly darker/denser
const bool   kQBBackWaveOnTop      = false; // draw order: false = back wave under front

// ===== Circle Border (optional, currently hidden) =====
const kQBCircleBackgroundOpacity   = 0.15;  // 0..1 extra tint inside ellipse
const kQBCircleBorderOpacity       = 0.00;  // 0..1 stroke opacity (0 = off)
const kQBCircleBorderWidth         = 2.0;   // px stroke width if enabled

// ===== Radial Progress Ring (outside ellipse) =====
// The ring that shows per-phase (4s) progress. Adjust spacing/weight here.
const double kQBRingOuterPadding   = 5.0;           // px gap between ellipse edge and ring
const double kQBRingThickness      = 20.0;          // px stroke thickness of ring
const Color  kQBRingTrackColor     = Color(0xFF3A434B); // dark neutral track for contrast against HOLD

// ===== Timing =====
// Wave motion + intro animation + overall session defaults.
const Duration kQBWaveLoopDuration    = Duration(milliseconds: 2500); // wave horizontal speed
const Duration kQBBreathCycleDuration = Duration(seconds: 16);        // legacy 4/4/4/4 total (keep)
const int      kQBSessionSeconds      = 90;                           // default total session length
const Duration kQBIntroDropDuration   = Duration(milliseconds: 300);  // intro: fill drops top→bottom

// ===== Box Breathing Durations (4/4/4/4) =====
// Keep these if you want to vary phase lengths later (e.g., 4/7/8 style).
const int kQBBoxInhaleSec = 4; // seconds
const int kQBBoxHoldSec   = 4; // seconds (first hold)
const int kQBBoxExhaleSec = 4; // seconds
const int kQBBoxHold2Sec  = 4; // seconds (second hold)
const int kQBBoxCycleSec  = kQBBoxInhaleSec + kQBBoxHoldSec + kQBBoxExhaleSec + kQBBoxHold2Sec; // 16s

// ===== Phase Colors (brand-aware; easy to A/B test) =====
// You can tweak these to emphasize state transitions. Start subtle; refine later.
const Color kQBColorInhale = kQBWaveColorMain;      // Calm teal (inhale)
const Color kQBColorHold   = Color(0xFF5E6874);     // Steel gray (hold)
const Color kQBColorExhale = Color(0xFF2D6F6A);     // Deep sea teal (exhale)
// If you want a distinct second-hold color, add it in controller mapping; otherwise reuse hold.

// ===== UI Sizing =====
const double kQBButtonWidth  = 220; // px
const double kQBButtonHeight = 56;  // px

// Vertical layout offsets for header/instruction copy.
const double kQBHeaderTopGap           = 56; // px from SafeArea top to header text
const double kQBHeaderToInstructionGap = 12; // px from header to instruction

// ===== Session (cycle-based progression) =====
// Baseline cycles per session and a simple streak gate to unlock a longer set.
const int kQBCyclesBaseline   = 3; // cycles when starting out
const int kQBCyclesUpgraded   = 4; // cycles after streak unlock
const int kQBStreakUpgradeDays = 3; // days needed to unlock upgraded cycles