import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/time_tracker.dart';
import '../models/time_event.dart';

class ControlButtons extends StatelessWidget {
  final TimeEvent? event;
  final bool isPaused;

  const ControlButtons({
    super.key,
    required this.event,
    required this.isPaused,
  });

  @override
  Widget build(BuildContext context) {
    final tracker = context.read<TimeTracker>();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          if (event != null) ...[
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isPaused ? Colors.green : Colors.orange,
              ),
              onPressed: isPaused ? tracker.resumeEvent : tracker.pauseEvent,
              child: Text(isPaused ? '恢复' : '暂停'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              onPressed: tracker.stopCurrentEvent,
              child: const Text('结束'),
            ),
          ],
        ],
      ),
    );
  }
}