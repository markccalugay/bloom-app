# Changelog

All notable changes to this project will be documented in this file.

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
