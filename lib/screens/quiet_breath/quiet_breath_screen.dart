import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'controllers/quiet_breath_controller.dart';
import 'quiet_breath_constants.dart';
import 'widgets/quiet_breath_circle.dart';
import 'widgets/quiet_breath_controls.dart';
import 'widgets/quiet_breath_timer_title.dart';
import 'package:quietline_app/screens/mood_checkin/mood_checkin_screen.dart';
import 'package:quietline_app/screens/mood_checkin/mood_checkin_strings.dart';

class QuietBreathScreen extends StatefulWidget {
  final String sessionId;
  const QuietBreathScreen({super.key, required this.sessionId});
  @override
  State<QuietBreathScreen> createState() => _QuietBreathScreenState();
}

class _QuietBreathScreenState extends State<QuietBreathScreen>
    with TickerProviderStateMixin {
  late final QuietBreathController controller;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    controller = QuietBreathController(vsync: this);
    controller.onSessionComplete = _handleSessionComplete;
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _handleSessionComplete() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => MoodCheckinScreen(
          mode: MoodCheckinMode.post,
          sessionId: widget.sessionId,
          onSubmit: (score) {},
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: kQBHeaderTopGap),
            AnimatedBuilder(
              animation: controller.listenable,
              builder: (_, _) => QuietBreathTimerTitle(controller: controller),
            ),
            Expanded(child: QuietBreathCircle(controller: controller)),
            QuietBreathControls(controller: controller),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}