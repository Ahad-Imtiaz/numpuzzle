import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class RulesWidget extends StatelessWidget {
  const RulesWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final rules = [
      {
        'Simple': '\n${!kIsWeb ? 'Tap' : 'Click'} numbers in order from 1 to 25.',
      },
      {
        'Easy': '\n${!kIsWeb ? 'Tap' : 'Click'} numbers in order from 1 to 25. Some red cells are traps.',
      },
      {
        'Intermediate':
            '\n${!kIsWeb ? 'Tap' : 'Click'} numbers in order from 1 to 25. Red cells appear and change dynamically.',
      },
      {
        'Hard': '\n${!kIsWeb ? 'Tap' : 'Click'} numbers in order from 1 to 25. Red cells appear and change dynamically.'
            '\nRows and Columns shift periodically.',
      },
      {
        'Reversed Mode': '\nStart with all cells selected and unselect them in order.',
      },
      {
        'Punish Wrong ${!kIsWeb ? 'Taps' : 'Clicks'}':
            '\nWrong ${!kIsWeb ? 'taps' : 'clicks'} will make the number in the selected cells disappear for 2 seconds.',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: rules
          .map((rule) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: RichText(
                  text: TextSpan(
                    style: DefaultTextStyle.of(context).style,
                    children: [
                      TextSpan(
                        text: rule.keys.first,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(text: rule.values.first),
                    ],
                  ),
                ),
              ))
          .toList(),
    );
  }
}
