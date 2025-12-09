enum MoodCheckinMode { pre, post }

final List<String> kMCPreHeaders = [
  "How are you arriving today?",
  "Check in with yourself.",
  "Before you begin, how are you?",
  "Where is your energy right now?",
  "Take a second — how do you feel?"
];

final List<String> kMCPostHeaders = [
  "You made space to breathe. That's strength.",
  "You slowed down. Good work.",
  "You created calm. Well done.",
  "You chose stillness. That's powerful.",
  "You showed up for yourself."
];

const String kMCQuestionLabel = "How do you feel now?";
const String kMCLabelLeft = "overwhelmed";
const String kMCLabelRight = "calm";