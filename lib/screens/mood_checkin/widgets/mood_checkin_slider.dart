import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../mood_checkin_constants.dart';
import '../mood_checkin_strings.dart';

class MoodCheckinSlider extends StatefulWidget {
  final int value;                   // 1..5
  final ValueChanged<int> onChanged; // emits snapped int

  const MoodCheckinSlider({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  State<MoodCheckinSlider> createState() => _MoodCheckinSliderState();
}

class _MoodCheckinSliderState extends State<MoodCheckinSlider> {
  late double _sliderValue; // internal double for Slider

  @override
  void initState() {
    super.initState();
    _sliderValue = widget.value.toDouble().clamp(1, 5);
  }

  @override
  void didUpdateWidget(covariant MoodCheckinSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _sliderValue = widget.value.toDouble().clamp(1, 5);
    }
  }

  void _handleChanged(double v) {
    final snapped = v.round().clamp(1, 5);
    if (snapped != widget.value) {
      HapticFeedback.selectionClick();
      widget.onChanged(snapped);
    }
    setState(() {
      _sliderValue = snapped.toDouble();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Slider
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: kMCSliderTrackHeight,
                  activeTrackColor: kMCPrimaryTeal,
                  inactiveTrackColor: kMCTrackColor,
                  thumbShape: const _ShieldThumbShape(),
                  overlayShape: SliderComponentShape.noOverlay,
                  thumbColor: kMCPrimaryTeal,
                  activeTickMarkColor: Colors.transparent,
                  inactiveTickMarkColor: Colors.transparent,
                ),
                child: Slider(
                  min: 1,
                  max: 5,
                  divisions: 4,
                  value: _sliderValue,
                  onChanged: _handleChanged,
                ),
              ),
            ),

            const SizedBox(height: kMCSliderToLabelsGap),

            // Numeric labels 1–5
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(5, (index) {
                  final num = index + 1;
                  final isActive = num == _sliderValue.round();
                  return Text(
                    '$num',
                    style: TextStyle(
                      color: isActive ? kMCTextColor : kMCLowLabelColor,
                      fontSize: 14,
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                    ),
                  );
                }),
              ),
            ),

            const SizedBox(height: 4),

            // "overwhelmed" / "calm" labels
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  kMCLabelLeft,
                  style: TextStyle(
                    color: kMCLowLabelColor,
                    fontSize: 12,
                  ),
                ),
                Text(
                  kMCLabelRight,
                  style: TextStyle(
                    color: kMCLowLabelColor,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom thumb that feels like a rounded “shield”.
class _ShieldThumbShape extends SliderComponentShape {
  const _ShieldThumbShape();

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return const Size(kMCSliderThumbSize, kMCSliderThumbSize);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final canvas = context.canvas;
    final paint = Paint()
      ..color = kMCPrimaryTeal
      ..style = PaintingStyle.fill;

    final rect = Rect.fromCenter(
      center: center,
      width: kMCSliderThumbSize,
      height: kMCSliderThumbSize,
    );

    final rRect = RRect.fromRectAndRadius(rect, const Radius.circular(8));
    canvas.drawRRect(rRect, paint);
  }
}