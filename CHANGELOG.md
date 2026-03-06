# Changelog

All notable changes to this project will be documented in this file.

## [0.1.0+3] - 2026-03-06

### Added
- **GitHub-style Mindful Days Heatmap**: Implemented a contribution graph aesthetic in the 'My Account' window with a 7x14 grid, day-of-week labels (Mon, Wed, Fri), and monthly indicators.
- **Session Frequency Tracking**: Updated the streak data layer to store and retrieve multiple sessions per day, enabling dynamic opacity in the heatmap.
- **Visual Heatmap Legend**: Added a GitHub-inspired 'Less to More' legend in the bottom-right corner, fully integrated with the Bloom design system.

## [0.1.0+2] - 2026-03-05

### Fixed
- **iOS Build System**: Resolved `CompileAssetCatalogVariant` failure caused by non-asset files (`README.md`) in specialized `.imageset` directories.
- **Rive Runtime Linking**: Corrected CocoaPods `.xcconfig` include paths in `ios/Flutter/` to ensure static native libraries (`librive.a`, etc.) are properly linked.
- **Native Dependency Management**: Standardized iOS deployment target to 14.0 for compatibility with latest Rive renderer features.
- **Project Structure**: Restored missing `Profile.xcconfig` to ensure consistent build configurations across all target schemes.
- **Renaming & Reframing (2026-03-05 16:09)**: Renamed "Navy Calm" 4-7-8 breathing to "Serenity 4-7-8" across all catalogs and UI screens; rephrased "Why It Works" content to move from military-focused framing to wellness-oriented language for Bloom's audience.
- **StoreKit Update (2026-03-05 16:21)**: Replaced `bloom.premium.monthly.v2` with the standard `bloom.premium.monthly` product ID across the service and paywall UI.

## [0.1.0+2] - 2026-03-02


### Added
- **High-Contrast Design System Mapping**: Created `bloom_haven_design_system.md` as the single source of truth for all color tokens and their UX rationale.
- **Semantic Success Tokens**: Integrated `tertiary` (Mint) and `tertiaryContainer` (Gold) into the global `ColorScheme` for health and achievement states.

### Changed
- **Bloom Haven Palette Upgrade**: Completely replaced the color backbone with refined, higher-contrast tokens.
- **Typography Overhaul**: Switched all primary text and headlines to **Deep Cocoa (#2F2326)** for maximum legibility and brand premium feel.
- **Full Project Refactor**: Purged all hardcoded `Colors.black`, `Colors.white`, and unique hex values from UI components in favor of theme-mapped tokens.
- **Results Screen Refinement**: Implemented theme-aware "inactive" flame tints and balanced "active" gradients.
- **Paywall UI Refactor**: Updated the subscription action button and pricing cards to the new brand pink with high-contrast text.
- **Onboarding UX**: Simplified the breath screen by hiding the back button during the first session to prevent "dead-end" navigation.
- **Feminization of Avatars & Identity**: Replaced masculine-coded avatars and name generation with feminine, nature-inspired options.
- **Integrated Theme Audit**: Replaced all hardcoded "QuietLine" hex values.
- **Brand Alignment & Cleanup**: Complete purge of residual teal colors in `BloomBottomNav`, `BloomResultsStreakBadge`, and navigation elements.
- **Gradient Standardization**: Renamed legacy gradients (`steelFlame` -> `nightFlame`, `tealFlame` -> `bloomFlame`) for consistency.
- **Theme System Optimization**: Refactored results constants and UI components to be fully dynamic.

### Fixed
- **Onboarding UX**: Corrected the font size for the 'Tap to continue' text in the coaching overlay from H1 to paragraph size.

## [0.1.0+1] - 2026-03-02

### Added
- **New Bloom Haven Theme System**: Implemented in `bloom_theme.dart`.
- **Premium Typography**: Integration of **Playfair Display** (Headlines) and **Inter** (Body) fonts.
- **Dedicated ColorScheme**: Defined Light (Mist Blossom + Soft Rose primary) and Dark modes.
- **Legacy Support**: Maintained backward compatibility for 10+ legacy color tokens and gradients.

### Changed
- **Home Screen Refactor**: Replaced hardcoded colors and updated `_BloomHomeHalo` and "Mix Intro" dialog.
- **Breath Screen Update**: Refactored `BloomBreathScreen` and widgets to use the new `ColorScheme`.
- **Results Screen Polish**: Updated `BloomResultsOkScreen` and `BloomWhyItWorksScreen` for visual consistency.
- **Partner Screen UI**: Refactored `StrengthPartnerScreen` chat and pairing views with new design tokens.
- **Global Styles**: Standardized `CardTheme` with 16pt border radius and refined elevations.

## [0.1.0] - 2026-02-18

### Added
- **Bloom Brand Identity**: Initial migration from the "QuietLine" codebase.
- **Growth Focus**: Refocused the app's mission on guided growth and reflection for women.
- **Supabase Integration**: Initial setup for authentication and secure data persistence.

### Changed
- **Rebranding**: Renamed and rebranded all "Quiet" components and assets to "Bloom."
- **Demographic Shift**: Updated target demographic from men to women (Reflected in README).
- **Core Refactor**: Extracted account screen UI components into new widgets.

## [Initial Setup] - 2026-02-17

### Added
- **Base Architecture**: Initial merge of the QuietLine+ system.
- **Core Features**: Strength Partner, Mix Builder, and guided breathing engine.
- **Auth Flow**: Google and Apple Sign-In platform interfaces.
