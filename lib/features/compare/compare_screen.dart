import 'package:flutter/material.dart';

import '../../core/controllers/app_scope.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/utils/dummy_data.dart';
import '../../core/widgets/quick_settings_button.dart';

class CompareScreen extends StatelessWidget {
  const CompareScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    final controller = AppScope.of(context).collectionsController;
    final selected = controller.compareSelection.map(
      (id) => DummyData.collections.firstWhere((element) => element.id == id),
    );
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(localization.t('compareTitle')),
        actions: const [QuickSettingsButton()],
      ),
      body: selected.isEmpty
          ? Center(child: Text(localization.t('tasksEmpty')))
          : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.all(24),
              child: Row(
                children: selected
                    .map((collection) => AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: 260,
                          margin: const EdgeInsets.only(right: 16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(28),
                            color: Theme.of(context).cardTheme.color,
                            boxShadow: [
                              BoxShadow(
                                color: Theme.of(context).primaryColor.withOpacity(0.15),
                                blurRadius: 18,
                                offset: const Offset(0, 12),
                              )
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(collection.title, style: Theme.of(context).textTheme.titleMedium),
                              const SizedBox(height: 8),
                              _CompareRow(label: localization.t('dateRange'), value: '${collection.date.day}/${collection.date.month}'),
                              _CompareRow(label: localization.t('location'), value: collection.location),
                              _CompareRow(label: localization.t('favourites'), value: collection.isFavourite ? '★' : '☆'),
                              _CompareRow(label: localization.t('tasks'), value: collection.tasks.length.toString()),
                              _CompareRow(label: localization.t('media'), value: collection.images.length.toString()),
                            ],
                          ),
                        ))
                    .toList(),
              ),
            ),
    );
  }
}

class _CompareRow extends StatelessWidget {
  const _CompareRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(child: Text(label, style: Theme.of(context).textTheme.bodySmall)),
          Text(value, style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }
}
