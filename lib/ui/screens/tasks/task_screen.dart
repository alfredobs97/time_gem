import 'package:flutter/material.dart';
import 'package:time_gem/ui/screens/home/widgets/task_widget.dart';

class TaskScreen extends StatelessWidget {
  const TaskScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
      ),
      body: const TaskWidget(),
    );
  }
}
