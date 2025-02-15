import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

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
      title: '高级时间管理',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomePage(),
      routes: {
        '/edit': (context) => const EventEditPage(),
      },
    );
  }
}

// 增强版事件模型
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

  // 获取实际持续时间（排除暂停时间）
  Duration get effectiveDuration {
    final base = endTime?.difference(startTime) ?? Duration.zero;
    return base - pausedDuration;
  }

  // 格式化时间显示
  String get timeRange {
    final end = endTime ?? DateTime.now();
    return '${DateFormat('HH:mm').format(startTime)} - ${DateFormat('HH:mm').format(end)}';
  }
}

class TimeTracker with ChangeNotifier {
  TimeEvent? _currentEvent;
  final List<TimeEvent> _history = [];

  TimeEvent? get currentEvent => _currentEvent;
  List<TimeEvent> get history => _history.reversed.toList();

  // 开始新事件（带最小时间校验）
  void startEvent({required String category, String name = '', String description = ''}) {
    if (_currentEvent != null) {
      _endCurrentEvent();
    }

    _currentEvent = TimeEvent(
      category: category,
      startTime: DateTime.now(),
      name: name,
      description: description,
    );
    notifyListeners();
  }

  // 暂停事件
  void pauseEvent() {
    if (_currentEvent != null && _currentEvent!.pauseStart == null) {
      _currentEvent!.pauseStart = DateTime.now();
      notifyListeners();
    }
  }

  // 恢复事件
  void resumeEvent() {
    if (_currentEvent?.pauseStart != null) {
      final pauseEnd = DateTime.now();
      _currentEvent!.pausedDuration += pauseEnd.difference(_currentEvent!.pauseStart!);
      _currentEvent!.pauseStart = null;
      notifyListeners();
    }
  }

  // 结束当前事件
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

  // 编辑事件
  void editEvent(TimeEvent oldEvent, String newName, String newDesc) {
    oldEvent.name = newName;
    oldEvent.description = newDesc;
    notifyListeners();
  }

  // 私有方法：真正结束事件
  void _endCurrentEvent() {
    _currentEvent!.endTime = DateTime.now();
    _history.add(_currentEvent!);
    _currentEvent = null;
  }
}

// 主界面
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('时间追踪'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => _showHistory(context),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildCurrentEventCard(context),
          _buildControlButtons(context),
          _buildQuickStartButtons(context),
        ],
      ),
    );
  }

  // 当前事件卡片
  Widget _buildCurrentEventCard(BuildContext context) {
    final event = context.watch<TimeTracker>().currentEvent;
    final isPaused = event?.pauseStart != null;

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
                    Text(event.timeRange),
                    Text('持续时间: ${_formatDuration(event.effectiveDuration)}'),
                    if (event.description.isNotEmpty)
                      Text(event.description),
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

  // 控制按钮组
  Widget _buildControlButtons(BuildContext context) {
    final tracker = context.read<TimeTracker>();
    final event = tracker.currentEvent;
    final isPaused = event?.pauseStart != null;

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

  // 快速开始按钮
  Widget _buildQuickStartButtons(BuildContext context) {
    return Expanded(
      child: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(16),
        children: [
          _buildCategoryButton(context, '学习', Colors.blue, Icons.school),
          _buildCategoryButton(context, '休息', Colors.green, Icons.free_breakfast),
          _buildCustomEventButton(context),
        ],
      ),
    );
  }

  // 分类按钮
  Widget _buildCategoryButton(BuildContext context, String category, Color color, IconData icon) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
        ),
        icon: Icon(icon),
        label: Text(category),
        onPressed: () => _startQuickEvent(context, category),
      ),
    );
  }

  // 自定义事件按钮
  Widget _buildCustomEventButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.purple,
          foregroundColor: Colors.white,
        ),
        icon: const Icon(Icons.add),
        label: const Text('自定义'),
        onPressed: () => _showCustomEventDialog(context),
      ),
    );
  }

  // 显示历史记录
  void _showHistory(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => _buildHistoryList(context),
    );
  }

  // 历史记录列表
  Widget _buildHistoryList(BuildContext context) {
    final history = context.watch<TimeTracker>().history;

    return ListView.builder(
      itemCount: history.length,
      itemBuilder: (context, index) {
        final event = history[index];
        return ListTile(
          title: Text(event.name.isNotEmpty ? event.name : event.category),
          subtitle: Text(event.timeRange),
          trailing: Text(_formatDuration(event.effectiveDuration)),
          onTap: () => Navigator.pushNamed(
            context,
            '/edit',
            arguments: event,
          ),
        );
      },
    );
  }

  // 其他辅助方法
  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    return '${hours}h ${minutes}m';
  }

  void _startQuickEvent(BuildContext context, String category) {
    context.read<TimeTracker>().startEvent(category: category);
  }

  void _showCustomEventDialog(BuildContext context) {
    final nameController = TextEditingController();
    final descController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('创建自定义事件'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: nameController,
              decoration: const InputDecoration(labelText: '事件名称'),
            ),
            TextFormField(
              controller: descController,
              decoration: const InputDecoration(labelText: '描述'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<TimeTracker>().startEvent(
                category: '自定义',
                name: nameController.text,
                description: descController.text,
              );
              Navigator.pop(context);
            },
            child: const Text('开始'),
          ),
        ],
      ),
    );
  }
}

// 事件编辑页面
class EventEditPage extends StatelessWidget {
  const EventEditPage({super.key});

  @override
  Widget build(BuildContext context) {
    final event = ModalRoute.of(context)!.settings.arguments as TimeEvent;
    final nameController = TextEditingController(text: event.name);
    final descController = TextEditingController(text: event.description);

    return Scaffold(
      appBar: AppBar(title: const Text('编辑事件')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextFormField(
              controller: nameController,
              decoration: const InputDecoration(labelText: '事件名称'),
            ),
            TextFormField(
              controller: descController,
              decoration: const InputDecoration(labelText: '描述'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                context.read<TimeTracker>().editEvent(
                  event,
                  nameController.text,
                  descController.text,
                );
                Navigator.pop(context);
              },
              child: const Text('保存修改'),
            ),
          ],
        ),
      ),
    );
  }
}