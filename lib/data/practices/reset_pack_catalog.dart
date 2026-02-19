import '../../screens/bloom_breath/models/breath_phase_contracts.dart';
import '../affirmations/affirmations_packs.dart';
import 'reset_pack_model.dart';

class ResetPackIds {
  static const panicReset = 'panic_reset';
  static const preMeetingReset = 'pre_meeting_reset';
  static const eveningWindDown = 'evening_wind_down';
}

class ResetPackCatalog {
  static const panicReset = ResetPack(
    id: ResetPackIds.panicReset,
    name: 'Panic Reset',
    description: 'Ground yourself instantly when anxiety peaks. Uses the 4-7-8 rhythm.',
    contract: navyCalmContract, // 4-7-8
    affirmationPackId: 'panic', // To be created
  );

  static const preMeetingReset = ResetPack(
    id: ResetPackIds.preMeetingReset,
    name: 'Pre-Meeting Reset',
    description: 'Clear your mind and find steady confidence. Uses logic-based box breathing.',
    contract: coreBloomContract, // 4-4-4-4
    affirmationPackId: 'meeting', // To be created
  );

  static const eveningWindDown = ResetPack(
    id: ResetPackIds.eveningWindDown,
    name: 'Evening Wind-down',
    description: 'Signal to your body that the day is done. Focuses on the long exhale.',
    contract: monkCalmContract, // 4-6-2
    affirmationPackId: AffirmationPackIds.sleep,
  );

  static const all = [
    panicReset,
    preMeetingReset,
    eveningWindDown,
  ];
}
