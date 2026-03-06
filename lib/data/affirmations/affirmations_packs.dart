import 'affirmations_model.dart';

/// IDs so we don't hardcode strings everywhere.
class AffirmationPackIds {
  static const core = 'core';
  static const focus = 'focus';
  static const sleep = 'sleep';
  static const strength = 'strength';
  static const panic = 'panic';
  static const meeting = 'meeting';
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
  description: 'Bloom strength, steady confidence, no bravado.',
  isSeasonal: false,
);

/// Panic Reset pack definition
const panicPack = AffirmationPack(
  id: AffirmationPackIds.panic,
  name: 'Panic Reset',
  description: 'Immediate grounding for high-anxiety moments.',
  isSeasonal: false,
);

/// Pre-Meeting Reset pack definition
const meetingPack = AffirmationPack(
  id: AffirmationPackIds.meeting,
  name: 'Pre-Meeting Reset',
  description: 'Steady clarity and presence before you perform.',
  isSeasonal: false,
);

/// All packs (for future library screens).
const allPacks = <AffirmationPack>[
  corePack,
  focusPack,
  sleepPack,
  strengthPack,
  panicPack,
  meetingPack,
];

/// Panic Reset affirmations (10 - high-impact safety)
const panicAffirmations = <Affirmation>[
  Affirmation(id: 'panic_001', packId: AffirmationPackIds.panic, text: 'I am safe in this breath.', isPremium: true),
  Affirmation(id: 'panic_002', packId: AffirmationPackIds.panic, text: 'This feeling is a wave, and it will pass.', isPremium: true),
  Affirmation(id: 'panic_003', packId: AffirmationPackIds.panic, text: 'I have air. I have space. I have time.', isPremium: true),
  Affirmation(id: 'panic_004', packId: AffirmationPackIds.panic, text: 'My body is doing its job. I am okay.', isPremium: true),
  Affirmation(id: 'panic_005', packId: AffirmationPackIds.panic, text: 'I come back to the physical world.', isPremium: true),
  Affirmation(id: 'panic_006', packId: AffirmationPackIds.panic, text: 'I don’t have to fight this. I can let it settle.', isPremium: true),
  Affirmation(id: 'panic_007', packId: AffirmationPackIds.panic, text: 'My heartbeat will find its rhythm again.', isPremium: true),
  Affirmation(id: 'panic_008', packId: AffirmationPackIds.panic, text: 'I am here. This floor is solid.', isPremium: true),
  Affirmation(id: 'panic_009', packId: AffirmationPackIds.panic, text: 'I am slowing down, and slow is safe.', isPremium: true),
  Affirmation(id: 'panic_010', packId: AffirmationPackIds.panic, text: 'I am in control of my next exhale.', isPremium: true),
];

/// Pre-Meeting Reset affirmations (10 - presence and clarity)
const meetingAffirmations = <Affirmation>[
  Affirmation(id: 'meeting_001', packId: AffirmationPackIds.meeting, text: 'I have something valuable to contribute.', isPremium: true),
  Affirmation(id: 'meeting_002', packId: AffirmationPackIds.meeting, text: 'I am prepared, even if I feel uncertain.', isPremium: true),
  Affirmation(id: 'meeting_003', packId: AffirmationPackIds.meeting, text: 'I listen as much as I speak.', isPremium: true),
  Affirmation(id: 'meeting_004', packId: AffirmationPackIds.meeting, text: 'My presence is more important than my perfection.', isPremium: true),
  Affirmation(id: 'meeting_005', packId: AffirmationPackIds.meeting, text: 'I respond with clarity, not with rush.', isPremium: true),
  Affirmation(id: 'meeting_006', packId: AffirmationPackIds.meeting, text: 'I am allowed to take a beat before I speak.', isPremium: true),
  Affirmation(id: 'meeting_007', packId: AffirmationPackIds.meeting, text: 'I belong in this conversation.', isPremium: true),
  Affirmation(id: 'meeting_008', packId: AffirmationPackIds.meeting, text: 'I focus on the goal, not the ego.', isPremium: true),
  Affirmation(id: 'meeting_009', packId: AffirmationPackIds.meeting, text: 'I carry my calm into the room.', isPremium: true),
  Affirmation(id: 'meeting_010', packId: AffirmationPackIds.meeting, text: 'I am ready to hear and be heard.', isPremium: true),
];

/// Core affirmations list (edit freely).
const coreAffirmations = <Affirmation>[
  Affirmation(id: 'core_001', packId: AffirmationPackIds.core, text: 'I return to the gentle center of my being.'),
  Affirmation(id: 'core_002', packId: AffirmationPackIds.core, text: 'My journey is beautiful exactly as it begins.'),
  Affirmation(id: 'core_003', packId: AffirmationPackIds.core, text: 'I grant myself permission to simply be.'),
  Affirmation(id: 'core_004', packId: AffirmationPackIds.core, text: 'In my softness, I find my greatest strength.'),
  Affirmation(id: 'core_005', packId: AffirmationPackIds.core, text: 'I am enough, right here and right now.'),
  Affirmation(id: 'core_006', packId: AffirmationPackIds.core, text: 'Supporting myself is the first step toward calm.'),
  Affirmation(id: 'core_007', packId: AffirmationPackIds.core, text: 'My spirit lightens with every deep, conscious breath.'),
  Affirmation(id: 'core_008', packId: AffirmationPackIds.core, text: 'I trust my intuition to guide my next step.'),
  Affirmation(id: 'core_009', packId: AffirmationPackIds.core, text: 'I nurture my mind with the rest it deserves.'),
  Affirmation(id: 'core_010', packId: AffirmationPackIds.core, text: 'I honor the resilience that brought me here.'),
  Affirmation(id: 'core_011', packId: AffirmationPackIds.core, text: 'I listen to my emotions with love and without judgment.'),
  Affirmation(id: 'core_012', packId: AffirmationPackIds.core, text: 'My stillness is a powerful act of self-care.'),
  Affirmation(id: 'core_013', packId: AffirmationPackIds.core, text: 'I respond to life with grace and steady presence.'),
  Affirmation(id: 'core_014', packId: AffirmationPackIds.core, text: 'I am worthy of peace, especially when it feels far.'),
  Affirmation(id: 'core_015', packId: AffirmationPackIds.core, text: 'I am building a foundation of self-trust.'),
  Affirmation(id: 'core_016', packId: AffirmationPackIds.core, text: 'I celebrate my effort, regardless of the outcome.'),
  Affirmation(id: 'core_017', packId: AffirmationPackIds.core, text: 'Tiny moments of self-love sustain my whole day.'),
  Affirmation(id: 'core_018', packId: AffirmationPackIds.core, text: 'I am the calm presence behind my busy thoughts.'),
  Affirmation(id: 'core_019', packId: AffirmationPackIds.core, text: 'I honor my own rhythm over the world\'s pace.'),
  Affirmation(id: 'core_020', packId: AffirmationPackIds.core, text: 'Resting is an essential part of my power.'),
  Affirmation(id: 'core_021', packId: AffirmationPackIds.core, text: 'My value is inherent, not earned through doing.'),
  Affirmation(id: 'core_022', packId: AffirmationPackIds.core, text: 'I am the sky; my feelings are just passing clouds.'),
  Affirmation(id: 'core_023', packId: AffirmationPackIds.core, text: 'I claim my space and my right to breathe deep.'),
  Affirmation(id: 'core_024', packId: AffirmationPackIds.core, text: 'I have the power to create a life I love from here.'),
  Affirmation(id: 'core_025', packId: AffirmationPackIds.core, text: 'My inner peace is independent of external noise.'),
  Affirmation(id: 'core_026', packId: AffirmationPackIds.core, text: 'I am coming home to the truest version of myself.'),
  Affirmation(id: 'core_027', packId: AffirmationPackIds.core, text: 'I am supported by the collective strength of women.'),
  Affirmation(id: 'core_028', packId: AffirmationPackIds.core, text: 'Every moment is a fresh invitation to begin again.'),
  Affirmation(id: 'core_029', packId: AffirmationPackIds.core, text: 'My breath is a sacred anchor in my day.'),
  Affirmation(id: 'core_030', packId: AffirmationPackIds.core, text: 'I am blooming in my own time and in my own way.'),
  Affirmation(id: 'core_031', packId: AffirmationPackIds.core, text: 'I trust the path unfolding beneath my feet.'),
  Affirmation(id: 'core_032', packId: AffirmationPackIds.core, text: 'Quiet is a gift I give to my soul.'),
  Affirmation(id: 'core_033', packId: AffirmationPackIds.core, text: 'I am doing the best I can, and that is more than enough.'),
  Affirmation(id: 'core_034', packId: AffirmationPackIds.core, text: 'I cultivate a sanctuary of calm within me.'),
  Affirmation(id: 'core_035', packId: AffirmationPackIds.core, text: 'I release the need to hurry through my life.'),
  Affirmation(id: 'core_036', packId: AffirmationPackIds.core, text: 'I speak to myself with the kindness of a dear friend.'),
  Affirmation(id: 'core_037', packId: AffirmationPackIds.core, text: 'I handle my heart with the utmost tenderness.'),
  Affirmation(id: 'core_038', packId: AffirmationPackIds.core, text: 'I am deserving of my own time and attention.'),
  Affirmation(id: 'core_039', packId: AffirmationPackIds.core, text: 'I am beautifully evolving every single day.'),
  Affirmation(id: 'core_040', packId: AffirmationPackIds.core, text: 'My rest is productive and necessary.'),
  Affirmation(id: 'core_041', packId: AffirmationPackIds.core, text: 'Focusing on my well-being makes me stronger.'),
  Affirmation(id: 'core_042', packId: AffirmationPackIds.core, text: 'The most capable version of me is already within.'),
  Affirmation(id: 'core_043', packId: AffirmationPackIds.core, text: 'Progress is more important than perfection.'),
  Affirmation(id: 'core_044', packId: AffirmationPackIds.core, text: 'I prioritize the peace that dwells in my heart.'),
  Affirmation(id: 'core_045', packId: AffirmationPackIds.core, text: 'I have triumphed before, and I will again.'),
  Affirmation(id: 'core_046', packId: AffirmationPackIds.core, text: 'I am proud of the woman I am becoming.'),
  Affirmation(id: 'core_047', packId: AffirmationPackIds.core, text: 'I move in alignment with my own internal compass.'),
  Affirmation(id: 'core_048', packId: AffirmationPackIds.core, text: 'Taking it slow is a powerful choice for my health.'),
  Affirmation(id: 'core_049', packId: AffirmationPackIds.core, text: 'I am weaving a life of steady, quiet confidence.'),
  Affirmation(id: 'core_050', packId: AffirmationPackIds.core, text: 'My body\'s wisdom is a trusted guide.'),
  Affirmation(id: 'core_051', packId: AffirmationPackIds.core, text: 'I release the weight of the world from my shoulders.'),
  Affirmation(id: 'core_052', packId: AffirmationPackIds.core, text: 'I allow my healing to unfold at its own pace.'),
  Affirmation(id: 'core_053', packId: AffirmationPackIds.core, text: 'In the silence, I hear my own inner truth.'),
  Affirmation(id: 'core_054', packId: AffirmationPackIds.core, text: 'I am thriving in ways I haven\'t yet recognized.'),
  Affirmation(id: 'core_055', packId: AffirmationPackIds.core, text: 'Needing a reset is a sign of my self-awareness.'),
  Affirmation(id: 'core_056', packId: AffirmationPackIds.core, text: 'Peace is a practice I choose every day.'),
  Affirmation(id: 'core_057', packId: AffirmationPackIds.core, text: 'I am becoming unshakable in my self-worth.'),
  Affirmation(id: 'core_058', packId: AffirmationPackIds.core, text: 'I choose harmony over the habit of chaos.'),
  Affirmation(id: 'core_059', packId: AffirmationPackIds.core, text: 'Caring for myself is my most important work.'),
  Affirmation(id: 'core_060', packId: AffirmationPackIds.core, text: 'I step forward with faith, even without all the answers.'),
  Affirmation(id: 'core_061', packId: AffirmationPackIds.core, text: 'I nourish my body and mind with gentle thoughts.'),
  Affirmation(id: 'core_062', packId: AffirmationPackIds.core, text: 'I am safe, I am whole, and I am here.'),
  Affirmation(id: 'core_063', packId: AffirmationPackIds.core, text: 'I have the power to slow down my world.'),
  Affirmation(id: 'core_064', packId: AffirmationPackIds.core, text: 'I take up space with confidence and grace.'),
  Affirmation(id: 'core_065', packId: AffirmationPackIds.core, text: 'A single conscious breath can transform my day.'),
  Affirmation(id: 'core_066', packId: AffirmationPackIds.core, text: 'My inner calm radiates to everyone around me.'),
  Affirmation(id: 'core_067', packId: AffirmationPackIds.core, text: 'I am learning to flow with life rather than fight it.'),
  Affirmation(id: 'core_068', packId: AffirmationPackIds.core, text: 'I honor my fatigue as much as my energy.'),
  Affirmation(id: 'core_069', packId: AffirmationPackIds.core, text: 'My potential for joy is renewed every morning.'),
  Affirmation(id: 'core_070', packId: AffirmationPackIds.core, text: 'I always find my way back to my inner light.'),
  Affirmation(id: 'core_071', packId: AffirmationPackIds.core, text: 'I am my own best company and greatest advocate.'),
  Affirmation(id: 'core_072', packId: AffirmationPackIds.core, text: 'I forgive myself and let go of who I used to be.'),
  Affirmation(id: 'core_073', packId: AffirmationPackIds.core, text: 'I find richness in the simple, quiet moments.'),
  Affirmation(id: 'core_074', packId: AffirmationPackIds.core, text: 'My capacity for peace is expanding every day.'),
  Affirmation(id: 'core_075', packId: AffirmationPackIds.core, text: 'I am the master of my own internal weather.'),
  Affirmation(id: 'core_076', packId: AffirmationPackIds.core, text: 'One gentle moment is a victory for my soul.'),
  Affirmation(id: 'core_077', packId: AffirmationPackIds.core, text: 'I am not stuck; I am deeply rooted and growing.'),
  Affirmation(id: 'core_078', packId: AffirmationPackIds.core, text: 'My strength is rising quietly from within.'),
  Affirmation(id: 'core_079', packId: AffirmationPackIds.core, text: 'I am letting go of everything that feels heavy.'),
  Affirmation(id: 'core_080', packId: AffirmationPackIds.core, text: 'A minute of mindfulness changes everything.'),
  Affirmation(id: 'core_081', packId: AffirmationPackIds.core, text: 'I am flexible and strong like a willow in the wind.'),
  Affirmation(id: 'core_082', packId: AffirmationPackIds.core, text: 'My mind is a garden that I tend with love.'),
  Affirmation(id: 'core_083', packId: AffirmationPackIds.core, text: 'I trust the wisdom of my own heart.'),
  Affirmation(id: 'core_084', packId: AffirmationPackIds.core, text: 'I am always at home within myself.'),
  Affirmation(id: 'core_085', packId: AffirmationPackIds.core, text: 'I choose the path of least resistance and most joy.'),
  Affirmation(id: 'core_086', packId: AffirmationPackIds.core, text: 'I am discovering the beauty of a steady soul.'),
  Affirmation(id: 'core_087', packId: AffirmationPackIds.core, text: 'I leave behind what I no longer need to carry.'),
  Affirmation(id: 'core_088', packId: AffirmationPackIds.core, text: 'My soul\'s pace is the only one that matters.'),
  Affirmation(id: 'core_089', packId: AffirmationPackIds.core, text: 'I embrace the divine balance of my life.'),
  Affirmation(id: 'core_090', packId: AffirmationPackIds.core, text: 'Serenity is becoming my natural state of being.'),
  Affirmation(id: 'core_091', packId: AffirmationPackIds.core, text: 'I am grateful for all that I am and all I have.'),
  Affirmation(id: 'core_092', packId: AffirmationPackIds.core, text: 'Each pause is a sacred return to my center.'),
  Affirmation(id: 'core_093', packId: AffirmationPackIds.core, text: 'My breath is the most natural medicine I have.'),
  Affirmation(id: 'core_094', packId: AffirmationPackIds.core, text: 'I am creating a life that feels good on the inside.'),
  Affirmation(id: 'core_095', packId: AffirmationPackIds.core, text: 'I deserve a mind that is a peaceful place to live.'),
  Affirmation(id: 'core_096', packId: AffirmationPackIds.core, text: 'I inhale strength and exhale everything else.'),
  Affirmation(id: 'core_097', packId: AffirmationPackIds.core, text: 'I am unfolding into my most authentic self.'),
  Affirmation(id: 'core_098', packId: AffirmationPackIds.core, text: 'I am capable of breathing through any storm.'),
  Affirmation(id: 'core_099', packId: AffirmationPackIds.core, text: 'I meet myself with radical self-compassion.'),
  Affirmation(id: 'core_100', packId: AffirmationPackIds.core, text: 'Peace is my practice, and love is my guide.'),
];

/// Focus & Work affirmations (25)
const focusAffirmations = <Affirmation>[
  Affirmation(id: 'focus_001', packId: AffirmationPackIds.focus, text: 'I focus on one task right now.', isPremium: true),
  Affirmation(id: 'focus_002', packId: AffirmationPackIds.focus, text: 'I begin even before I feel ready.', isPremium: true),
  Affirmation(id: 'focus_003', packId: AffirmationPackIds.focus, text: 'I grow focus when I remove urgency.', isPremium: true),
  Affirmation(id: 'focus_004', packId: AffirmationPackIds.focus, text: 'I don’t need momentum to start.', isPremium: true),
  Affirmation(id: 'focus_005', packId: AffirmationPackIds.focus, text: 'My small progress still counts.', isPremium: true),
  Affirmation(id: 'focus_006', packId: AffirmationPackIds.focus, text: 'I work calmly and stay effective.', isPremium: true),
  Affirmation(id: 'focus_007', packId: AffirmationPackIds.focus, text: 'I choose where my attention goes.', isPremium: true),
  Affirmation(id: 'focus_008', packId: AffirmationPackIds.focus, text: 'I return to the task without judgment.', isPremium: true),
  Affirmation(id: 'focus_009', packId: AffirmationPackIds.focus, text: 'I find clarity by doing, not overthinking.', isPremium: true),
  Affirmation(id: 'focus_010', packId: AffirmationPackIds.focus, text: 'I finish this one step at a time.', isPremium: true),
  Affirmation(id: 'focus_011', packId: AffirmationPackIds.focus, text: 'I feel discomfort without treating it as danger.', isPremium: true),
  Affirmation(id: 'focus_012', packId: AffirmationPackIds.focus, text: 'I begin without perfect conditions.', isPremium: true),
  Affirmation(id: 'focus_013', packId: AffirmationPackIds.focus, text: 'I slow down and still move forward.', isPremium: true),
  Affirmation(id: 'focus_014', packId: AffirmationPackIds.focus, text: 'I build focus instead of forcing it.', isPremium: true),
  Affirmation(id: 'focus_015', packId: AffirmationPackIds.focus, text: 'I allow myself to work without pressure.', isPremium: true),
  Affirmation(id: 'focus_016', packId: AffirmationPackIds.focus, text: 'I take one clear action right now.', isPremium: true),
  Affirmation(id: 'focus_017', packId: AffirmationPackIds.focus, text: 'I release distraction and return gently.', isPremium: true),
  Affirmation(id: 'focus_018', packId: AffirmationPackIds.focus, text: 'I choose progress over intensity.', isPremium: true),
  Affirmation(id: 'focus_019', packId: AffirmationPackIds.focus, text: 'I stay with this moment.', isPremium: true),
  Affirmation(id: 'focus_020', packId: AffirmationPackIds.focus, text: 'I create better results with calm attention.', isPremium: true),
  Affirmation(id: 'focus_021', packId: AffirmationPackIds.focus, text: 'I don’t rush to be productive.', isPremium: true),
  Affirmation(id: 'focus_022', packId: AffirmationPackIds.focus, text: 'I steady my breath and sharpen my work.', isPremium: true),
  Affirmation(id: 'focus_023', packId: AffirmationPackIds.focus, text: 'I reset my focus at any time.', isPremium: true),
  Affirmation(id: 'focus_024', packId: AffirmationPackIds.focus, text: 'My work does not define my worth.', isPremium: true),
  Affirmation(id: 'focus_025', packId: AffirmationPackIds.focus, text: 'I finish what I can, and it’s enough.', isPremium: true),
];

/// Sleep & Night Reset affirmations (25)
const sleepAffirmations = <Affirmation>[
  Affirmation(id: 'sleep_001', packId: AffirmationPackIds.sleep, text: 'I let the day end here.', isPremium: true),
  Affirmation(id: 'sleep_002', packId: AffirmationPackIds.sleep, text: 'I don’t need to solve everything tonight.', isPremium: true),
  Affirmation(id: 'sleep_003', packId: AffirmationPackIds.sleep, text: 'I rest to support tomorrow.', isPremium: true),
  Affirmation(id: 'sleep_004', packId: AffirmationPackIds.sleep, text: 'My body knows how to power down.', isPremium: true),
  Affirmation(id: 'sleep_005', packId: AffirmationPackIds.sleep, text: 'I release today without replaying it.', isPremium: true),
  Affirmation(id: 'sleep_006', packId: AffirmationPackIds.sleep, text: 'Nothing else is required of me right now.', isPremium: true),
  Affirmation(id: 'sleep_007', packId: AffirmationPackIds.sleep, text: 'I let my thoughts slow naturally.', isPremium: true),
  Affirmation(id: 'sleep_012', packId: AffirmationPackIds.sleep, text: 'I soften without losing control.', isPremium: true),
  Affirmation(id: 'sleep_013', packId: AffirmationPackIds.sleep, text: 'I treat the night as a reset.', isPremium: true),
  Affirmation(id: 'sleep_014', packId: AffirmationPackIds.sleep, text: 'I don’t need answers to rest.', isPremium: true),
  Affirmation(id: 'sleep_015', packId: AffirmationPackIds.sleep, text: 'I allow my nervous system to calm.', isPremium: true),
  Affirmation(id: 'sleep_016', packId: AffirmationPackIds.sleep, text: 'I let this moment be quiet.', isPremium: true),
  Affirmation(id: 'sleep_017', packId: AffirmationPackIds.sleep, text: 'I trust my body to rest when it’s ready.', isPremium: true),
  Affirmation(id: 'sleep_018', packId: AffirmationPackIds.sleep, text: 'My work today is complete enough.', isPremium: true),
  Affirmation(id: 'sleep_019', packId: AffirmationPackIds.sleep, text: 'I put the day down now.', isPremium: true),
  Affirmation(id: 'sleep_020', packId: AffirmationPackIds.sleep, text: 'I let calm arrive by releasing resistance.', isPremium: true),
  Affirmation(id: 'sleep_021', packId: AffirmationPackIds.sleep, text: 'I don’t carry tomorrow tonight.', isPremium: true),
  Affirmation(id: 'sleep_022', packId: AffirmationPackIds.sleep, text: 'I let rest repair what effort can’t.', isPremium: true),
  Affirmation(id: 'sleep_008', packId: AffirmationPackIds.sleep, text: 'I let tomorrow wait until morning.', isPremium: true),
  Affirmation(id: 'sleep_009', packId: AffirmationPackIds.sleep, text: 'I stop holding everything.', isPremium: true),
  Affirmation(id: 'sleep_010', packId: AffirmationPackIds.sleep, text: 'I let sleep come without forcing it.', isPremium: true),
  Affirmation(id: 'sleep_011', packId: AffirmationPackIds.sleep, text: 'I signal safety with every steady breath.', isPremium: true),
  Affirmation(id: 'sleep_023', packId: AffirmationPackIds.sleep, text: 'I am safe to slow all the way down.', isPremium: true),
  Affirmation(id: 'sleep_024', packId: AffirmationPackIds.sleep, text: 'I prepare for sleep with a steady breath.', isPremium: true),
  Affirmation(id: 'sleep_025', packId: AffirmationPackIds.sleep, text: 'I allow the night to hold me.', isPremium: true),
];

/// Confidence & Strength affirmations (25)
const strengthAffirmations = <Affirmation>[
  Affirmation(id: 'strength_001', packId: AffirmationPackIds.strength, text: 'I carry calm as a form of strength.', isPremium: true),
  Affirmation(id: 'strength_002', packId: AffirmationPackIds.strength, text: 'I can handle what’s in front of me.', isPremium: true),
  Affirmation(id: 'strength_003', packId: AffirmationPackIds.strength, text: 'I stay powerful without reacting.', isPremium: true),
  Affirmation(id: 'strength_004', packId: AffirmationPackIds.strength, text: 'I choose steady over aggressive.', isPremium: true),
  Affirmation(id: 'strength_005', packId: AffirmationPackIds.strength, text: 'I trust myself to respond well.', isPremium: true),
  Affirmation(id: 'strength_006', packId: AffirmationPackIds.strength, text: 'I stay grounded under pressure.', isPremium: true),
  Affirmation(id: 'strength_007', packId: AffirmationPackIds.strength, text: 'I hold strength without tension.', isPremium: true),
  Affirmation(id: 'strength_008', packId: AffirmationPackIds.strength, text: 'I don’t need to prove anything right now.', isPremium: true),
  Affirmation(id: 'strength_009', packId: AffirmationPackIds.strength, text: 'I hold my ground without force.', isPremium: true),
  Affirmation(id: 'strength_010', packId: AffirmationPackIds.strength, text: 'I can pause and still be capable.', isPremium: true),
  Affirmation(id: 'strength_011', packId: AffirmationPackIds.strength, text: 'I build confidence by staying present.', isPremium: true),
  Affirmation(id: 'strength_012', packId: AffirmationPackIds.strength, text: 'I move at my own pace.', isPremium: true),
  Affirmation(id: 'strength_013', packId: AffirmationPackIds.strength, text: 'I keep my power when I stay calm.', isPremium: true),
  Affirmation(id: 'strength_014', packId: AffirmationPackIds.strength, text: 'I choose clarity over impulse.', isPremium: true),
  Affirmation(id: 'strength_015', packId: AffirmationPackIds.strength, text: 'I am firm without being harsh.', isPremium: true),
  Affirmation(id: 'strength_016', packId: AffirmationPackIds.strength, text: 'My composure is reliable.', isPremium: true),
  Affirmation(id: 'strength_017', packId: AffirmationPackIds.strength, text: 'I don’t need approval to trust myself.', isPremium: true),
  Affirmation(id: 'strength_018', packId: AffirmationPackIds.strength, text: 'I stay steady when things are uncertain.', isPremium: true),
  Affirmation(id: 'strength_019', packId: AffirmationPackIds.strength, text: 'I lead myself through this moment.', isPremium: true),
  Affirmation(id: 'strength_020', packId: AffirmationPackIds.strength, text: 'I let my strength be quiet.', isPremium: true),
  Affirmation(id: 'strength_021', packId: AffirmationPackIds.strength, text: 'I am capable without rushing.', isPremium: true),
  Affirmation(id: 'strength_022', packId: AffirmationPackIds.strength, text: 'I meet challenges without tightening.', isPremium: true),
  Affirmation(id: 'strength_023', packId: AffirmationPackIds.strength, text: 'I don’t need chaos to feel alive.', isPremium: true),
  Affirmation(id: 'strength_024', packId: AffirmationPackIds.strength, text: 'I carry myself with intention.', isPremium: true),
  Affirmation(id: 'strength_025', packId: AffirmationPackIds.strength, text: 'I am harder to shake than I used to be.', isPremium: true),
];

/// Map pack → affirmations
final Map<String, List<Affirmation>> affirmationsByPack = {
  AffirmationPackIds.core: coreAffirmations,
  AffirmationPackIds.focus: focusAffirmations,
  AffirmationPackIds.sleep: sleepAffirmations,
  AffirmationPackIds.strength: strengthAffirmations,
  AffirmationPackIds.panic: panicAffirmations,
  AffirmationPackIds.meeting: meetingAffirmations,
};
