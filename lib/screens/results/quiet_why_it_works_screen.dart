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
            _WhySection(text: 'Slow, steady breathing works by regulating the autonomic nervous system, which governs how the body responds to stress, pressure, and emotional load. When stress is high, breathing becomes shallow and irregular, reinforcing a cycle of tension and reactivity. Returning the breath to a slow, predictable rhythm interrupts this cycle at the physiological level.'),
            _WhySection(text: 'Research shows that consistent breathing patterns improve heart rate variability, a key indicator of nervous system flexibility and emotional regulation. Higher heart rate variability is associated with better impulse control, improved mood stability, and greater resilience in the face of ongoing stress. Instead of swinging between overactivation and exhaustion, the body learns to stay balanced.'),
            _WhySection(text: 'Over time, this creates a foundation for discipline. When the nervous system is stable, it becomes easier to show up consistently, follow through on intentions, and make decisions without relying on forceful willpower. Discipline becomes something the body supports automatically, rather than something the mind has to constantly enforce.'),
          ],
          sources: [
            'Laborde, S., Mosley, E., & Thayer, J. F. (2017). Heart rate variability and cardiac vagal tone in psychophysiological research. Frontiers in Psychology, 8, 213. https://doi.org/10.3389/fpsyg.2017.00213',
            'Lehrer, P. M., & Gevirtz, R. (2014). Heart rate variability biofeedback: How and why does it work? Applied Psychophysiology and Biofeedback, 39(2), 109–135. https://doi.org/10.1007/s10484-014-9248-9',
          ],
        );
      case 'monk_calm':
        return const _WhyContent(
          sections: [
            _WhySection(text: 'Breathing techniques that emphasize longer exhales directly engage the parasympathetic nervous system, which is responsible for rest, recovery, and internal quiet. Physiologically, longer exhales slow the heart rate and reduce stress-related signaling between the body and the brain.'),
            _WhySection(text: 'As this calming response deepens, activity decreases in brain regions associated with anxiety, rumination, and hypervigilance. Thoughts may still arise, but they carry less urgency and emotional charge. This creates a mental environment where stillness becomes possible without effort or suppression.'),
            _WhySection(text: 'For centuries, contemplative and monastic traditions have used extended-exhale breathing because it works with the body rather than against it. Calm is not produced by forcing the mind to stop thinking. It emerges naturally when the body receives consistent signals of safety and stability.'),
          ],
          sources: [
            'Zaccaro, A., Piarulli, A., Laurino, M., Garbella, E., Menicucci, D., Neri, B., & Gemignani, A. (2018). How breath-control can change your life: A systematic review on psychophysiological correlates of slow breathing. Frontiers in Human Neuroscience, 12, 353. https://doi.org/10.3389/fnhum.2018.00353',
            'Porges, S. W. (2007). The polyvagal perspective. Biological Psychology, 74(2), 116–143. https://doi.org/10.1016/j.biopsycho.2006.06.009',
          ],
        );
      case 'navy_calm':
        return const _WhyContent(
          sections: [
            _WhySection(text: 'Breathing patterns that include longer holds and extended exhales slow the nervous system’s stress response. When breathing lengthens, signals from the lungs and heart tell the brain that the body is no longer in immediate danger.'),
            _WhySection(text: 'This reduces sympathetic nervous system activity, which drives fight-or-flight reactions. As arousal decreases, heart rate slows and muscle tension eases. Emotional responses become less reactive, making it easier to maintain composure in demanding situations.'),
            _WhySection(text: 'Because of these effects, extended breathing cycles are commonly taught in environments that require calm decision-making under pressure, including military training and emergency response. Slowing the breath creates a physiological pause, allowing clearer thinking and more deliberate action to replace impulsive reactions.'),
          ],
          sources: [
            'Jerath, R., Edry, J. W., Barnes, V. A., & Jerath, V. (2015). Physiology of long pranayamic breathing: Neural respiratory elements may provide a mechanism that explains how slow deep breathing shifts the autonomic nervous system. Medical Hypotheses, 85(3), 486–496. https://doi.org/10.1016/j.mehy.2015.07.007',
            'Brown, R. P., & Gerbarg, P. L. (2005). Sudarshan Kriya yogic breathing in the treatment of stress, anxiety, and depression. Journal of Alternative and Complementary Medicine, 11(4), 711–717. https://doi.org/10.1089/acm.2005.11.711',
          ],
        );
      case 'athlete_focus':
        return const _WhyContent(
          sections: [
            _WhySection(text: 'Controlled breathing improves coordination between the heart, lungs, and nervous system, which is essential for sustained performance. Under physical or mental load, breathing often becomes inefficient, leading to early fatigue and loss of focus.'),
            _WhySection(text: 'Research in sports and performance psychology shows that breathing regulation improves heart rate variability and oxygen efficiency. This allows the body to maintain calm alertness rather than tipping into overactivation or exhaustion. Focus sharpens, recovery between efforts improves, and reaction times become more consistent.'),
            _WhySection(text: 'Athletes use breathing techniques not to reduce intensity, but to support it. When the nervous system is steady, performance becomes repeatable and resilient. The body stays ready without burning through energy unnecessarily.'),
          ],
          sources: [
            'Laborde, S., Mosley, E., & Thayer, J. F. (2017). Heart rate variability and cardiac vagal tone in psychophysiological research. Frontiers in Psychology, 8, 213. https://doi.org/10.3389/fpsyg.2017.00213',
            'McConnell, A. K. (2013). Breathe strong, perform better. Human Kinetics.',
          ],
        );
      case 'cold_resolve':
        return const _WhyContent(
          sections: [
            _WhySection(text: 'This practice uses fast, activating breathing to intentionally stimulate the nervous system for a short period of time, followed by recovery. Unlike calming techniques, the goal here is controlled exposure to stress rather than immediate relaxation.'),
            _WhySection(text: 'Research shows that voluntary activation of the stress response can temporarily increase alertness and stress hormones. When followed by a return to baseline, this process can improve emotional regulation and stress tolerance over time. The nervous system learns that activation does not automatically lead to loss of control.'),
            _WhySection(text: 'This technique is inspired by breathing principles popularized by Wim Hof, but it does not fully replicate the Wim Hof Method and does not include cold exposure. The focus here is controlled activation within safe limits. Used intentionally, this approach helps train composure, resilience, and mental control under pressure.'),
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
            _WhySection(
              text:
                  'Slow, controlled breathing sends a clear signal to your nervous system that you are safe. '
                  'This signal matters because the nervous system is constantly scanning for threat, even when '
                  'no immediate danger is present.',
            ),
            _WhySection(
              text:
                  'When you breathe in a steady rhythm, like 4 seconds in, 4 seconds hold, and 4 seconds out, '
                  'your body shifts away from stress mode (fight or flight) and toward calm, regulated control '
                  '(rest and digest). Heart rate slows, muscle tension eases, and the brain reduces its sense of urgency.',
            ),
            _WhySection(
              text:
                  'This shift happens automatically. You are not trying to calm your thoughts directly. '
                  'Instead, you are changing the physical signals traveling from your lungs and heart to the brain, '
                  'which then adjusts emotional and mental state in response.',
            ),
            _WhySection(
              text: 'This happens because slow breathing:',
              bullets: [
                'Activates the vagus nerve, which lowers heart rate and blood pressure',
                'Improves heart rate variability (HRV), a key marker of nervous system resilience',
                'Reduces overactivity in brain regions linked to anxiety and rumination',
              ],
            ),
            _WhySection(
              text:
                  'You do not need to think positive thoughts or relax harder. '
                  'The rhythm alone does the work, even on days when your mind feels busy or resistant.',
            ),
            _WhySection(
              text: 'That is why simple breathing patterns are widely used by:',
              bullets: [
                'Clinicians treating anxiety and PTSD',
                'Athletes under performance stress',
                'Military and first responders to regain control quickly',
              ],
            ),
            _WhySection(
              text:
                  'By finishing this session, you told your nervous system that the moment is manageable '
                  'and that you are back in control.',
              isBold: true,
            ),
          ],
          sources: [
            'Jerath, R., Edry, J. W., Barnes, V. A., & Jerath, V. (2015). '
                'Physiology of long pranayamic breathing: Neural respiratory elements may provide a mechanism '
                'that explains how slow deep breathing shifts the autonomic nervous system. '
                'Medical Hypotheses, 85(3), 486-496. https://doi.org/10.1016/j.mehy.2015.07.007',
            'Laborde, S., Mosley, E., & Thayer, J. F. (2017). '
                'Heart rate variability and cardiac vagal tone in psychophysiological research. '
                'Frontiers in Psychology, 8, 213. https://doi.org/10.3389/fpsyg.2017.00213',
            'Zaccaro, A., Piarulli, A., Laurino, M., Garbella, E., Menicucci, D., Neri, B., & Gemignani, A. (2018). '
                'How breath-control can change your life: A systematic review on psychophysiological correlates '
                'of slow breathing. Frontiers in Human Neuroscience, 12, 353. '
                'https://doi.org/10.3389/fnhum.2018.00353',
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
