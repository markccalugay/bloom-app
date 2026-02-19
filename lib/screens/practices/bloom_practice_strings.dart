/// Strings for the Practice Library.
class BloomPracticeStrings {
  static const title = 'Practices';
  static const premiumUnlocked = 'Bloom+ Premium unlocked.';
  static const includedWithPremium = 'Included with Bloom+ Premium';
  static const changePracticeTitle = 'Change Practice?';
  static const whyThisWorks = 'Why This Works';
  static const active = 'Active';
  static const activate = 'Activate';
  static const confirm = 'Confirm';
  static const cancel = 'Cancel';
  static const startToSeeFavorites = 'Start a session to see favorites.';
  static const resetPacks = 'Guided Reset Packs';
  static const resetPacksSubtitle = 'Combine specific breathing with guided mental focus.';
  static const whyGuidedPacks = 'Why Guided Packs?';
  
  static String changePracticePrompt(String id) => 'Set ${id.replaceAll('_', ' ')} as your current active practice?';
  static String changeResetPackPrompt(String name) => 'Set $name as your current guided practice?';
  
  // Techniques & Benefits
  static const techCoreBloomTitle = 'Technique: 4–4–4 box breathing.';
  static const techCoreBloomSub = 'Inhale for 4 seconds, hold for 4, exhale for 4.\nBenefits: Calms the nervous system and resets attention.';
  
  static const techSteadyDisciplineTitle = 'Technique: Slow rhythmic breathing with steady pacing.';
  static const techSteadyDisciplineSub = 'Benefits: Builds consistency, self-control, and emotional regulation.';
  
  static const techMonkCalmTitle = 'Technique: Extended exhales inspired by monastic breathing.';
  static const techMonkCalmSub = 'Benefits: Encourages deep calm, patience, and mental stillness.';
  
  static const techNavyCalmTitle = 'Technique: 4–7–8 breathing.';
  static const techNavyCalmSub = 'Inhale for 4, hold for 7, exhale for 8.\nBenefits: Improves stress tolerance and composure under pressure.';
  
  static const techAthleteFocusTitle = 'Technique: Performance-focused breathing cycles.';
  static const techAthleteFocusSub = 'Benefits: Enhances focus, recovery, and physical readiness.';
  
  static const techColdResolveTitle = 'A fast, activating breathing practice inspired by Wim Hof.';
  static const techColdResolveSub = 'Designed to build resilience and sharpen mental control under stress.';
}
