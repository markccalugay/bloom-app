import 'package:flutter/material.dart';
import 'mood_checkin_constants.dart';
import 'mood_checkin_controller.dart';
import 'mood_checkin_strings.dart';
import 'widgets/mood_checkin_header.dart';
import 'widgets/mood_checkin_slider.dart';
import 'widgets/mood_checkin_skip_button.dart';
import 'package:quietline_app/widgets/ql_primary_button.dart';
import 'package:quietline_app/core/feature_flags.dart';

import 'package:quietline_app/data/mood/mood_checkin_record.dart';
import 'package:quietline_app/data/mood/mood_checkin_store.dart';
import 'package:quietline_app/data/streak/quiet_streak_service.dart';
import 'package:quietline_app/data/user/user_service.dart';
import 'package:quietline_app/services/first_launch_service.dart';
import 'package:quietline_app/screens/results/quiet_results_ok_screen.dart';

import 'package:quietline_app/screens/results/quiet_results_not_ok_screen.dart';

// Phase 5 (MVP): Gate the distress / Not OK results variant behind a flag.
// Keep the screen + wiring intact for V2, but make it unreachable for MVP.
// Use a getter (not a const) so the code path remains compilable/wired for V2
// without triggering compile-time dead-code analysis.
bool get kDistressResultsEnabled => false;

class MoodCheckinScreen extends StatefulWidget {
  final MoodCheckinMode mode;
  final void Function(int score) onSubmit;
  final VoidCallback? onSkip; // used only for pre mode
  final int initialValue;
  final String? sessionId;

  const MoodCheckinScreen({
    super.key,
    required this.mode,
    required this.onSubmit,
    this.onSkip,
    this.initialValue = 3,
    this.sessionId,
  });

  @override
  State<MoodCheckinScreen> createState() => _MoodCheckinScreenState();
}

class _MoodCheckinScreenState extends State<MoodCheckinScreen> {
  late MoodCheckinController controller;

  @override
  void initState() {
    super.initState();
    controller = MoodCheckinController(
      mode: widget.mode,
      onSubmit: widget.onSubmit,
      onSkip: widget.onSkip,
    );
    controller.value = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    final bool isPre = widget.mode == MoodCheckinMode.pre;

    // Phase 3.2 (Option A): If mood check-ins are disabled for MVP, this screen
    // should be a harmless dead-end. We immediately route users to the correct
    // flow without saving mood data or mutating streak.
    if (!FeatureFlags.moodCheckInsEnabled) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) return;

        if (isPre) {
          // Continue the original pre-flow (typically routes into breathing via the shell callback).
          controller.submit();
          return;
        }

        // Capture navigator before any async gap to satisfy `use_build_context_synchronously`.
        final navigator = Navigator.of(context);

        // POST mode: route to OK results as a safe default.
        int current = 0;
        try {
          current = await QuietStreakService.getCurrentStreak();
        } catch (_) {
          current = 0;
        }

        if (!mounted) return;

        navigator.pushReplacement(
          MaterialPageRoute(
            builder: (_) => QuietResultsOkScreen(
              streak: current,
              isNew: false,
            ),
          ),
        );
      });

      // Render an empty scaffold while we redirect.
      return const Scaffold(body: SizedBox.shrink());
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: kMCHeaderTopGap),

            // HEADER
            MoodCheckinHeader(text: controller.header),

            const SizedBox(height: kMCHeaderToQuestionGap),

            // QUESTION LABEL
            const Text(
              kMCQuestionLabel,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: kMCTextColor,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: kMCQuestionToSliderGap),

            // SLIDER
            MoodCheckinSlider(
              value: controller.value,
              onChanged: (v) => setState(() => controller.setValue(v)),
            ),

            const Spacer(),

            // PRIMARY BUTTON
            QLPrimaryButton(
              label: isPre ? 'Begin' : 'Continue',
              onPressed: () async {
                // 1. Get the current score from the controller (round to int if needed).
                final int score = controller.value.round();
                debugPrint(
                  'MoodCheckin pressed: mode=${widget.mode}, score=$score',
                );

                // 2. Build a new mood record for this check-in.
                final record = MoodCheckinRecord.newEntry(
                  mode: widget.mode, // pre OR post
                  score: score,
                  sessionId:
                      widget.sessionId, // <-- link this check-in to a session
                );

                // 3. Save to local storage.
                const store = MoodCheckinStore();
                await store.save(record);

                // 4. Continue the original flow (pre → breath, post → next screen).
                // controller.submit();

                // Phase 3 – Step 2: Results Router
                if (widget.mode == MoodCheckinMode.pre) {
                  // Original behavior: continue to the breath screen.
                  controller.submit();
                } else {
                  // POST mode: route to results.
                  if (score >= 3) {
                    // Capture navigator before any async gap.
                    final navigator = Navigator.of(context);

                    // 1. Update streak as usual.
                    final newStreak =
                        await QuietStreakService.registerSessionCompletedToday();

                    // 2. Ensure anonymous user exists.
                    final user = await UserService.instance.getOrCreateUser();
                    debugPrint('Using user: ${user.username} (${user.id})');

                    // 3. Mark first session completion (idempotent).
                    await FirstLaunchService.instance.markCompleted();

                    // 4. Continue into results (replace so back doesn't return to mood screen).
                    if (!mounted) return;
                    navigator.pushReplacement(
                      MaterialPageRoute(
                        builder: (_) => QuietResultsOkScreen(
                          streak: newStreak,
                          isNew: true,
                        ),
                      ),
                    );
                  } else {
                    // Phase 5 (MVP): Distress results are gated. For MVP we always
                    // route to the standard results flow even if the mood score is low.
                    if (!kDistressResultsEnabled) {
                      // Capture navigator before any async gap.
                      final navigator = Navigator.of(context);

                      int current = 0;
                      try {
                        current = await QuietStreakService.getCurrentStreak();
                      } catch (_) {
                        current = 0;
                      }

                      if (!mounted) return;

                      navigator.pushReplacement(
                        MaterialPageRoute(
                          builder: (_) => QuietResultsOkScreen(
                            streak: current,
                            isNew: false,
                          ),
                        ),
                      );
                      return;
                    }

                    if (!mounted) return;
                    final navigator = Navigator.of(context);

                    navigator.pushReplacement(
                      MaterialPageRoute(
                        builder: (_) => const QuietResultsNotOkScreen(),
                      ),
                    );
                  }
                }
              },
              backgroundColor: kMCPrimaryTeal,
              textColor: Colors.white,
              margin: const EdgeInsets.only(
                left: 40,
                right: 40,
                top: 24,
                bottom: 8,
              ),
            ),

            // SKIP BUTTON (PRE ONLY)
            if (isPre && widget.onSkip != null)
              MoodCheckinSkipButton(onTap: () => controller.skip()),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
