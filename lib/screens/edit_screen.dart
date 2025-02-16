import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/time_event.dart';
import '../providers/time_tracker.dart';

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