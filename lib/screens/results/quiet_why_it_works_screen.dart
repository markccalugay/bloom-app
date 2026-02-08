import 'package:flutter/material.dart';
import 'package:quietline_app/widgets/ql_primary_button.dart';
import 'package:quietline_app/theme/ql_theme.dart';

class QuietWhyItWorksScreen extends StatefulWidget {
  final String practiceId;
  final VoidCallback onContinue;

  const QuietWhyItWorksScreen({
    super.key,
    this.practiceId = 'core_quiet',
    required this.onContinue,
  });

  @override
  State<QuietWhyItWorksScreen> createState() => _QuietWhyItWorksScreenState();
}

class _QuietWhyItWorksScreenState extends State<QuietWhyItWorksScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _showContinue = false;
  bool _showSources = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_showContinue) {
      if (_scrollController.position.pixels > _scrollController.position.maxScrollExtent * 0.4) {
        setState(() => _showContinue = true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;
    final content = _getContent(widget.practiceId);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(24, 40, 24, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Why this works',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: onSurface,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ...content.sections.map((s) => _buildSection(s.text, bullets: s.bullets, isBold: s.isBold)),
                  const SizedBox(height: 48),
                  
                  // Sources Toggle
                  GestureDetector(
                    onTap: () => setState(() => _showSources = !_showSources),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(color: onSurface.withValues(alpha: 0.1)),
                        ),
                      ),
                      child: Row(
                        children: [
                          Text(
                            'Sources',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: onSurface.withValues(alpha: 0.7),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            _showSources ? 'Collapse' : '(Tap to expand)',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: onSurface.withValues(alpha: 0.5),
                            ),
                          ),
                          Icon(
                            _showSources ? Icons.expand_less : Icons.expand_more,
                            size: 18,
                            color: onSurface.withValues(alpha: 0.5),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  if (_showSources) ...[
                    const SizedBox(height: 16),
                    ...content.sources.map((src) => _buildSource(src)),
                  ],
                ],
              ),
            ),
            
            // Fading Continue Button
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 500),
                opacity: _showContinue ? 1.0 : 0.0,
                child: IgnorePointer(
                  ignoring: !_showContinue,
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          theme.scaffoldBackgroundColor.withValues(alpha: 0.0),
                          theme.scaffoldBackgroundColor.withValues(alpha: 0.9),
                          theme.scaffoldBackgroundColor,
                        ],
                      ),
                    ),
                    child: QLPrimaryButton(
                      label: 'Continue',
                      onPressed: widget.onContinue,
                      margin: EdgeInsets.zero,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String text, {List<String>? bullets, bool isBold = false}) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;

    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            text,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: onSurface.withValues(alpha: 0.9),
              height: 1.5,
              fontWeight: isBold ? FontWeight.w700 : FontWeight.normal,
            ),
          ),
          if (bullets != null) ...[
            const SizedBox(height: 12),
            ...bullets.map((b) => Padding(
                  padding: const EdgeInsets.only(left: 12, bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Container(
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(
                            color: QLColors.primaryTeal,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          b,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: onSurface.withValues(alpha: 0.8),
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ],
      ),
    );
  }

  Widget _buildSource(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
          height: 1.4,
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }

  _WhyContent _getContent(String id) {
    switch (id) {
      case 'steady_discipline':
        return const _WhyContent(
          sections: [
            _WhySection(text: 'Slow, steady breathing helps regulate the autonomic nervous system — the system that controls stress, focus, and emotional reactions.'),
            _WhySection(text: 'When breathing follows a consistent rhythm, heart rate variability (HRV) improves. Higher HRV is associated with better emotional regulation, impulse control, and long-term stress resilience. Over time, this supports discipline by stabilizing the body first, so the mind can follow.'),
            _WhySection(text: 'Discipline isn’t forced.\nIt’s trained through repetition.', isBold: true),
          ],
          sources: [
            'Laborde, S., Mosley, E., & Thayer, J. F. (2017). Heart rate variability and cardiac vagal tone in psychophysiological research. Frontiers in Psychology, 8, 213. https://doi.org/10.3389/fpsyg.2017.00213',
            'Lehrer, P. M., & Gevirtz, R. (2014). Heart rate variability biofeedback: How and why does it work? Applied Psychophysiology and Biofeedback, 39(2), 109–135. https://doi.org/10.1007/s10484-014-9248-9',
          ],
        );
      case 'monk_calm':
        return const _WhyContent(
          sections: [
            _WhySection(text: 'Longer exhales directly stimulate the parasympathetic nervous system — the body’s primary calming mechanism.'),
            _WhySection(text: 'Research shows that extending the exhale slows heart rate, lowers physiological arousal, and reduces activity in brain regions associated with anxiety and rumination. This is why extended-exhale breathing has been used for centuries in contemplative practices to cultivate mental stillness.'),
            _WhySection(text: 'Stillness emerges when the body feels safe.', isBold: true),
          ],
          sources: [
            'Zaccaro, A., Piarulli, A., Laurino, M., Garbella, E., Menicucci, D., Neri, B., & Gemignani, A. (2018). How breath-control can change your life: A systematic review on psychophysiological correlates of slow breathing. Frontiers in Human Neuroscience, 12, 353. https://doi.org/10.3389/fnhum.2018.00353',
            'Porges, S. W. (2007). The polyvagal perspective. Biological Psychology, 74(2), 116–143. https://doi.org/10.1016/j.biopsycho.2006.06.009',
          ],
        );
      case 'navy_calm':
        return const _WhyContent(
          sections: [
            _WhySection(text: 'Breathing patterns with longer holds and exhales reduce nervous system arousal and improve stress tolerance.'),
            _WhySection(text: 'Studies show that extended breathing cycles lower heart rate, decrease sympathetic nervous system activity, and promote composure during high-pressure situations. This makes the technique effective for maintaining control when emotions or stress are elevated.'),
            _WhySection(text: 'Slow breathing creates space between reaction and response.', isBold: true),
          ],
          sources: [
            'Jerath, R., Edry, J. W., Barnes, V. A., & Jerath, V. (2015). Physiology of long pranayamic breathing: Neural respiratory elements may provide a mechanism that explains how slow deep breathing shifts the autonomic nervous system. Medical Hypotheses, 85(3), 486–496. https://doi.org/10.1016/j.mehy.2015.07.007',
            'Brown, R. P., & Gerbarg, P. L. (2005). Sudarshan Kriya yogic breathing in the treatment of stress, anxiety, and depression. Journal of Alternative and Complementary Medicine, 11(4), 711–717. https://doi.org/10.1089/acm.2005.11.711',
          ],
        );
      case 'athlete_focus':
        return const _WhyContent(
          sections: [
            _WhySection(text: 'Controlled breathing improves the coordination between the heart, lungs, and nervous system.'),
            _WhySection(text: 'Sports science research shows that breathing regulation enhances focus, speeds recovery, and stabilizes physiological readiness. By improving heart rate variability and oxygen efficiency, athletes use breathing to stay calm, alert, and responsive under physical and mental load.'),
            _WhySection(text: 'Calm focus outperforms raw intensity.', isBold: true),
          ],
          sources: [
            'Laborde, S., Mosley, E., & Thayer, J. F. (2017). Heart rate variability and cardiac vagal tone in psychophysiological research. Frontiers in Psychology, 8, 213. https://doi.org/10.3389/fpsyg.2017.00213',
            'McConnell, A. K. (2013). Breathe strong, perform better. Human Kinetics.',
          ],
        );
      case 'cold_resolve':
        return const _WhyContent(
          sections: [
            _WhySection(text: 'This practice uses fast, activating breathing to briefly stimulate the nervous system, followed by recovery.'),
            _WhySection(text: 'Research shows that controlled activation can increase alertness and stress hormones temporarily, followed by improved emotional regulation and stress resilience. This technique is inspired by the breathing principles popularized by Wim Hof, but it does not fully replicate the Wim Hof Method or include cold exposure.'),
            _WhySection(text: 'This is controlled stress — used to train composure, not overwhelm.', isBold: true),
          ],
          sources: [
            'Kox, M., van Eijk, L. T., Zwaag, J., van den Wildenberg, J., Sweep, F. C., van der Hoeven, J. G., & Pickkers, P. (2014). Voluntary activation of the sympathetic nervous system and attenuation of the innate immune response. Proceedings of the National Academy of Sciences, 111(20), 7379–7384. https://doi.org/10.1073/pnas.1322174111',
            'Zaccaro, A., et al. (2018). How breath-control can change your life: A systematic review on psychophysiological correlates of slow breathing. Frontiers in Human Neuroscience, 12, 353. https://doi.org/10.3389/fnhum.2018.00353',
          ],
        );
      case 'core_quiet':
      default:
        return const _WhyContent(
          sections: [
            _WhySection(text: 'Slow, controlled breathing sends a signal to your nervous system that you’re safe.'),
            _WhySection(text: 'When you breathe in a steady rhythm — like 4 seconds in, 4 seconds hold, 4 seconds out — your body shifts away from stress mode (fight-or-flight) and toward calm, regulated control (rest-and-digest).'),
            _WhySection(
              text: 'This happens because slow breathing:',
              bullets: [
                'Activates the vagus nerve, which lowers heart rate and blood pressure',
                'Improves heart rate variability (HRV), a key marker of nervous system resilience',
                'Reduces overactivity in brain regions linked to anxiety and rumination',
              ],
            ),
            _WhySection(text: 'You don’t need to think positive thoughts or “relax harder.”\nThe rhythm alone does the work.'),
            _WhySection(
              text: 'That’s why simple breathing patterns are used by:',
              bullets: [
                'Clinicians treating anxiety and PTSD',
                'Athletes under performance stress',
                'Military and first responders to regain control fast',
              ],
            ),
            _WhySection(text: 'You just told your nervous system: we’re okay.', isBold: true),
          ],
          sources: [
            'Jerath, R., Edry, J. W., Barnes, V. A., & Jerath, V. (2015). Physiology of long pranayamic breathing: Neural respiratory elements may provide a mechanism that explains how slow deep breathing shifts the autonomic nervous system. Medical Hypotheses, 85(3), 486–496. https://doi.org/10.1016/j.mehy.2015.07.007',
            'Laborde, S., Mosley, E., & Thayer, J. F. (2017). Heart rate variability and cardiac vagal tone in psychophysiological research. Frontiers in Psychology, 8, 213. https://doi.org/10.3389/fpsyg.2017.00213',
            'Zaccaro, A., Piarulli, A., Laurino, M., Garbella, E., Menicucci, D., Neri, B., & Gemignani, A. (2018). How breath-control can change your life: A systematic review on psychophysiological correlates of slow breathing. Frontiers in Human Neuroscience, 12, 353. https://doi.org/10.3389/fnhum.2018.00353',
          ],
        );
    }
  }
}

class _WhyContent {
  final List<_WhySection> sections;
  final List<String> sources;

  const _WhyContent({required this.sections, required this.sources});
}

class _WhySection {
  final String text;
  final List<String>? bullets;
  final bool isBold;

  const _WhySection({required this.text, this.bullets, this.isBold = false});
}
