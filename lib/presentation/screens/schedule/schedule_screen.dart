import 'package:flutter/material.dart';
import '/presentation/routes/app_router.dart';

class ScheduleScreen extends StatelessWidget {
  const ScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        title: const Text('Schedule'),
      ),
      body: const Center(
        child: Text('Schedule Screen - Implementation in progress'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to Add Schedule Screen
          Navigator.pushNamed(context, Routes.addSchedule);
        },
        tooltip: 'Add Schedule',
        child: const Icon(Icons.add),
      ),
    );
}