import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/time_event.dart';
import '../providers/time_tracker.dart';

class EventEditPage extends StatefulWidget {
  const EventEditPage({super.key});

  @override
  State<EventEditPage> createState() => _EventEditPageState();
}

class _EventEditPageState extends State<EventEditPage> {
  late final FocusNode _nameFocusNode;
  late final FocusNode _descFocusNode;

  @override
  void initState() {
    super.initState();
    _nameFocusNode = FocusNode();
    _descFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _nameFocusNode.dispose();
    _descFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final event = ModalRoute.of(context)!.settings.arguments as TimeEvent;
    final nameController = TextEditingController(text: event.name);
    final descController = TextEditingController(text: event.description);

    return GestureDetector(
      onTap: () {
        _nameFocusNode.unfocus();
        _descFocusNode.unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('编辑事件'),
          elevation: 0,
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
        backgroundColor: Colors.grey[100],
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      TextFormField(
                        focusNode: _nameFocusNode,
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: '事件名称',
                          border: InputBorder.none,
                        ),
                        style: const TextStyle(fontSize: 18),
                      ),
                      const Divider(),
                      TextFormField(
                        focusNode: _descFocusNode,
                        controller: descController,
                        decoration: const InputDecoration(
                          labelText: '描述',
                          border: InputBorder.none,
                        ),
                        style: const TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  context.read<TimeTracker>().editEvent(
                    event,
                    nameController.text,
                    descController.text,
                  );
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  textStyle: const TextStyle(fontSize: 18),
                ),
                child: const Text('保存'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}