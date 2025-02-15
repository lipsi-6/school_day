import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => TimeTracker(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '校园时间管理',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomePage(),
    );
  }
}

class TimeTracker with ChangeNotifier {
  TimeEvent? _currentEvent;
  final List<TimeEvent> _history = [];

  TimeEvent? get currentEvent => _currentEvent;
  List<TimeEvent> get history => _history;

  void startEvent(String category) {
    if (_currentEvent != null) {
      _currentEvent!.endTime = DateTime.now();
      _history.add(_currentEvent!);
    }
    _currentEvent = TimeEvent(category: category, startTime: DateTime.now());
    notifyListeners();
  }

  void stopCurrentEvent() {
    if (_currentEvent != null) {
      _currentEvent!.endTime = DateTime.now();
      _history.add(_currentEvent!);
      _currentEvent = null;
      notifyListeners();
    }
  }
}

class TimeEvent {
  final String category;
  final DateTime startTime;
  DateTime? endTime;

  TimeEvent({
    required this.category,
    required this.startTime,
  });

  String get durationString {
    if (endTime == null) return '进行中';
    final duration = endTime!.difference(startTime);
    return '${duration.inMinutes}分${duration.inSeconds % 60}秒';
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('我的时间记录')),
      body: Column(
        children: [
          _buildCurrentEvent(context),
          _buildTimeChart(context),
          _buildHistoryList(context),
        ],
      ),
      floatingActionButton: _buildActionButtons(context),
    );
  }

  Widget _buildCurrentEvent(BuildContext context) {
    final event = context.watch<TimeTracker>().currentEvent;
    return Card(
      child: ListTile(
        title: Text(event?.category ?? '暂无进行中的事件'),
        subtitle: Text(event?.durationString ?? '点击下方按钮开始记录'),
      ),
    );
  }

  Widget _buildTimeChart(BuildContext context) {
    final events = context.watch<TimeTracker>().history;
    final Map<String, double> categoryDuration = {};

    for (var event in events) {
      if (event.endTime != null) {
        final duration = event.endTime!.difference(event.startTime).inSeconds;
        categoryDuration.update(
          event.category,
              (value) => value + duration,
          ifAbsent: () => duration.toDouble(),
        );
      }
    }

    return SizedBox(
      height: 200,
      child: PieChart(
        PieChartData(
          sections: categoryDuration.entries.map((e) {
            return PieChartSectionData(
              value: e.value,
              color: _getCategoryColor(e.key),
              title: '${e.key}\n${(e.value / 60).toStringAsFixed(1)}分钟',
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildHistoryList(BuildContext context) {
    final history = context.watch<TimeTracker>().history;
    return Expanded(
      child: ListView.builder(
        itemCount: history.length,
        itemBuilder: (context, index) {
          final event = history.reversed.toList()[index];
          return ListTile(
            leading: Icon(Icons.access_time, color: _getCategoryColor(event.category)),
            title: Text(event.category),
            subtitle: Text(DateFormat('HH:mm').format(event.startTime)),
            trailing: Text(event.durationString),
          );
        },
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    final tracker = context.read<TimeTracker>();
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        FloatingActionButton(
          heroTag: 'study',
          onPressed: () => tracker.startEvent('学习'),
          backgroundColor: _getCategoryColor('学习'),
          child: const Icon(Icons.school),
        ),
        const SizedBox(width: 10),
        FloatingActionButton(
          heroTag: 'rest',
          onPressed: () => tracker.startEvent('休息'),
          backgroundColor: _getCategoryColor('休息'),
          child: const Icon(Icons.free_breakfast),
        ),
        const SizedBox(width: 10),
        FloatingActionButton(
          heroTag: 'stop',
          onPressed: tracker.stopCurrentEvent,
          child: const Icon(Icons.stop),
        ),
      ],
    );
  }

  Color _getCategoryColor(String category) {
    final colors = {
      '学习': Colors.blue,
      '休息': Colors.green,
      '娱乐': Colors.orange,
      '运动': Colors.red,
    };
    return colors[category] ?? Colors.grey;
  }
}