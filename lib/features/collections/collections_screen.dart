import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';

import '../../core/controllers/app_scope.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/utils/dummy_data.dart';
import '../../core/utils/itinerary_utils.dart';
import '../../core/widgets/skeleton_box.dart';

class CollectionsScreen extends StatefulWidget {
  const CollectionsScreen({super.key});

  @override
  State<CollectionsScreen> createState() => _CollectionsScreenState();
}

class _CollectionsScreenState extends State<CollectionsScreen> {
  final _scrollController = ScrollController();
  final List<String> tabs = const ['All', 'Trip', 'Party', 'Anniversary'];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final controller = AppScope.of(context).collectionsController;
    if (_scrollController.position.pixels > _scrollController.position.maxScrollExtent - 200) {
      controller.loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    final controllers = AppScope.of(context);
    final collectionsController = controllers.collectionsController;
    final labels = {
      'All': localization.t('galleryFilterAll'),
      'Trip': localization.t('upcomingTrip'),
      'Party': localization.t('partyEvent'),
      'Anniversary': localization.t('anniversary'),
    };
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(localization.t('collections')),
        actions: [
          IconButton(
            icon: const Icon(IconlyLight.setting),
            onPressed: () => Navigator.of(context).pushNamed('/settings'),
          )
        ],
      ),
      body: RefreshIndicator(
        onRefresh: collectionsController.refresh,
        child: AnimatedBuilder(
          animation: collectionsController,
          builder: (context, _) {
            final items = collectionsController.visible;
            return ListView(
              controller: _scrollController,
              padding: const EdgeInsets.all(24),
              children: [
                TextField(
                  decoration: InputDecoration(
                    hintText: localization.t('searchCollections'),
                    prefixIcon: const Icon(IconlyLight.search),
                    suffixIcon: IconButton(
                      icon: const Icon(IconlyLight.filter),
                      onPressed: () => Navigator.of(context).pushNamed('/catalog'),
                    ),
                  ),
                  onChanged: collectionsController.search,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: collectionsController.sortOption,
                        decoration: InputDecoration(labelText: localization.t('sort')),
                        items: [
                          DropdownMenuItem(value: 'Newest', child: Text(localization.t('newest'))),
                          DropdownMenuItem(value: 'Oldest', child: Text(localization.t('oldest'))),
                          DropdownMenuItem(value: 'A-Z', child: Text(localization.t('az'))),
                        ],
                        onChanged: (value) => collectionsController.sortBy(value ?? 'Newest'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    TextButton(
                      onPressed: collectionsController.resetFilters,
                      child: Text(localization.t('clear')),
                    )
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  children: [
                    FilterChip(
                      label: Text(localization.t('favouriteOnly')),
                      selected: collectionsController.favouriteOnly,
                      onSelected: collectionsController.toggleFavouriteFilter,
                    ),
                    FilterChip(
                      label: Text(collectionsController.dateRange == null
                          ? localization.t('dateFilter')
                          : '${collectionsController.dateRange!.start.month}/${collectionsController.dateRange!.start.day} - '
                              '${collectionsController.dateRange!.end.month}/${collectionsController.dateRange!.end.day}'),
                      selected: collectionsController.dateRange != null,
                      onSelected: (_) async {
                        final range = await showDateRangePicker(
                          context: context,
                          firstDate: DateTime.now().subtract(const Duration(days: 365)),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                          initialDateRange: collectionsController.dateRange,
                        );
                        collectionsController.updateDateRange(range);
                      },
                    )
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _StatPill(
                      label: localization.t('activeEvents'),
                      value: collectionsController.activeCollections.toString(),
                      icon: IconlyBold.discovery,
                    ),
                    const SizedBox(width: 12),
                    _StatPill(
                      label: localization.t('tasksDueSoon'),
                      value: collectionsController.upcomingTasksCount.toString(),
                      icon: IconlyBold.time_circle,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  children: tabs
                      .map((type) => ChoiceChip(
                            label: Text(labels[type] ?? type),
                            selected: collectionsController.typeFilter == type,
                            onSelected: (_) => collectionsController.filterByType(type),
                          ))
                      .toList(),
                ),
                const SizedBox(height: 24),
                if (collectionsController.isLoading)
                  Column(
                    children: const [
                      SkeletonBox(height: 120),
                      SizedBox(height: 12),
                      SkeletonBox(height: 120),
                    ],
                  )
                else ...items.map((collection) => _CollectionTile(collection: collection)),
                if (collectionsController.isPaginating)
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                const SizedBox(height: 80),
                ElevatedButton.icon(
                  onPressed: collectionsController.compareSelection.isNotEmpty
                      ? () => Navigator.of(context).pushNamed('/compare')
                      : null,
                  icon: const Icon(IconlyLight.paper_negative),
                  label: Text(localization.t('compare')),
                )
              ],
            );
          },
        ),
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  const _StatPill({required this.label, required this.value, required this.icon});

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: Theme.of(context).cardTheme.color,
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: Theme.of(context).primaryColor.withOpacity(0.2),
              child: Icon(icon, color: Theme.of(context).primaryColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(value, style: Theme.of(context).textTheme.titleLarge),
                  Text(label, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CollectionTile extends StatelessWidget {
  const _CollectionTile({required this.collection});
  final CollectionModel collection;

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context).collectionsController;
    final localization = AppLocalizations.of(context);
    final progress = collection.budgetPlanned == 0
        ? 0.0
        : (collection.budgetUsed / collection.budgetPlanned).clamp(0, 1);
    final overBudget = collection.budgetUsed > collection.budgetPlanned;
    final nextSlot = controller.nextItinerarySlot(collection.id);
    final timeLabel = nextSlot == null
        ? null
        : MaterialLocalizations.of(context).formatTimeOfDay(nextSlot.slot.time);
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        color: Theme.of(context).cardTheme.color,
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Image.network(collection.images.first, width: 80, height: 80, fit: BoxFit.cover),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(collection.title, style: Theme.of(context).textTheme.titleMedium),
                Text(collection.description, maxLines: 2, overflow: TextOverflow.ellipsis),
                Text(collection.location, style: Theme.of(context).textTheme.labelMedium),
                const SizedBox(height: 6),
                LinearProgressIndicator(
                  value: progress,
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(8),
                  color: overBudget ? Colors.redAccent : Theme.of(context).primaryColor,
                  backgroundColor: Theme.of(context).primaryColor.withOpacity(0.15),
                ),
                const SizedBox(height: 4),
                Text(
                  '${collection.budgetUsed.toStringAsFixed(0)} / ${collection.budgetPlanned.toStringAsFixed(0)}',
                  style: Theme.of(context)
                      .textTheme
                      .labelSmall
                      ?.copyWith(color: overBudget ? Colors.redAccent : null),
                ),
                if (nextSlot != null) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(IconlyLight.calendar, size: 16),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          '${timeLabel ?? ''} · ${nextSlot.slot.title}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    children: [
                      Chip(
                        label: Text(localizedItineraryTag(nextSlot.slot.tag, localization)),
                        backgroundColor: Theme.of(context).primaryColor.withOpacity(0.15),
                      ),
                      Chip(
                        label: Text(localization.t('itineraryNextSlot')),
                        backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                      ),
                    ],
                  ),
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: TextButton(
                      onPressed: () => Navigator.of(context)
                          .pushNamed('/collection_itinerary', arguments: collection.id),
                      child: Text(localization.t('openItinerary')),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Column(
            children: [
              IconButton(
                icon: Icon(collection.isFavourite ? IconlyBold.heart : IconlyLight.heart),
                onPressed: () => controller.toggleFavourite(collection.id),
              ),
              Checkbox(
                value: controller.compareSelection.contains(collection.id),
                onChanged: (_) => controller.toggleCompare(collection.id),
              ),
            ],
          )
        ],
      ),
    );
  }
}
