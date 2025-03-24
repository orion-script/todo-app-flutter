import 'package:flutter/material.dart';

class TaskInput extends StatefulWidget {
  final Function(String) onTaskAdded;

  const TaskInput({super.key, required this.onTaskAdded});

  @override
  TaskInputState createState() => TaskInputState();
}

class TaskInputState extends State<TaskInput> {
  final TextEditingController _controller = TextEditingController();

  void _submitTask() {
    widget.onTaskAdded(_controller.text);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration(hintText: 'Enter task'),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _submitTask,
          ),
        ],
      ),
    );
  }
}
