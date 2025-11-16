import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';

import '../../core/controllers/app_scope.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/widgets/quick_settings_button.dart';
import 'widgets/task_composer.dart';

class TaskScheduleScreen extends StatelessWidget {
  const TaskScheduleScreen({super.key, required this.collectionId});

  final String collectionId;

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    final controller = AppScope.of(context).collectionsController;
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(localization.t('fullSchedule')),
        actions: [
          IconButton(
            icon: const Icon(IconlyLight.plus),
            onPressed: () => showTaskComposer(context, collectionId),
          ),
          const QuickSettingsButton(),
        ],
      ),
      body: AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          final grouped = controller.groupedTasks(collectionId);
          if (grouped.isEmpty) {
            return Center(child: Text(localization.t('tasksEmpty')));
          }
          return ListView(
            padding: const EdgeInsets.all(24),
            children: grouped.entries.map((entry) {
              final date = entry.key;
              final tasks = entry.value;
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  color: Theme.of(context).cardTheme.color,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '${date.day}/${date.month}/${date.year}',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () {
                            for (final task in tasks) {
                              controller.toggleTask(collectionId, task.id, true);
                            }
                          },
                          child: Text(localization.t('markAllDone')),
                        )
                      ],
                    ),
                    const SizedBox(height: 12),
                    ...tasks.map(
                      (task) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Checkbox(
                          value: task.completed,
                          onChanged: (value) => controller.toggleTask(collectionId, task.id, value ?? false),
                        ),
                        title: Text(task.title),
                        subtitle: Text(task.subtitle),
                        trailing: Chip(
                          label: Text('${task.date.hour.toString().padLeft(2, '0')}:${task.date.minute.toString().padLeft(2, '0')}'),
                        ),
                      ),
                    )
                  ],
                ),
              );
            }).toList(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showTaskComposer(context, collectionId),
        icon: const Icon(IconlyLight.paper_plus),
        label: Text(localization.t('createTask')),
      ),
    );
  }
}
