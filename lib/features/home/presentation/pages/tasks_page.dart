import 'package:flutter/material.dart';

class TasksPage extends StatelessWidget {
  const TasksPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.list,
            size: 48,
          ),
          SizedBox(height: 16),
          Text(
            '任务列表',
            style: TextStyle(fontSize: 24),
          ),
        ],
      ),
    );
  }
}