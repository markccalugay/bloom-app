/// Centralized copy for the results screens.
class QuietResultsStrings {
  // OK / streak screen
  static const okHeadline = 'You showed up again.';
  static const okSub =
      'Stillness compounds. The calm you build today strengthens you tomorrow.';

  static String dayOfStreak(int n) => 'Day $n of your quiet streak.';

  static const continueButton = 'Continue';

  // Not OK screen
  static const notOkHeadline = "You're having a difficult moment.";
  static const notOkSubLine1 = "We’ll take this one step at a time.";
  static const notOkSubLine2 = "You’re safe here.";

  static const groundButton = 'Ground for 90 seconds';
  static const call988Button = 'Call 988';

  static const footer988 =
      'If you need immediate help, tap to call 988. You’re not alone.';
}