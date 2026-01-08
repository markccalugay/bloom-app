import 'affirmations_model.dart';

/// IDs so we don't hardcode strings everywhere.
class AffirmationPackIds {
  static const core = 'core';
}

/// Core pack definition
const corePack = AffirmationPack(
  id: AffirmationPackIds.core,
  name: 'Core Affirmations',
  description: 'Daily reminders to breathe, reset, and stay steady.',
  isSeasonal: false,
);

/// All packs (for future library screens).
const allPacks = <AffirmationPack>[corePack];

/// Core affirmations list (edit freely).
const coreAffirmations = <Affirmation>[
  Affirmation(
    id: 'core_001',
    packId: AffirmationPackIds.core,
    text: 'Welcome back to yourself.',
  ),
  Affirmation(
    id: 'core_002',
    packId: AffirmationPackIds.core,
    text: 'This is a good place to begin.',
  ),
  Affirmation(
    id: 'core_003',
    packId: AffirmationPackIds.core,
    text: 'Nothing is required of you right now.',
  ),
  Affirmation(
    id: 'core_004',
    packId: AffirmationPackIds.core,
    text: 'Slow is safe. Slow is steady.',
  ),
  Affirmation(
    id: 'core_005',
    packId: AffirmationPackIds.core,
    text: 'You’re allowed to start exactly where you are.',
  ),
  Affirmation(
    id: 'core_006',
    packId: AffirmationPackIds.core,
    text: 'You showed up. That’s where calm begins.',
  ),
  Affirmation(
    id: 'core_007',
    packId: AffirmationPackIds.core,
    text: 'Things feel lighter when you breathe slower.',
  ),
  Affirmation(
    id: 'core_008',
    packId: AffirmationPackIds.core,
    text: 'You don’t need the whole plan right now. Just the next step.',
  ),
  Affirmation(
    id: 'core_009',
    packId: AffirmationPackIds.core,
    text: 'Your mind is allowed to rest, even if the world isn’t.',
  ),
  Affirmation(
    id: 'core_010',
    packId: AffirmationPackIds.core,
    text: 'You’ve made it through every hard moment so far.',
  ),
  Affirmation(
    id: 'core_011',
    packId: AffirmationPackIds.core,
    text: 'Your feelings don’t need to be solved — just heard.',
  ),
  Affirmation(
    id: 'core_012',
    packId: AffirmationPackIds.core,
    text: 'Stillness is strength, not absence.',
  ),
  Affirmation(
    id: 'core_013',
    packId: AffirmationPackIds.core,
    text: 'You’re learning to respond, not react.',
  ),
  Affirmation(
    id: 'core_014',
    packId: AffirmationPackIds.core,
    text: 'You deserve calm, even on days you struggle to find it.',
  ),
  Affirmation(
    id: 'core_015',
    packId: AffirmationPackIds.core,
    text: 'Hold steady. You’re becoming someone you can rely on.',
  ),
  Affirmation(
    id: 'core_016',
    packId: AffirmationPackIds.core,
    text: 'You don’t have to win today. Just don’t quit.',
  ),
  Affirmation(
    id: 'core_017',
    packId: AffirmationPackIds.core,
    text: 'Small resets prevent big breakdowns.',
  ),
  Affirmation(
    id: 'core_018',
    packId: AffirmationPackIds.core,
    text: 'Your thoughts are loud. You can be louder.',
  ),
  Affirmation(
    id: 'core_019',
    packId: AffirmationPackIds.core,
    text: 'Your effort matters more than your pace.',
  ),
  Affirmation(
    id: 'core_020',
    packId: AffirmationPackIds.core,
    text: 'You’re allowed to pause without feeling weak.',
  ),
  Affirmation(
    id: 'core_021',
    packId: AffirmationPackIds.core,
    text: 'Your worth isn’t tied to how “productive” you feel.',
  ),
  Affirmation(
    id: 'core_022',
    packId: AffirmationPackIds.core,
    text: 'Even storms break eventually. You won’t feel this forever.',
  ),
  Affirmation(
    id: 'core_023',
    packId: AffirmationPackIds.core,
    text: 'You don’t need permission to breathe.',
  ),
  Affirmation(
    id: 'core_024',
    packId: AffirmationPackIds.core,
    text: 'You can rebuild from anywhere, including here.',
  ),
  Affirmation(
    id: 'core_025',
    packId: AffirmationPackIds.core,
    text: 'Today’s tension isn’t tomorrow’s truth.',
  ),
  Affirmation(
    id: 'core_026',
    packId: AffirmationPackIds.core,
    text: 'You’re getting better at coming back to yourself.',
  ),
  Affirmation(
    id: 'core_027',
    packId: AffirmationPackIds.core,
    text: 'You don’t have to push through everything alone.',
  ),
  Affirmation(
    id: 'core_028',
    packId: AffirmationPackIds.core,
    text: 'You can start again as many times as you need.',
  ),
  Affirmation(
    id: 'core_029',
    packId: AffirmationPackIds.core,
    text: 'Your breath is your anchor — use it.',
  ),
  Affirmation(
    id: 'core_030',
    packId: AffirmationPackIds.core,
    text: 'You’re growing in ways you can’t see yet.',
  ),
  Affirmation(
    id: 'core_031',
    packId: AffirmationPackIds.core,
    text: 'Even a shaky step is still forward.',
  ),
  Affirmation(
    id: 'core_032',
    packId: AffirmationPackIds.core,
    text: 'Your silence is allowed to be healing, not empty.',
  ),
  Affirmation(
    id: 'core_033',
    packId: AffirmationPackIds.core,
    text: 'Being overwhelmed doesn’t mean you’re failing.',
  ),
  Affirmation(
    id: 'core_034',
    packId: AffirmationPackIds.core,
    text: 'Calm doesn’t arrive. You create it.',
  ),
  Affirmation(
    id: 'core_035',
    packId: AffirmationPackIds.core,
    text: 'Not everything requires your urgency.',
  ),
  Affirmation(
    id: 'core_036',
    packId: AffirmationPackIds.core,
    text: 'Your inner critic is loud, not accurate.',
  ),
  Affirmation(
    id: 'core_037',
    packId: AffirmationPackIds.core,
    text: 'You’re learning how to handle yourself with care.',
  ),
  Affirmation(
    id: 'core_038',
    packId: AffirmationPackIds.core,
    text: 'You deserve quiet moments too.',
  ),
  Affirmation(
    id: 'core_039',
    packId: AffirmationPackIds.core,
    text: 'You’re not behind. You’re rebuilding.',
  ),
  Affirmation(
    id: 'core_040',
    packId: AffirmationPackIds.core,
    text: 'You’re allowed to rest without explaining why.',
  ),
  Affirmation(
    id: 'core_041',
    packId: AffirmationPackIds.core,
    text: 'You’re stronger when you slow down.',
  ),
  Affirmation(
    id: 'core_042',
    packId: AffirmationPackIds.core,
    text: 'The version of you that can handle this is already forming.',
  ),
  Affirmation(
    id: 'core_043',
    packId: AffirmationPackIds.core,
    text: 'You don’t need to be perfect to be progressing.',
  ),
  Affirmation(
    id: 'core_044',
    packId: AffirmationPackIds.core,
    text: 'Your peace matters too. Treat it like it does.',
  ),
  Affirmation(
    id: 'core_045',
    packId: AffirmationPackIds.core,
    text: 'You’ve gotten through harder days than this.',
  ),
  Affirmation(
    id: 'core_046',
    packId: AffirmationPackIds.core,
    text: 'Your heart is trying. Give it credit.',
  ),
  Affirmation(
    id: 'core_047',
    packId: AffirmationPackIds.core,
    text: 'You don’t have to match anyone’s pace.',
  ),
  Affirmation(
    id: 'core_048',
    packId: AffirmationPackIds.core,
    text: 'Even slowing down is a form of moving forward.',
  ),
  Affirmation(
    id: 'core_049',
    packId: AffirmationPackIds.core,
    text: 'You’re building steadiness one breath at a time.',
  ),
  Affirmation(
    id: 'core_050',
    packId: AffirmationPackIds.core,
    text: 'Your nervous system isn’t your enemy.',
  ),
  Affirmation(
    id: 'core_051',
    packId: AffirmationPackIds.core,
    text: 'You are allowed to unclench.',
  ),
  Affirmation(
    id: 'core_052',
    packId: AffirmationPackIds.core,
    text: 'Don’t rush the healing. Let it settle.',
  ),
  Affirmation(
    id: 'core_053',
    packId: AffirmationPackIds.core,
    text: 'Your clarity grows in quiet spaces.',
  ),
  Affirmation(
    id: 'core_054',
    packId: AffirmationPackIds.core,
    text: 'You’re doing better than you feel.',
  ),
  Affirmation(
    id: 'core_055',
    packId: AffirmationPackIds.core,
    text: 'Nothing is wrong with needing a reset.',
  ),
  Affirmation(
    id: 'core_056',
    packId: AffirmationPackIds.core,
    text: 'Choose calm more often. It rewires things.',
  ),
  Affirmation(
    id: 'core_057',
    packId: AffirmationPackIds.core,
    text: 'You are becoming harder to shake.',
  ),
  Affirmation(
    id: 'core_058',
    packId: AffirmationPackIds.core,
    text: 'You’re allowed to outgrow chaos.',
  ),
  Affirmation(
    id: 'core_059',
    packId: AffirmationPackIds.core,
    text: 'Rest is not a reward. It’s maintenance.',
  ),
  Affirmation(
    id: 'core_060',
    packId: AffirmationPackIds.core,
    text: 'You don’t need the answers to move forward.',
  ),
  Affirmation(
    id: 'core_061',
    packId: AffirmationPackIds.core,
    text: 'Your body hears everything your mind says. Speak gently.',
  ),
  Affirmation(
    id: 'core_062',
    packId: AffirmationPackIds.core,
    text: 'You’re here. You’re breathing. You’re okay.',
  ),
  Affirmation(
    id: 'core_063',
    packId: AffirmationPackIds.core,
    text: 'You’re allowed to slow things down.',
  ),
  Affirmation(
    id: 'core_064',
    packId: AffirmationPackIds.core,
    text: 'You can take up space quietly.',
  ),
  Affirmation(
    id: 'core_065',
    packId: AffirmationPackIds.core,
    text: 'One steady breath resets the next ten.',
  ),
  Affirmation(
    id: 'core_066',
    packId: AffirmationPackIds.core,
    text: 'Your calm is contagious.',
  ),
  Affirmation(
    id: 'core_067',
    packId: AffirmationPackIds.core,
    text: 'You’re learning to carry things differently.',
  ),
  Affirmation(
    id: 'core_068',
    packId: AffirmationPackIds.core,
    text: 'You’re allowed to feel tired. You’re still capable.',
  ),
  Affirmation(
    id: 'core_069',
    packId: AffirmationPackIds.core,
    text: 'You can start fresh any time of day.',
  ),
  Affirmation(
    id: 'core_070',
    packId: AffirmationPackIds.core,
    text: 'You’re finding your way back to center.',
  ),
  Affirmation(
    id: 'core_071',
    packId: AffirmationPackIds.core,
    text: 'Sit with yourself. You’re worth the company.',
  ),
  Affirmation(
    id: 'core_072',
    packId: AffirmationPackIds.core,
    text: 'You’re shedding old versions of yourself. Let them go.',
  ),
  Affirmation(
    id: 'core_073',
    packId: AffirmationPackIds.core,
    text: 'You don’t need noise to feel present.',
  ),
  Affirmation(
    id: 'core_074',
    packId: AffirmationPackIds.core,
    text: 'Your peace is beginning to stretch.',
  ),
  Affirmation(
    id: 'core_075',
    packId: AffirmationPackIds.core,
    text: 'You’re teaching your mind how to calm down.',
  ),
  Affirmation(
    id: 'core_076',
    packId: AffirmationPackIds.core,
    text: 'One deep breath is still progress.',
  ),
  Affirmation(
    id: 'core_077',
    packId: AffirmationPackIds.core,
    text: 'You’re not stuck. You’re pausing.',
  ),
  Affirmation(
    id: 'core_078',
    packId: AffirmationPackIds.core,
    text: 'Your capacity is growing quietly.',
  ),
  Affirmation(
    id: 'core_079',
    packId: AffirmationPackIds.core,
    text: 'You’re beginning to feel lighter.',
  ),
  Affirmation(
    id: 'core_080',
    packId: AffirmationPackIds.core,
    text: 'Even a calm minute helps.',
  ),
  Affirmation(
    id: 'core_081',
    packId: AffirmationPackIds.core,
    text: 'You can soften without breaking.',
  ),
  Affirmation(
    id: 'core_082',
    packId: AffirmationPackIds.core,
    text: 'Your mind deserves gentleness too.',
  ),
  Affirmation(
    id: 'core_083',
    packId: AffirmationPackIds.core,
    text: 'You are learning to trust yourself again.',
  ),
  Affirmation(
    id: 'core_084',
    packId: AffirmationPackIds.core,
    text: 'Your breath brings you home.',
  ),
  Affirmation(
    id: 'core_085',
    packId: AffirmationPackIds.core,
    text: 'Choose the calmer path — even in small ways.',
  ),
  Affirmation(
    id: 'core_086',
    packId: AffirmationPackIds.core,
    text: 'You’re discovering what steady feels like.',
  ),
  Affirmation(
    id: 'core_087',
    packId: AffirmationPackIds.core,
    text: 'You can release what’s not yours to carry.',
  ),
  Affirmation(
    id: 'core_088',
    packId: AffirmationPackIds.core,
    text: 'Your internal pace matters more than external pressure.',
  ),
  Affirmation(
    id: 'core_089',
    packId: AffirmationPackIds.core,
    text: 'You can be both soft and strong.',
  ),
  Affirmation(
    id: 'core_090',
    packId: AffirmationPackIds.core,
    text: 'Your sense of calm is becoming more familiar.',
  ),
  Affirmation(
    id: 'core_091',
    packId: AffirmationPackIds.core,
    text: 'You can let this moment be enough.',
  ),
  Affirmation(
    id: 'core_092',
    packId: AffirmationPackIds.core,
    text: 'Each pause is a small return to yourself.',
  ),
  Affirmation(
    id: 'core_093',
    packId: AffirmationPackIds.core,
    text: 'Your breathing is the safest place to start.',
  ),
  Affirmation(
    id: 'core_094',
    packId: AffirmationPackIds.core,
    text: 'You’re building a calmer life in real time.',
  ),
  Affirmation(
    id: 'core_095',
    packId: AffirmationPackIds.core,
    text: 'You deserve to feel steady inside your own mind.',
  ),
  Affirmation(
    id: 'core_096',
    packId: AffirmationPackIds.core,
    text: 'You choose peace every time you inhale slowly.',
  ),
  Affirmation(
    id: 'core_097',
    packId: AffirmationPackIds.core,
    text: 'You are not falling apart. You are unwinding.',
  ),
  Affirmation(
    id: 'core_098',
    packId: AffirmationPackIds.core,
    text: 'You can breathe through this too.',
  ),
  Affirmation(
    id: 'core_099',
    packId: AffirmationPackIds.core,
    text: 'You’re learning to meet yourself where you are.',
  ),
  Affirmation(
    id: 'core_100',
    packId: AffirmationPackIds.core,
    text: 'Steady is a direction, not a destination.',
  ),
];

/// Map pack → affirmations
final Map<String, List<Affirmation>> affirmationsByPack = {
  AffirmationPackIds.core: coreAffirmations,
};
