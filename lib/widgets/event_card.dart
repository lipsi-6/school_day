// event_card.dart
import 'dart:async';
import 'package:flutter/material.dart';
import '../models/time_event.dart';

class EventCard extends StatefulWidget {
  final TimeEvent? event;
  final bool isPaused;

  const EventCard({
    super.key,
    required this.event,
    required this.isPaused,
  });

  @override
  State<EventCard> createState() => _EventCardState();
}

class _EventCardState extends State<EventCard> {
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ListTile(
              title: Text(widget.event?.name.isNotEmpty == true
                  ? widget.event!.name
                  : widget.event?.category ?? '无进行中事件'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.event != null) ...[
                    Text(widget.event!.timeRange),
                    Text('持续时间: ${_formatDuration(widget.event!.effectiveDuration)}'),
                    if (widget.event!.description.isNotEmpty)
                      Text(widget.event!.description),
                  ],
                ],
              ),
            ),
            if (widget.isPaused)
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
    final seconds = duration.inSeconds.remainder(60); // 新增秒级显示
    return '${hours}h ${minutes}m ${seconds}s'; // 添加秒数
  }
}