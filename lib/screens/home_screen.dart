import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/time_tracker.dart';
import '../widgets/event_card.dart';
import '../widgets/control_buttons.dart';
import '../widgets/category_button.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final tracker = context.watch<TimeTracker>();
    final event = tracker.currentEvent;
    final isPaused = event?.pauseStart != null;

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
          EventCard(event: event, isPaused: isPaused),
          ControlButtons(event: event, isPaused: isPaused),
          _buildQuickStartSection(context),
        ],
      ),
    );
  }

  Widget _buildQuickStartSection(BuildContext context) {
    final tracker = context.watch<TimeTracker>();
    final isEventOngoing = tracker.currentEvent != null; // 判断是否有事件进行中

    return Expanded(
      child: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(16),
        children: [
          CategoryButton(
            category: '学习',
            color: isEventOngoing ? Colors.grey : Colors.blue, // 事件进行中变灰
            icon: Icons.school,
            onPressed: isEventOngoing ? null : () => _startQuickEvent(context, '学习'), // 禁用点击
          ),
          CategoryButton(
            category: '休息',
            color: isEventOngoing ? Colors.grey : Colors.green,
            icon: Icons.free_breakfast,
            onPressed: isEventOngoing ? null : () => _startQuickEvent(context, '休息'),
          ),
          _buildCustomEventButton(context, isEventOngoing),
        ],
      ),
    );
  }

  // 自定义事件按钮（拆分为独立组件）
  Widget _buildCustomEventButton(BuildContext context, bool isEventOngoing) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: isEventOngoing ? Colors.grey : Colors.purple, // 事件进行中变灰
          foregroundColor: Colors.white,
        ),
        icon: const Icon(Icons.add),
        label: const Text('自定义'),
        onPressed: isEventOngoing ? null : () => _showCustomEventDialog(context), // 禁用点击
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

  // 历史记录列表（可考虑拆分为独立组件）
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

  // 持续时间格式化方法
  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    return '${hours}h ${minutes}m';
  }

  // 快速开始事件
  void _startQuickEvent(BuildContext context, String category) {
    context.read<TimeTracker>().startEvent(category: category);
  }

  // 显示自定义事件对话框
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