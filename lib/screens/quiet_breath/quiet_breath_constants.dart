import 'dart:math' as math;

// -----------------------------------------------------------------------------
// Quiet Breath • Constants
// -----------------------------------------------------------------------------
// Goal: keep names stable for the codebase, but make every value EASY to tweak.
// Notes on style:
// • Units are called out (px, seconds, 0..1) so you know what to change.
// • Grouped by purpose: Visual Palette → Geometry → Ring → Timing → Layout.
// • No renames to avoid breaking imports; this is a readability pass only.
// -----------------------------------------------------------------------------

// ===== Visual Palette (Theme-Driven) =====
// Note: Screen background, wave sounds, and brand tones are now resolved
// dynamically via Theme.of(context) in the widgets.
// These constants are kept only where a fallback value is needed.

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
// Radius ring colors are now theme-aware in QuietBreathCircle.

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

// Phase colors are primarily managed by the breathing contract.

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