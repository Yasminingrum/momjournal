import 'package:flutter/material.dart';
import '/presentation/routes/app_router.dart';

class JournalScreen extends StatelessWidget {
  const JournalScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        title: const Text('Journal'),
      ),
      body: const Center(
        child: Text('Journal Screen - Implementation in progress'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to Add Journal Screen
          Navigator.pushNamed(context, Routes.addJournal);
        },
        tooltip: 'Add Journal',
        child: const Icon(Icons.edit),
      ),
    );
}