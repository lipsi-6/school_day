// time_event.dart
import 'package:intl/intl.dart';

class TimeEvent {
  String category;
  String name;
  String description;
  final DateTime startTime;
  DateTime? endTime;
  DateTime? pauseStart;
  Duration pausedDuration = Duration.zero;

  TimeEvent({
    required this.category,
    required this.startTime,
    this.name = '',
    this.description = '',
  });

  Duration get effectiveDuration {
    final end = endTime ?? DateTime.now();  // 关键修改
    final base = end.difference(startTime);
    return base - pausedDuration;
  }

  String get timeRange {
    final end = endTime ?? DateTime.now();
    return '${DateFormat('HH:mm').format(startTime)} - ${DateFormat('HH:mm').format(end)}';
  }
}