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
    final end = endTime ?? DateTime.now();
    final base = end.difference(startTime);
    final currentPause = pauseStart != null ? DateTime.now().difference(pauseStart!) : Duration.zero;
    return base - pausedDuration - currentPause;  // 关键修复：实时扣除当前暂停时段
  }

  String get timeRange {
    final end = endTime ?? DateTime.now();
    return '${DateFormat('HH:mm').format(startTime)} - ${DateFormat('HH:mm').format(end)}';
  }
}