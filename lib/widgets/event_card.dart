import 'package:flutter/material.dart';
import '../models/time_event.dart';

class EventCard extends StatelessWidget {
  final TimeEvent? event;
  final bool isPaused;

  const EventCard({
    super.key,
    required this.event,
    required this.isPaused,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ListTile(
              title: Text(event?.name.isNotEmpty == true
                  ? event!.name
                  : event?.category ?? '无进行中事件'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (event != null) ...[
                    Text(event!.timeRange),
                    Text('持续时间: ${_formatDuration(event!.effectiveDuration)}'),
                    if (event!.description.isNotEmpty)
                      Text(event!.description),
                  ],
                ],
              ),
            ),
            if (isPaused)
              const Chip(
                label: Text('已暂停'),
                backgroundColor: Colors.orange,
              )
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    return '${hours}h ${minutes}m';
  }
}