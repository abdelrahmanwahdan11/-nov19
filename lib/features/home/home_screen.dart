import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';

import '../../core/constants/app_assets.dart';
import '../../core/controllers/app_scope.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/utils/dummy_data.dart';
import '../../core/utils/itinerary_utils.dart';
import '../../core/widgets/skeleton_box.dart';
import 'widgets/notifications_sheet.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    final controllers = AppScope.of(context);
    final heroCollection = DummyData.collections.first;
    final listenable = Listenable.merge([
      controllers.collectionsController,
      controllers.notificationsController,
    ]);
    return AnimatedBuilder(
      animation: listenable,
      builder: (context, _) {
        final stats = [
          (localization.t('activeEvents'), controllers.collectionsController.activeCollections.toString(), IconlyBold.ticket),
          (localization.t('tasksDueSoon'), controllers.collectionsController.upcomingTasksCount.toString(), IconlyBold.time_circle),
          (localization.t('favouriteCollectionsShort'), controllers.collectionsController.favouriteCount.toString(),
              IconlyBold.heart),
        ];
        final timeline = controllers.collectionsController.upcomingTimeline(4);
        final highlights = controllers.collectionsController.recentJournalEntries();
        final totalBudgetPlanned = controllers.collectionsController.totalBudgetPlanned;
        final totalBudgetUsed = controllers.collectionsController.totalBudgetUsed;
        final budgetProgress = totalBudgetPlanned == 0
            ? 0.0
            : (totalBudgetUsed / totalBudgetPlanned).clamp(0, 1);
        final milestonePeek = controllers.collectionsController.upcomingMilestones(3);
        final itineraryPeek = controllers.collectionsController.upcomingItinerarySlots(4);
        final unread = controllers.notificationsController.unreadCount;
        return RefreshIndicator(
          onRefresh: controllers.collectionsController.refresh,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 48, 24, 120),
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          localization.t('goodMorning'),
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white70),
                        ),
                        Text(
                          localization.t('appName'),
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => _openNotifications(context),
                    icon: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        const Icon(IconlyLight.notification),
                        if (unread > 0)
                          Positioned(
                            right: -4,
                            top: -4,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text('$unread', style: const TextStyle(color: Colors.white, fontSize: 10)),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    radius: 26,
                    backgroundImage: NetworkImage(AppAssets.profile),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: () => Navigator.of(context).pushNamed('/collection_details', arguments: heroCollection.id),
                child: Hero(
                  tag: heroCollection.id,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(36),
                      gradient: LinearGradient(
                        colors: [Theme.of(context).primaryColor, Theme.of(context).primaryColor.withOpacity(0.6)],
                      ),
                    ),
                    height: 260,
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(32),
                            child: Image.network(heroCollection.images.first, fit: BoxFit.cover),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(32),
                            gradient: LinearGradient(
                              colors: [Colors.black.withOpacity(0.5), Colors.transparent],
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 20,
                          left: 20,
                          right: 20,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                heroCollection.title,
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                              Text(heroCollection.description,
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child:
                        Text(localization.t('insightsTitle'), style: Theme.of(context).textTheme.titleMedium),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pushNamed('/insights'),
                    child: Text(localization.t('openInsights')),
                  )
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 110,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (_, index) {
                    final stat = stats[index];
                    return _InsightCard(
                      label: stat.$1,
                      value: stat.$2,
                      icon: stat.$3,
                    );
                  },
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemCount: stats.length,
                ),
              ),
              const SizedBox(height: 24),
              _BudgetHealthCard(
                progress: budgetProgress,
                planned: totalBudgetPlanned,
                used: totalBudgetUsed,
                localization: localization,
              ),
              const SizedBox(height: 24),
              Text(localization.t('autoPlanner'), style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              SizedBox(
                height: 120,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _QuickCard(title: localization.t('upcomingTrip'), icon: IconlyLight.paper_plus),
                    _QuickCard(title: localization.t('partyEvent'), icon: IconlyLight.game),
                    _QuickCard(title: localization.t('anniversary'), icon: IconlyLight.heart),
                    _QuickCard(title: localization.t('createManual'), icon: IconlyLight.edit),
                  ],
                ),
              ),
              if (timeline.isNotEmpty) ...[
                const SizedBox(height: 24),
                Text(localization.t('timelineFocus'), style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 12),
                Column(
                  children: timeline
                      .map(
                        (entry) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _TimelineTile(collection: entry.collection, task: entry.task),
                        ),
                      )
                      .toList(),
                ),
              ],
              if (itineraryPeek.isNotEmpty) ...[
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                        child: Text(localization.t('itineraryPeek'),
                            style: Theme.of(context).textTheme.titleMedium)),
                    TextButton(
                      onPressed: () => Navigator.of(context)
                          .pushNamed('/collection_itinerary', arguments: itineraryPeek.first.collection.id),
                      child: Text(localization.t('openItinerary')),
                    )
                  ],
                ),
                const SizedBox(height: 12),
                Column(
                  children: itineraryPeek
                      .map((entry) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _ItinerarySnippetCard(entry: entry),
                          ))
                      .toList(),
                ),
              ],
              if (highlights.isNotEmpty) ...[
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: Text(localization.t('latestHighlights'),
                          style: Theme.of(context).textTheme.titleMedium),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context)
                          .pushNamed('/collection_journal', arguments: highlights.first.collection.id),
                      child: Text(localization.t('openJournal')),
                    )
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 210,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: highlights.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (_, index) {
                      final item = highlights[index];
                      return _JournalHighlightCard(entry: item);
                    },
                  ),
                ),
              ],
              if (milestonePeek.isNotEmpty) ...[
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(child: Text(localization.t('nextMilestones'), style: Theme.of(context).textTheme.titleMedium)),
                    TextButton(
                      onPressed: () => Navigator.of(context)
                          .pushNamed('/collection_roadmap', arguments: milestonePeek.first.collection.id),
                      child: Text(localization.t('openRoadmap')),
                    )
                  ],
                ),
                const SizedBox(height: 12),
                Column(
                  children: milestonePeek
                      .map(
                        (entry) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _MilestoneTile(entry: entry),
                        ),
                      )
                      .toList(),
                ),
              ],
              const SizedBox(height: 24),
              Text(localization.t('collections'), style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              if (controllers.collectionsController.isLoading)
                Column(
                  children: const [
                    SkeletonBox(),
                    SizedBox(height: 12),
                    SkeletonBox(),
                  ],
                )
              else
                Column(
                  children: controllers.collectionsController.visible
                      .take(3)
                      .map((collection) => Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: _CollectionCard(collection: collection),
                          ))
                      .toList(),
                ),
            ],
          ),
        );
      },
    );
  }

  void _openNotifications(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const NotificationsSheet(),
    );
  }
}

class _QuickCard extends StatelessWidget {
  const _QuickCard({required this.title, required this.icon});
  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        color: Theme.of(context).cardTheme.color,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Theme.of(context).primaryColor),
          const Spacer(),
          Text(title, style: Theme.of(context).textTheme.titleSmall),
        ],
      ),
    );
  }
}

class _CollectionCard extends StatelessWidget {
  const _CollectionCard({required this.collection});

  final CollectionModel collection;

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    final controller = AppScope.of(context).collectionsController;
    final totalTasks = collection.tasks.length;
    final completed = collection.tasks.where((task) => task.completed).length;
    final progress = totalTasks == 0 ? 0.0 : completed / totalTasks;
    final nextSlot = controller.nextItinerarySlot(collection.id);
    final timeLabel = nextSlot == null
        ? null
        : MaterialLocalizations.of(context).formatTimeOfDay(nextSlot.slot.time);
    return GestureDetector(
      onTap: () => Navigator.of(context).pushNamed('/collection_details', arguments: collection.id),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          color: Theme.of(context).cardTheme.color,
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Image.network(collection.images.first, width: 90, height: 90, fit: BoxFit.cover),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(collection.title, style: Theme.of(context).textTheme.titleMedium),
                  Text(collection.location, style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(height: 6),
                  Text(
                    collection.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  if (totalTasks > 0)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        LinearProgressIndicator(value: progress, minHeight: 6, borderRadius: BorderRadius.circular(8)),
                        const SizedBox(height: 4),
                        Text('${(progress * 100).round()}% ${AppLocalizations.of(context).t('tasks')}'),
                      ],
                    ),
                  if (nextSlot != null) ...[
                    const SizedBox(height: 8),
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
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: TextButton(
                        onPressed: () => Navigator.of(context)
                            .pushNamed('/collection_itinerary', arguments: collection.id),
                        child: Text(localization.t('openItinerary')),
                      ),
                    )
                  ],
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _InsightCard extends StatelessWidget {
  const _InsightCard({required this.label, required this.value, required this.icon});

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        color: Theme.of(context).cardTheme.color,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Theme.of(context).primaryColor),
          const Spacer(),
          Text(value, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _TimelineTile extends StatelessWidget {
  const _TimelineTile({required this.collection, required this.task});

  final CollectionModel collection;
  final TaskModel task;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        color: Theme.of(context).cardTheme.color,
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Theme.of(context).primaryColor.withOpacity(0.2),
            child: const Icon(IconlyLight.time_circle),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(task.title, style: Theme.of(context).textTheme.titleMedium),
                Text(collection.title, style: Theme.of(context).textTheme.bodySmall),
                Text('${AppLocalizations.of(context).t('dueDate')}: ${_formatTime(task.date)}',
                    style: Theme.of(context).textTheme.labelSmall),
              ],
            ),
          ),
          Chip(label: Text(task.assignee)),
        ],
      ),
    );
  }

  String _formatTime(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '${date.day}/${date.month} $hour:$minute';
  }
}

class _ItinerarySnippetCard extends StatelessWidget {
  const _ItinerarySnippetCard({required this.entry});

  final ({
    CollectionModel collection,
    ItineraryDayModel day,
    ItinerarySlotModel slot,
    DateTime schedule,
  }) entry;

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    final timeLabel = MaterialLocalizations.of(context).formatTimeOfDay(entry.slot.time);
    final dateLabel = MaterialLocalizations.of(context).formatMediumDate(entry.day.date);
    return GestureDetector(
      onTap: () => Navigator.of(context).pushNamed('/collection_itinerary', arguments: entry.collection.id),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          color: Theme.of(context).cardTheme.color,
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(entry.collection.images.first),
              radius: 28,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(entry.collection.title, style: Theme.of(context).textTheme.titleMedium),
                  Text('${timeLabel} · ${entry.slot.title}'),
                  Text(dateLabel, style: Theme.of(context).textTheme.labelSmall),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 8,
                    children: [
                      Chip(
                        label: Text(localizedItineraryTag(entry.slot.tag, localization)),
                        backgroundColor: Theme.of(context).primaryColor.withOpacity(0.15),
                      ),
                      Chip(
                        label: Text(localization.t('itineraryUpcoming')),
                        backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                      ),
                    ],
                  )
                ],
              ),
            ),
            const Icon(IconlyLight.arrow_right_2),
          ],
        ),
      ),
    );
  }
}

class _BudgetHealthCard extends StatelessWidget {
  const _BudgetHealthCard({
    required this.progress,
    required this.planned,
    required this.used,
    required this.localization,
  });

  final double progress;
  final double planned;
  final double used;
  final AppLocalizations localization;

  @override
  Widget build(BuildContext context) {
    final remaining = (planned - used).clamp(0, planned);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        color: Theme.of(context).cardTheme.color,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(localization.t('budgetHealth'), style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            borderRadius: BorderRadius.circular(12),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _BudgetTile(label: localization.t('budgetPlanned'), value: planned)),
              Expanded(child: _BudgetTile(label: localization.t('budgetUsed'), value: used)),
              Expanded(child: _BudgetTile(label: localization.t('budgetRemaining'), value: remaining)),
            ],
          ),
        ],
      ),
    );
  }
}

class _BudgetTile extends StatelessWidget {
  const _BudgetTile({required this.label, required this.value});

  final String label;
  final double value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value.toStringAsFixed(0), style: Theme.of(context).textTheme.titleMedium),
        Text(label, style: Theme.of(context).textTheme.labelSmall),
      ],
    );
  }
}

class _MilestoneTile extends StatelessWidget {
  const _MilestoneTile({required this.entry});

  final ({CollectionModel collection, MilestoneModel milestone}) entry;

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    final milestone = entry.milestone;
    final collection = entry.collection;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        color: Theme.of(context).cardTheme.color,
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Theme.of(context).primaryColor.withOpacity(0.15),
            child: const Icon(IconlyLight.flag),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(milestone.title, style: Theme.of(context).textTheme.titleMedium),
                Text(collection.title, style: Theme.of(context).textTheme.bodySmall),
                Text('${milestone.date.day}/${milestone.date.month}',
                    style: Theme.of(context).textTheme.labelSmall),
              ],
            ),
          ),
          Chip(label: Text(_statusLabel(localization, milestone.status))),
        ],
      ),
    );
  }

  String _statusLabel(AppLocalizations localization, MilestoneStatus status) {
    switch (status) {
      case MilestoneStatus.progress:
        return localization.t('statusProgress');
      case MilestoneStatus.done:
        return localization.t('statusDone');
      default:
        return localization.t('statusPlanned');
    }
  }
}

class _JournalHighlightCard extends StatelessWidget {
  const _JournalHighlightCard({required this.entry});

  final ({CollectionModel collection, JournalEntryModel entry}) entry;

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    final journal = entry.entry;
    return GestureDetector(
      onTap: () => Navigator.of(context)
          .pushNamed('/collection_journal', arguments: entry.collection.id),
      child: Container(
        width: 220,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          color: Theme.of(context).cardTheme.color,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Image.network(journal.image, height: 110, width: double.infinity, fit: BoxFit.cover),
            ),
            const SizedBox(height: 8),
            Text(entry.collection.title, style: Theme.of(context).textTheme.labelSmall),
            Text(journal.title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text(journal.note, maxLines: 2, overflow: TextOverflow.ellipsis),
            const Spacer(),
            Row(
              children: [
                Chip(
                  label: Text(_moodLabel(localization, journal.mood)),
                  backgroundColor: Theme.of(context).primaryColor.withOpacity(0.15),
                  labelStyle: TextStyle(color: Theme.of(context).primaryColor),
                ),
                const Spacer(),
                Text('${journal.date.day}/${journal.date.month}',
                    style: Theme.of(context).textTheme.labelSmall),
              ],
            )
          ],
        ),
      ),
    );
  }

  String _moodLabel(AppLocalizations localization, JournalMood mood) {
    switch (mood) {
      case JournalMood.calm:
        return localization.t('moodCalm');
      case JournalMood.focused:
        return localization.t('moodFocused');
      default:
        return localization.t('moodExcited');
    }
  }
}
