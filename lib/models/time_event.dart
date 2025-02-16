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
    final base = endTime?.difference(startTime) ?? Duration.zero;
    return base - pausedDuration;
  }

  String get timeRange {
    final end = endTime ?? DateTime.now();
    return '${DateFormat('HH:mm').format(startTime)} - ${DateFormat('HH:mm').format(end)}';
  }
}