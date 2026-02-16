import 'dart:math';

import 'package:flutter/material.dart';
import 'package:quietline_app/screens/shell/quiet_shell_screen.dart';
import 'quiet_results_constants.dart';

class QuietSessionCompleteScreen extends StatelessWidget {
  QuietSessionCompleteScreen({super.key}) : _copySet = _copySets[Random().nextInt(_copySets.length)];

  final _CopySet _copySet;

  static const List<_CopySet> _copySets = [
    _CopySet(
      headline: 'You came back.',
      subline: 'That’s discipline.',
      subtext: 'Calm compounds.',
    ),
    _CopySet(
      headline: 'You showed up.',
      subline: 'That’s progress.',
      subtext: 'Peace builds.',
    ),
    _CopySet(
      headline: 'You returned.',
      subline: 'That’s strength.',
      subtext: 'Stillness grows.',
    ),
    _CopySet(
      headline: 'You’re here again.',
      subline: 'That’s focus.',
      subtext: 'Quiet deepens.',
    ),
    _CopySet(
      headline: 'You came back.',
      subline: 'That’s courage.',
      subtext: 'Calm compounds.',
    ),
    _CopySet(
      headline: 'You showed up.',
      subline: 'That’s commitment.',
      subtext: 'Peace builds.',
    ),
    _CopySet(
      headline: 'You returned.',
      subline: 'That’s resilience.',
      subtext: 'Stillness grows.',
    ),
    _CopySet(
      headline: 'You’re here again.',
      subline: 'That’s willpower.',
      subtext: 'Quiet deepens.',
    ),
    _CopySet(
      headline: 'You came back.',
      subline: 'That’s dedication.',
      subtext: 'Calm compounds.',
    ),
    _CopySet(
      headline: 'You showed up.',
      subline: 'That’s persistence.',
      subtext: 'Peace builds.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: QuietResultsConstants.horizontalPadding,
          ),
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(
                        height: QuietResultsConstants.verticalSpacingLarge,
                      ),

                      // Primary copy
                      Text(
                        _copySet.headline,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),

                      const SizedBox(
                        height: QuietResultsConstants.verticalSpacingSmall,
                      ),

                      Text(
                        _copySet.subline,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),

                      const SizedBox(
                        height: QuietResultsConstants.verticalSpacingLarge,
                      ),

                      // Subtext
                      Text(
                        _copySet.subtext,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),

                      const SizedBox(
                        height: QuietResultsConstants.verticalSpacingLarge,
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: QuietResultsConstants.verticalSpacingLarge,
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder: (context) => const QuietShellScreen(),
                          ),
                          (route) => false);
                    },
                    child: const Text('Continue'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

@immutable
class _CopySet {
  final String headline;
  final String subline;
  final String subtext;

  const _CopySet({
    required this.headline,
    required this.subline,
    required this.subtext,
  });
}