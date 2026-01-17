import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class QuietTimePickerSheet extends StatefulWidget {
  const QuietTimePickerSheet({super.key});

  @override
  State<QuietTimePickerSheet> createState() => _QuietTimePickerSheetState();
}

class _QuietTimePickerSheetState extends State<QuietTimePickerSheet> {
  int _selectedHour = 9; // 1–12
  int _selectedMinute = 0; // 0–55 (5 min steps)
  bool _isAm = true;

  static const List<int> _hours = [
    1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12
  ];

  static const List<int> _minutes = [
    0, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55
  ];

  void _confirm() {
    HapticFeedback.lightImpact();
    int hour24 = _selectedHour % 12;
    if (!_isAm) {
      hour24 += 12;
    }

    final time = TimeOfDay(
      hour: hour24,
      minute: _selectedMinute,
    );

    Navigator.of(context).pop(time);
  }

  void _cancel() {
    Navigator.of(context).pop(null);
  }

  Widget _buildPicker<T>({
    required List<T> values,
    required T selectedValue,
    required ValueChanged<T> onChanged,
    required String Function(T) labelBuilder,
  }) {
    final controller = FixedExtentScrollController(
      initialItem: values.indexOf(selectedValue),
    );

    return Expanded(
      child: CupertinoPicker(
        scrollController: controller,
        itemExtent: 40,
        magnification: 1.1,
        useMagnifier: true,
        onSelectedItemChanged: (index) {
          onChanged(values[index]);
          HapticFeedback.selectionClick();
        },
        children: values
            .map(
              (value) => Center(
                child: Text(
                  labelBuilder(value),
                  style: const TextStyle(
                    fontSize: 22,
                    color: Colors.white,
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        decoration: const BoxDecoration(
          color: Color(0xFF0E1A1F), // QuietLine dark tone
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(24),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title
            const Text(
              'Choose a time',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 16),

            // Pickers
            SizedBox(
              height: 160,
              child: Row(
                children: [
                  _buildPicker<int>(
                    values: _hours,
                    selectedValue: _selectedHour,
                    onChanged: (value) {
                      setState(() => _selectedHour = value);
                    },
                    labelBuilder: (v) => v.toString(),
                  ),
                  _buildPicker<int>(
                    values: _minutes,
                    selectedValue: _selectedMinute,
                    onChanged: (value) {
                      setState(() => _selectedMinute = value);
                    },
                    labelBuilder: (v) => v.toString().padLeft(2, '0'),
                  ),
                  _buildPicker<bool>(
                    values: const [true, false],
                    selectedValue: _isAm,
                    onChanged: (value) {
                      setState(() => _isAm = value);
                    },
                    labelBuilder: (v) => v ? 'AM' : 'PM',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Actions
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: _cancel,
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                ),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _confirm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4FA39A),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: const Text('Confirm'),
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