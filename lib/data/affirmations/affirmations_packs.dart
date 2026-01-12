import 'affirmations_model.dart';

/// IDs so we don't hardcode strings everywhere.
class AffirmationPackIds {
  static const core = 'core';
  static const focus = 'focus';
  static const sleep = 'sleep';
  static const strength = 'strength';
}

/// Core pack definition
const corePack = AffirmationPack(
  id: AffirmationPackIds.core,
  name: 'Core Affirmations',
  description: 'Daily reminders to breathe, reset, and stay steady.',
  isSeasonal: false,
);

/// Focus pack definition
const focusPack = AffirmationPack(
  id: AffirmationPackIds.focus,
  name: 'Focus & Work',
  description: 'Calm focus for work, effort, and attention.',
  isSeasonal: false,
);

/// Sleep pack definition
const sleepPack = AffirmationPack(
  id: AffirmationPackIds.sleep,
  name: 'Sleep & Night Reset',
  description: 'Wind down, release the day, and reset for rest.',
  isSeasonal: false,
);

/// Strength pack definition
const strengthPack = AffirmationPack(
  id: AffirmationPackIds.strength,
  name: 'Confidence & Strength',
  description: 'Quiet strength, steady confidence, no bravado.',
  isSeasonal: false,
);

/// All packs (for future library screens).
const allPacks = <AffirmationPack>[
  corePack,
  focusPack,
  sleepPack,
  strengthPack,
];

/// Core affirmations list (edit freely).
const coreAffirmations = <Affirmation>[
  Affirmation(id: 'core_001', packId: AffirmationPackIds.core, text: 'I come back to myself.'),
  Affirmation(id: 'core_002', packId: AffirmationPackIds.core, text: 'This is a good place for me to begin.'),
  Affirmation(id: 'core_003', packId: AffirmationPackIds.core, text: 'Nothing is required of me right now.'),
  Affirmation(id: 'core_004', packId: AffirmationPackIds.core, text: 'Slow is safe. Slow is steady for me.'),
  Affirmation(id: 'core_005', packId: AffirmationPackIds.core, text: 'I can start exactly where I am.'),
  Affirmation(id: 'core_006', packId: AffirmationPackIds.core, text: 'I showed up. That’s where my calm begins.'),
  Affirmation(id: 'core_007', packId: AffirmationPackIds.core, text: 'Things feel lighter when I breathe slower.'),
  Affirmation(id: 'core_008', packId: AffirmationPackIds.core, text: 'I don’t need the whole plan. Just my next step.'),
  Affirmation(id: 'core_009', packId: AffirmationPackIds.core, text: 'I allow my mind to rest, even if the world doesn’t.'),
  Affirmation(id: 'core_010', packId: AffirmationPackIds.core, text: 'I’ve made it through every hard moment so far.'),
  Affirmation(id: 'core_011', packId: AffirmationPackIds.core, text: 'I don’t need to solve my feelings — I can hear them.'),
  Affirmation(id: 'core_012', packId: AffirmationPackIds.core, text: 'Stillness is my strength, not my absence.'),
  Affirmation(id: 'core_013', packId: AffirmationPackIds.core, text: 'I am learning to respond, not react.'),
  Affirmation(id: 'core_014', packId: AffirmationPackIds.core, text: 'I deserve calm, even on days it feels far.'),
  Affirmation(id: 'core_015', packId: AffirmationPackIds.core, text: 'I hold steady. I’m becoming someone I can rely on.'),
  Affirmation(id: 'core_016', packId: AffirmationPackIds.core, text: 'I don’t have to win today. I just don’t quit.'),
  Affirmation(id: 'core_017', packId: AffirmationPackIds.core, text: 'My small resets prevent big breakdowns.'),
  Affirmation(id: 'core_018', packId: AffirmationPackIds.core, text: 'My thoughts can be loud. I can be steadier.'),
  Affirmation(id: 'core_019', packId: AffirmationPackIds.core, text: 'My effort matters more than my pace.'),
  Affirmation(id: 'core_020', packId: AffirmationPackIds.core, text: 'I can pause without being weak.'),
  Affirmation(id: 'core_021', packId: AffirmationPackIds.core, text: 'My worth isn’t tied to how productive I feel.'),
  Affirmation(id: 'core_022', packId: AffirmationPackIds.core, text: 'Even storms break. I won’t feel this forever.'),
  Affirmation(id: 'core_023', packId: AffirmationPackIds.core, text: 'I don’t need permission to breathe.'),
  Affirmation(id: 'core_024', packId: AffirmationPackIds.core, text: 'I can rebuild from anywhere, including here.'),
  Affirmation(id: 'core_025', packId: AffirmationPackIds.core, text: 'Today’s tension isn’t tomorrow’s truth for me.'),
  Affirmation(id: 'core_026', packId: AffirmationPackIds.core, text: 'I am getting better at coming back to myself.'),
  Affirmation(id: 'core_027', packId: AffirmationPackIds.core, text: 'I don’t have to push through everything alone.'),
  Affirmation(id: 'core_028', packId: AffirmationPackIds.core, text: 'I can start again as many times as I need.'),
  Affirmation(id: 'core_029', packId: AffirmationPackIds.core, text: 'My breath is my anchor, and I use it.'),
  Affirmation(id: 'core_030', packId: AffirmationPackIds.core, text: 'I am growing in ways I can’t see yet.'),
  Affirmation(id: 'core_031', packId: AffirmationPackIds.core, text: 'Even a shaky step is still forward for me.'),
  Affirmation(id: 'core_032', packId: AffirmationPackIds.core, text: 'My silence can heal me; it doesn’t have to be empty.'),
  Affirmation(id: 'core_033', packId: AffirmationPackIds.core, text: 'Being overwhelmed doesn’t mean I’m failing.'),
  Affirmation(id: 'core_034', packId: AffirmationPackIds.core, text: 'Calm doesn’t arrive for me. I create it.'),
  Affirmation(id: 'core_035', packId: AffirmationPackIds.core, text: 'Not everything requires my urgency.'),
  Affirmation(id: 'core_036', packId: AffirmationPackIds.core, text: 'My inner critic is loud, not accurate.'),
  Affirmation(id: 'core_037', packId: AffirmationPackIds.core, text: 'I handle myself with more care each day.'),
  Affirmation(id: 'core_038', packId: AffirmationPackIds.core, text: 'I deserve quiet moments too.'),
  Affirmation(id: 'core_039', packId: AffirmationPackIds.core, text: 'I’m not behind. I’m rebuilding.'),
  Affirmation(id: 'core_040', packId: AffirmationPackIds.core, text: 'I can rest without explaining why.'),
  Affirmation(id: 'core_041', packId: AffirmationPackIds.core, text: 'I’m stronger when I slow down.'),
  Affirmation(id: 'core_042', packId: AffirmationPackIds.core, text: 'The version of me who can handle this is forming.'),
  Affirmation(id: 'core_043', packId: AffirmationPackIds.core, text: 'I don’t need perfection to make progress.'),
  Affirmation(id: 'core_044', packId: AffirmationPackIds.core, text: 'My peace matters, and I treat it that way.'),
  Affirmation(id: 'core_045', packId: AffirmationPackIds.core, text: 'I’ve gotten through harder days than this.'),
  Affirmation(id: 'core_046', packId: AffirmationPackIds.core, text: 'My heart is trying, and I give it credit.'),
  Affirmation(id: 'core_047', packId: AffirmationPackIds.core, text: 'I don’t have to match anyone’s pace.'),
  Affirmation(id: 'core_048', packId: AffirmationPackIds.core, text: 'Even slowing down is moving forward for me.'),
  Affirmation(id: 'core_049', packId: AffirmationPackIds.core, text: 'I build steadiness one breath at a time.'),
  Affirmation(id: 'core_050', packId: AffirmationPackIds.core, text: 'My nervous system isn’t my enemy.'),
  Affirmation(id: 'core_051', packId: AffirmationPackIds.core, text: 'I am allowed to unclench.'),
  Affirmation(id: 'core_052', packId: AffirmationPackIds.core, text: 'I don’t rush my healing. I let it settle.'),
  Affirmation(id: 'core_053', packId: AffirmationPackIds.core, text: 'My clarity grows in quiet spaces.'),
  Affirmation(id: 'core_054', packId: AffirmationPackIds.core, text: 'I’m doing better than I feel.'),
  Affirmation(id: 'core_055', packId: AffirmationPackIds.core, text: 'There’s nothing wrong with me needing a reset.'),
  Affirmation(id: 'core_056', packId: AffirmationPackIds.core, text: 'I choose calm more often, and it rewires me.'),
  Affirmation(id: 'core_057', packId: AffirmationPackIds.core, text: 'I am becoming harder to shake.'),
  Affirmation(id: 'core_058', packId: AffirmationPackIds.core, text: 'I am allowed to outgrow chaos.'),
  Affirmation(id: 'core_059', packId: AffirmationPackIds.core, text: 'Rest is not a reward. It’s my maintenance.'),
  Affirmation(id: 'core_060', packId: AffirmationPackIds.core, text: 'I don’t need all the answers to move forward.'),
  Affirmation(id: 'core_061', packId: AffirmationPackIds.core, text: 'My body hears my mind. I speak gently to myself.'),
  Affirmation(id: 'core_062', packId: AffirmationPackIds.core, text: 'I’m here. I’m breathing. I’m okay.'),
  Affirmation(id: 'core_063', packId: AffirmationPackIds.core, text: 'I am allowed to slow things down.'),
  Affirmation(id: 'core_064', packId: AffirmationPackIds.core, text: 'I can take up space quietly.'),
  Affirmation(id: 'core_065', packId: AffirmationPackIds.core, text: 'One steady breath resets the next ten for me.'),
  Affirmation(id: 'core_066', packId: AffirmationPackIds.core, text: 'My calm can be contagious.'),
  Affirmation(id: 'core_067', packId: AffirmationPackIds.core, text: 'I’m learning to carry things differently.'),
  Affirmation(id: 'core_068', packId: AffirmationPackIds.core, text: 'I’m allowed to feel tired, and I’m still capable.'),
  Affirmation(id: 'core_069', packId: AffirmationPackIds.core, text: 'I can start fresh at any time of day.'),
  Affirmation(id: 'core_070', packId: AffirmationPackIds.core, text: 'I find my way back to center.'),
  Affirmation(id: 'core_071', packId: AffirmationPackIds.core, text: 'I sit with myself. I’m worth the company.'),
  Affirmation(id: 'core_072', packId: AffirmationPackIds.core, text: 'I let old versions of me go.'),
  Affirmation(id: 'core_073', packId: AffirmationPackIds.core, text: 'I don’t need noise to feel present.'),
  Affirmation(id: 'core_074', packId: AffirmationPackIds.core, text: 'My peace is beginning to stretch.'),
  Affirmation(id: 'core_075', packId: AffirmationPackIds.core, text: 'I’m teaching my mind how to calm down.'),
  Affirmation(id: 'core_076', packId: AffirmationPackIds.core, text: 'One deep breath is still progress for me.'),
  Affirmation(id: 'core_077', packId: AffirmationPackIds.core, text: 'I’m not stuck. I’m pausing.'),
  Affirmation(id: 'core_078', packId: AffirmationPackIds.core, text: 'My capacity is growing quietly.'),
  Affirmation(id: 'core_079', packId: AffirmationPackIds.core, text: 'I am beginning to feel lighter.'),
  Affirmation(id: 'core_080', packId: AffirmationPackIds.core, text: 'Even a calm minute helps me.'),
  Affirmation(id: 'core_081', packId: AffirmationPackIds.core, text: 'I can soften without breaking.'),
  Affirmation(id: 'core_082', packId: AffirmationPackIds.core, text: 'My mind deserves gentleness too.'),
  Affirmation(id: 'core_083', packId: AffirmationPackIds.core, text: 'I am learning to trust myself again.'),
  Affirmation(id: 'core_084', packId: AffirmationPackIds.core, text: 'My breath brings me home.'),
  Affirmation(id: 'core_085', packId: AffirmationPackIds.core, text: 'I choose the calmer path, even in small ways.'),
  Affirmation(id: 'core_086', packId: AffirmationPackIds.core, text: 'I am discovering what steady feels like.'),
  Affirmation(id: 'core_087', packId: AffirmationPackIds.core, text: 'I release what isn’t mine to carry.'),
  Affirmation(id: 'core_088', packId: AffirmationPackIds.core, text: 'My internal pace matters more than external pressure.'),
  Affirmation(id: 'core_089', packId: AffirmationPackIds.core, text: 'I can be both soft and strong.'),
  Affirmation(id: 'core_090', packId: AffirmationPackIds.core, text: 'Calm is becoming more familiar to me.'),
  Affirmation(id: 'core_091', packId: AffirmationPackIds.core, text: 'I let this moment be enough.'),
  Affirmation(id: 'core_092', packId: AffirmationPackIds.core, text: 'Each pause is my return to myself.'),
  Affirmation(id: 'core_093', packId: AffirmationPackIds.core, text: 'My breathing is the safest place to start.'),
  Affirmation(id: 'core_094', packId: AffirmationPackIds.core, text: 'I’m building a calmer life in real time.'),
  Affirmation(id: 'core_095', packId: AffirmationPackIds.core, text: 'I deserve to feel steady inside my own mind.'),
  Affirmation(id: 'core_096', packId: AffirmationPackIds.core, text: 'I choose peace when I inhale slowly.'),
  Affirmation(id: 'core_097', packId: AffirmationPackIds.core, text: 'I am not falling apart. I am unwinding.'),
  Affirmation(id: 'core_098', packId: AffirmationPackIds.core, text: 'I can breathe through this too.'),
  Affirmation(id: 'core_099', packId: AffirmationPackIds.core, text: 'I meet myself where I am.'),
  Affirmation(id: 'core_100', packId: AffirmationPackIds.core, text: 'Steady is my direction, not my destination.'),
];

/// Focus & Work affirmations (25)
const focusAffirmations = <Affirmation>[
  Affirmation(id: 'focus_001', packId: AffirmationPackIds.focus, text: 'One task is enough right now.'),
  Affirmation(id: 'focus_002', packId: AffirmationPackIds.focus, text: 'I can begin before I feel ready.'),
  Affirmation(id: 'focus_003', packId: AffirmationPackIds.focus, text: 'Focus grows when I remove urgency.'),
  Affirmation(id: 'focus_004', packId: AffirmationPackIds.focus, text: 'I don’t need momentum to start.'),
  Affirmation(id: 'focus_005', packId: AffirmationPackIds.focus, text: 'Small progress still counts.'),
  Affirmation(id: 'focus_006', packId: AffirmationPackIds.focus, text: 'I can work calmly and still be effective.'),
  Affirmation(id: 'focus_007', packId: AffirmationPackIds.focus, text: 'My attention is something I can choose.'),
  Affirmation(id: 'focus_008', packId: AffirmationPackIds.focus, text: 'I return to the task without judgment.'),
  Affirmation(id: 'focus_009', packId: AffirmationPackIds.focus, text: 'Clarity comes from doing, not thinking.'),
  Affirmation(id: 'focus_010', packId: AffirmationPackIds.focus, text: 'I can finish this one step at a time.'),
  Affirmation(id: 'focus_011', packId: AffirmationPackIds.focus, text: 'Discomfort doesn’t mean danger.'),
  Affirmation(id: 'focus_012', packId: AffirmationPackIds.focus, text: 'I don’t need perfect conditions to begin.'),
  Affirmation(id: 'focus_013', packId: AffirmationPackIds.focus, text: 'I can slow down and still move forward.'),
  Affirmation(id: 'focus_014', packId: AffirmationPackIds.focus, text: 'Focus is built, not forced.'),
  Affirmation(id: 'focus_015', packId: AffirmationPackIds.focus, text: 'I’m allowed to work without pressure.'),
  Affirmation(id: 'focus_016', packId: AffirmationPackIds.focus, text: 'One clear action is enough for now.'),
  Affirmation(id: 'focus_017', packId: AffirmationPackIds.focus, text: 'I release distraction and return gently.'),
  Affirmation(id: 'focus_018', packId: AffirmationPackIds.focus, text: 'Progress beats intensity.'),
  Affirmation(id: 'focus_019', packId: AffirmationPackIds.focus, text: 'I can stay with this moment.'),
  Affirmation(id: 'focus_020', packId: AffirmationPackIds.focus, text: 'Calm attention creates better results.'),
  Affirmation(id: 'focus_021', packId: AffirmationPackIds.focus, text: 'I don’t need to rush to be productive.'),
  Affirmation(id: 'focus_022', packId: AffirmationPackIds.focus, text: 'My work improves when my breath steadies.'),
  Affirmation(id: 'focus_023', packId: AffirmationPackIds.focus, text: 'I can reset my focus at any time.'),
  Affirmation(id: 'focus_024', packId: AffirmationPackIds.focus, text: 'This task does not define my worth.'),
  Affirmation(id: 'focus_025', packId: AffirmationPackIds.focus, text: 'I finish what I can, and that’s enough.'),
];

/// Sleep & Night Reset affirmations (25)
const sleepAffirmations = <Affirmation>[
  Affirmation(id: 'sleep_001', packId: AffirmationPackIds.sleep, text: 'The day is allowed to end here.'),
  Affirmation(id: 'sleep_002', packId: AffirmationPackIds.sleep, text: 'I don’t need to solve everything tonight.'),
  Affirmation(id: 'sleep_003', packId: AffirmationPackIds.sleep, text: 'Rest is productive for tomorrow.'),
  Affirmation(id: 'sleep_004', packId: AffirmationPackIds.sleep, text: 'My body knows how to power down.'),
  Affirmation(id: 'sleep_005', packId: AffirmationPackIds.sleep, text: 'I release today without replaying it.'),
  Affirmation(id: 'sleep_006', packId: AffirmationPackIds.sleep, text: 'Nothing else is required of me right now.'),
  Affirmation(id: 'sleep_007', packId: AffirmationPackIds.sleep, text: 'I can let my thoughts slow naturally.'),
  Affirmation(id: 'sleep_008', packId: AffirmationPackIds.sleep, text: 'Tomorrow can wait until morning.'),
  Affirmation(id: 'sleep_009', packId: AffirmationPackIds.sleep, text: 'I’m allowed to stop holding everything.'),
  Affirmation(id: 'sleep_010', packId: AffirmationPackIds.sleep, text: 'Sleep comes easier when I stop trying.'),
  Affirmation(id: 'sleep_011', packId: AffirmationPackIds.sleep, text: 'My breath signals safety to my body.'),
  Affirmation(id: 'sleep_012', packId: AffirmationPackIds.sleep, text: 'I can soften without losing control.'),
  Affirmation(id: 'sleep_013', packId: AffirmationPackIds.sleep, text: 'The night is a reset, not an escape.'),
  Affirmation(id: 'sleep_014', packId: AffirmationPackIds.sleep, text: 'I don’t need answers to rest.'),
  Affirmation(id: 'sleep_015', packId: AffirmationPackIds.sleep, text: 'My nervous system is allowed to calm.'),
  Affirmation(id: 'sleep_016', packId: AffirmationPackIds.sleep, text: 'I can let this moment be quiet.'),
  Affirmation(id: 'sleep_017', packId: AffirmationPackIds.sleep, text: 'I trust my body to rest when it’s ready.'),
  Affirmation(id: 'sleep_018', packId: AffirmationPackIds.sleep, text: 'The work of today is complete enough.'),
  Affirmation(id: 'sleep_019', packId: AffirmationPackIds.sleep, text: 'I can put the day down now.'),
  Affirmation(id: 'sleep_020', packId: AffirmationPackIds.sleep, text: 'Calm arrives when I stop resisting it.'),
  Affirmation(id: 'sleep_021', packId: AffirmationPackIds.sleep, text: 'I don’t need to carry tomorrow tonight.'),
  Affirmation(id: 'sleep_022', packId: AffirmationPackIds.sleep, text: 'Rest repairs more than effort ever could.'),
  Affirmation(id: 'sleep_023', packId: AffirmationPackIds.sleep, text: 'I am safe to slow all the way down.'),
  Affirmation(id: 'sleep_024', packId: AffirmationPackIds.sleep, text: 'My breath prepares me for sleep.'),
  Affirmation(id: 'sleep_025', packId: AffirmationPackIds.sleep, text: 'I allow the night to hold me.'),
];

/// Confidence & Strength affirmations (25)
const strengthAffirmations = <Affirmation>[
  Affirmation(id: 'strength_001', packId: AffirmationPackIds.strength, text: 'Calm is a form of strength.'),
  Affirmation(id: 'strength_002', packId: AffirmationPackIds.strength, text: 'I can handle what’s in front of me.'),
  Affirmation(id: 'strength_003', packId: AffirmationPackIds.strength, text: 'I don’t need to react to stay powerful.'),
  Affirmation(id: 'strength_004', packId: AffirmationPackIds.strength, text: 'Steady beats aggressive.'),
  Affirmation(id: 'strength_005', packId: AffirmationPackIds.strength, text: 'I trust myself to respond well.'),
  Affirmation(id: 'strength_006', packId: AffirmationPackIds.strength, text: 'I can stay grounded under pressure.'),
  Affirmation(id: 'strength_007', packId: AffirmationPackIds.strength, text: 'Strength doesn’t require tension.'),
  Affirmation(id: 'strength_008', packId: AffirmationPackIds.strength, text: 'I don’t need to prove anything right now.'),
  Affirmation(id: 'strength_009', packId: AffirmationPackIds.strength, text: 'I hold my ground without force.'),
  Affirmation(id: 'strength_010', packId: AffirmationPackIds.strength, text: 'I can pause and still be capable.'),
  Affirmation(id: 'strength_011', packId: AffirmationPackIds.strength, text: 'Confidence grows when I stay present.'),
  Affirmation(id: 'strength_012', packId: AffirmationPackIds.strength, text: 'I’m allowed to move at my own pace.'),
  Affirmation(id: 'strength_013', packId: AffirmationPackIds.strength, text: 'I don’t lose power by staying calm.'),
  Affirmation(id: 'strength_014', packId: AffirmationPackIds.strength, text: 'I choose clarity over impulse.'),
  Affirmation(id: 'strength_015', packId: AffirmationPackIds.strength, text: 'I can be firm without being harsh.'),
  Affirmation(id: 'strength_016', packId: AffirmationPackIds.strength, text: 'My composure is reliable.'),
  Affirmation(id: 'strength_017', packId: AffirmationPackIds.strength, text: 'I don’t need approval to trust myself.'),
  Affirmation(id: 'strength_018', packId: AffirmationPackIds.strength, text: 'I stay steady even when things are uncertain.'),
  Affirmation(id: 'strength_019', packId: AffirmationPackIds.strength, text: 'I can lead myself through this moment.'),
  Affirmation(id: 'strength_020', packId: AffirmationPackIds.strength, text: 'Strength looks quiet from the outside.'),
  Affirmation(id: 'strength_021', packId: AffirmationPackIds.strength, text: 'I am capable without rushing.'),
  Affirmation(id: 'strength_022', packId: AffirmationPackIds.strength, text: 'I meet challenges without tightening.'),
  Affirmation(id: 'strength_023', packId: AffirmationPackIds.strength, text: 'I don’t need chaos to feel alive.'),
  Affirmation(id: 'strength_024', packId: AffirmationPackIds.strength, text: 'I carry myself with intention.'),
  Affirmation(id: 'strength_025', packId: AffirmationPackIds.strength, text: 'I am harder to shake than I used to be.'),
];

/// Map pack → affirmations
final Map<String, List<Affirmation>> affirmationsByPack = {
  AffirmationPackIds.core: coreAffirmations,
  AffirmationPackIds.focus: focusAffirmations,
  AffirmationPackIds.sleep: sleepAffirmations,
  AffirmationPackIds.strength: strengthAffirmations,
};
