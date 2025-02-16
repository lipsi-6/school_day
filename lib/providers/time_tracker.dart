import 'package:flutter/material.dart';
import '../models/time_event.dart';

class TimeTracker with ChangeNotifier {
  TimeEvent? _currentEvent;
  final List<TimeEvent> _history = [];

  TimeEvent? get currentEvent => _currentEvent;
  List<TimeEvent> get history => _history.reversed.toList();

  void startEvent({required String category, String name = '', String description = ''}) {
    if (_currentEvent != null) _endCurrentEvent();

    _currentEvent = TimeEvent(
      category: category,
      startTime: DateTime.now(),
      name: name,
      description: description,
    );
    notifyListeners();
  }

  void pauseEvent() {
    if (_currentEvent != null && _currentEvent!.pauseStart == null) {
      _currentEvent!.pauseStart = DateTime.now();
      notifyListeners();
    }
  }

  void resumeEvent() {
    if (_currentEvent?.pauseStart != null) {
      final pauseEnd = DateTime.now();
      _currentEvent!.pausedDuration += pauseEnd.difference(_currentEvent!.pauseStart!);
      _currentEvent!.pauseStart = null;
      notifyListeners();
    }
  }

  void stopCurrentEvent() {
    if (_currentEvent != null) {
      _currentEvent!.endTime = DateTime.now();
      if (_currentEvent!.effectiveDuration.inSeconds >= 10) {
        _history.add(_currentEvent!);
      }
      _currentEvent = null;
      notifyListeners();
    }
  }

  void editEvent(TimeEvent oldEvent, String newName, String newDesc) {
    oldEvent.name = newName;
    oldEvent.description = newDesc;
    notifyListeners();
  }

  void _endCurrentEvent() {
    _currentEvent!.endTime = DateTime.now();
    _history.add(_currentEvent!);
    _currentEvent = null;
  }
}