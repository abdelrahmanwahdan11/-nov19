import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';

import '../../../core/controllers/app_scope.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/utils/dummy_data.dart';

Future<void> showTaskComposer(BuildContext context, String collectionId) async {
  final localization = AppLocalizations.of(context);
  final controller = AppScope.of(context).collectionsController;
  final titleController = TextEditingController();
  final subtitleController = TextEditingController();
  final assigneeController = TextEditingController();
  DateTime selectedDate = DateTime.now();
  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
    ),
    builder: (ctx) {
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          left: 24,
          right: 24,
          top: 24,
        ),
        child: StatefulBuilder(
          builder: (context, setModalState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Icon(IconlyLight.paper_plus, color: Theme.of(context).primaryColor),
                    const SizedBox(width: 12),
                    Text(localization.t('createTask'), style: Theme.of(context).textTheme.titleLarge),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(labelText: localization.t('taskTitle')),
                ),
                TextField(
                  controller: subtitleController,
                  decoration: InputDecoration(labelText: localization.t('taskSubtitle')),
                ),
                TextField(
                  controller: assigneeController,
                  decoration: InputDecoration(labelText: localization.t('assignee')),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('${localization.t('dueDate')}: ${_formatDate(selectedDate)}'),
                  trailing: TextButton(
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime.now().subtract(const Duration(days: 30)),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (picked != null) {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.fromDateTime(selectedDate),
                        );
                        if (time != null) {
                          setModalState(() {
                            selectedDate = DateTime(picked.year, picked.month, picked.day, time.hour, time.minute);
                          });
                        }
                      }
                    },
                    child: Text(localization.t('dueDate')),
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () {
                    controller.addTask(
                      collectionId,
                      TaskModel(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        title: titleController.text.isEmpty ? localization.t('newTask') : titleController.text,
                        subtitle:
                            subtitleController.text.isEmpty ? localization.t('localAddition') : subtitleController.text,
                        date: selectedDate,
                        assignee: assigneeController.text.isEmpty ? 'Nuviq' : assigneeController.text,
                      ),
                    );
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(localization.t('taskSaved'))),
                    );
                  },
                  icon: const Icon(IconlyLight.send),
                  label: Text(localization.t('createTask')),
                )
              ],
            );
          },
        ),
      );
    },
  );
}

String _formatDate(DateTime date) =>
    '${date.day}/${date.month} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
