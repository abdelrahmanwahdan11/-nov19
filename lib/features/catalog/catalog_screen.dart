import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';

import '../../core/controllers/app_scope.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/utils/dummy_data.dart';
import '../../core/widgets/quick_settings_button.dart';

class CatalogScreen extends StatelessWidget {
  const CatalogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    final controller = AppScope.of(context).catalogController;
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(localization.t('catalog')),
        actions: const [QuickSettingsButton()],
      ),
      body: AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          final items = controller.items;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      decoration: InputDecoration(
                        hintText: localization.t('searchCollections'),
                        prefixIcon: const Icon(IconlyLight.search),
                      ),
                      onChanged: controller.search,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        DropdownButton<String>(
                          value: controller.sort,
                          items: [
                            DropdownMenuItem(value: 'Newest', child: Text(localization.t('newest'))),
                            DropdownMenuItem(value: 'Oldest', child: Text(localization.t('oldest'))),
                            DropdownMenuItem(value: 'A-Z', child: Text(localization.t('az'))),
                          ],
                          onChanged: (value) => controller.sortBy(value ?? 'Newest'),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: Icon(controller.isGrid ? Icons.grid_view : Icons.list),
                          onPressed: controller.toggleView,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: ['All', 'Trip', 'Party', 'Anniversary']
                            .map(
                              (type) => Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: ChoiceChip(
                                  label: Text(type == 'All'
                                      ? localization.t('galleryFilterAll')
                                      : type == 'Trip'
                                          ? localization.t('upcomingTrip')
                                          : type == 'Party'
                                              ? localization.t('partyEvent')
                                              : localization.t('anniversary')),
                                  selected: controller.typeFilter == type,
                                  onSelected: (_) => controller.filterType(type),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        FilterChip(
                          selected: controller.favouriteOnly,
                          label: Text(localization.t('favouriteOnly')),
                          onSelected: controller.toggleFavouriteOnly,
                        ),
                        FilterChip(
                          selected: controller.overBudgetOnly,
                          label: Text(localization.t('overBudgetOnly')),
                          onSelected: controller.toggleOverBudget,
                          avatar: const Icon(IconlyLight.wallet, size: 16),
                        ),
                        FilterChip(
                          selected: controller.dateRange != null,
                          label: Text(controller.dateRange == null
                              ? localization.t('dateFilter')
                              : '${controller.dateRange!.start.month}/${controller.dateRange!.start.day} - ${controller.dateRange!.end.month}/${controller.dateRange!.end.day}'),
                          onSelected: (_) async {
                            final range = await showDateRangePicker(
                              context: context,
                              firstDate: DateTime.now().subtract(const Duration(days: 365)),
                              lastDate: DateTime.now().add(const Duration(days: 365)),
                              initialDateRange: controller.dateRange,
                            );
                            controller.updateDateRange(range);
                          },
                          avatar: const Icon(IconlyLight.calendar, size: 16),
                        ),
                        if (controller.dateRange != null)
                          TextButton.icon(
                            onPressed: () => controller.updateDateRange(null),
                            icon: const Icon(Icons.clear),
                            label: Text(localization.t('clear')),
                          ),
                      ],
                    )
                  ],
                ),
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    controller.search('');
                    await Future<void>.delayed(const Duration(milliseconds: 300));
                  },
                  child: controller.isGrid
                      ? GridView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 0.78,
                          ),
                          itemCount: items.length,
                          itemBuilder: (_, index) => _CatalogCard(collection: items[index]),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          itemCount: items.length,
                          itemBuilder: (_, index) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _CatalogCard(collection: items[index]),
                          ),
                        ),
                ),
              )
            ],
          );
        },
      ),
    );
  }
}

class _CatalogCard extends StatelessWidget {
  const _CatalogCard({required this.collection});
  final CollectionModel collection;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pushNamed('/collection_details', arguments: collection.id),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          color: Theme.of(context).cardTheme.color,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              child: Image.network(collection.images.first, height: 140, width: double.infinity, fit: BoxFit.cover),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(collection.title, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(collection.description, maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(IconlyLight.calendar, size: 16),
                      const SizedBox(width: 4),
                      Text('${collection.date.day}/${collection.date.month}'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _BudgetProgress(collection: collection),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _BudgetProgress extends StatelessWidget {
  const _BudgetProgress({required this.collection});
  final CollectionModel collection;

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    final progress = collection.budgetPlanned == 0
        ? 0.0
        : (collection.budgetUsed / collection.budgetPlanned).clamp(0, 1);
    final remaining = (collection.budgetPlanned - collection.budgetUsed).clamp(0, collection.budgetPlanned);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LinearProgressIndicator(
          value: progress,
          minHeight: 6,
          borderRadius: BorderRadius.circular(8),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Expanded(
              child: Text(
                '${localization.t('budgetUsed')}: ${collection.budgetUsed.toStringAsFixed(0)}',
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ),
            Text(
              '${localization.t('budgetRemaining')}: ${remaining.toStringAsFixed(0)}',
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ],
        )
      ],
    );
  }
}
