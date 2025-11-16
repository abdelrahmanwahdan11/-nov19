import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';

import '../../core/controllers/app_scope.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/utils/dummy_data.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controllers = AppScope.of(context);
    final localization = AppLocalizations.of(context);
    final collections = controllers.collectionsController;
    return Scaffold(
      appBar: AppBar(
        title: Text(localization.t('insightsDeepDive')),
        actions: [
          IconButton(
            onPressed: () => Navigator.of(context).pushNamed('/settings'),
            icon: const Icon(IconlyLight.setting),
          )
        ],
      ),
      body: AnimatedBuilder(
        animation: collections,
        builder: (context, _) {
          if (collections.isLoading && collections.visible.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          final spending = collections.spendingByType();
          final mood = collections.overallMoodSummary();
          final attention = collections.collectionsNeedingAttention();
          final leaders = collections.leadingCollections();
          final timeline = collections.upcomingTimeline(6);
          final distribution = <String, int>{};
          for (final collection in DummyData.collections) {
            distribution.update(collection.type, (value) => value + 1, ifAbsent: () => 1);
          }
          return RefreshIndicator(
            onRefresh: collections.refresh,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 120),
              children: [
                _OverviewCard(
                  completion: collections.overallCompletionRate,
                  completedTasks: collections.completedTasksCount,
                  totalTasks: collections.totalTasksCount,
                  planned: collections.totalBudgetPlanned,
                  used: collections.totalBudgetUsed,
                  localization: localization,
                ),
                const SizedBox(height: 24),
                _SectionTitle(title: localization.t('moodPulse')),
                const SizedBox(height: 12),
                if (mood.values.any((count) => count > 0))
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: mood.entries
                        .map((entry) => _MoodChip(
                              mood: entry.key,
                              count: entry.value,
                              localization: localization,
                            ))
                        .toList(),
                  )
                else
                  Text(localization.t('insightsAllGood')),
                const SizedBox(height: 24),
                if (spending.isNotEmpty) ...[
                  _SectionTitle(title: localization.t('spendingByType')),
                  const SizedBox(height: 12),
                  _SpendingChart(spending: spending),
                  const SizedBox(height: 24),
                ],
                if (distribution.isNotEmpty) ...[
                  _SectionTitle(title: localization.t('eventDistribution')),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: distribution.entries
                        .map((entry) => Chip(
                              avatar: CircleAvatar(
                                backgroundColor: Theme.of(context).primaryColor.withOpacity(0.2),
                                child: Text('${entry.value}'),
                              ),
                              label: Text(entry.key),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 24),
                ],
                _SectionTitle(title: localization.t('collectionsAttention')),
                const SizedBox(height: 12),
                if (attention.isEmpty)
                  _EmptyState(text: localization.t('insightsAllGood'))
                else
                  Column(
                    children: attention
                        .map(
                          (collection) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _CollectionInsightTile(
                              collection: collection,
                              completion: collections.completionRate(collection.id),
                              budgetRatio: collections.budgetProgress(collection.id),
                              localization: localization,
                            ),
                          ),
                        )
                        .toList(),
                  ),
                const SizedBox(height: 24),
                _SectionTitle(title: localization.t('collectionsLeaders')),
                const SizedBox(height: 12),
                if (leaders.isEmpty)
                  _EmptyState(text: localization.t('insightsNoLeaders'))
                else
                  Column(
                    children: leaders
                        .map(
                          (collection) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _CollectionInsightTile(
                              collection: collection,
                              completion: collections.completionRate(collection.id),
                              budgetRatio: collections.budgetProgress(collection.id),
                              localization: localization,
                              positive: true,
                            ),
                          ),
                        )
                        .toList(),
                  ),
                if (timeline.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  _SectionTitle(title: localization.t('insightsTimeline')),
                  const SizedBox(height: 12),
                  Column(
                    children: timeline
                        .map(
                          (entry) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _TimelineCard(entry: entry, localization: localization),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _OverviewCard extends StatelessWidget {
  const _OverviewCard({
    required this.completion,
    required this.completedTasks,
    required this.totalTasks,
    required this.planned,
    required this.used,
    required this.localization,
  });

  final double completion;
  final int completedTasks;
  final int totalTasks;
  final double planned;
  final double used;
  final AppLocalizations localization;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(36),
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor.withOpacity(0.9),
            Theme.of(context).primaryColor.withOpacity(0.6),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(localization.t('overallCompletion'),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white70)),
          const SizedBox(height: 8),
          Text('${(completion * 100).round()}%',
              style: Theme.of(context)
                  .textTheme
                  .displaySmall
                  ?.copyWith(color: Colors.white, fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: completion,
            minHeight: 8,
            borderRadius: BorderRadius.circular(12),
            backgroundColor: Colors.white24,
            color: Colors.white,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _OverviewStat(
                  label: localization.t('tasks'),
                  value: '$completedTasks/$totalTasks',
                  icon: IconlyLight.tick_square,
                ),
              ),
              Expanded(
                child: _OverviewStat(
                  label: localization.t('budgetUsed'),
                  value: used.toStringAsFixed(0),
                  icon: IconlyLight.wallet,
                ),
              ),
              Expanded(
                child: _OverviewStat(
                  label: localization.t('budgetRemaining'),
                  value: (planned - used).clamp(0, planned).toStringAsFixed(0),
                  icon: IconlyLight.chart,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}

class _OverviewStat extends StatelessWidget {
  const _OverviewStat({required this.label, required this.value, required this.icon});

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.white70, size: 18),
            const SizedBox(width: 6),
            Text(label, style: const TextStyle(color: Colors.white70)),
          ],
        ),
        const SizedBox(height: 4),
        Text(value,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(title, style: Theme.of(context).textTheme.titleMedium);
  }
}

class _MoodChip extends StatelessWidget {
  const _MoodChip({required this.mood, required this.count, required this.localization});

  final JournalMood mood;
  final int count;
  final AppLocalizations localization;

  @override
  Widget build(BuildContext context) {
    final color = switch (mood) {
      JournalMood.calm => const Color(0xFF4CB5AB),
      JournalMood.focused => const Color(0xFF3F6C1E),
      JournalMood.excited => const Color(0xFFEF7C55),
    };
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: color.withOpacity(0.15),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(IconlyBold.heart, color: color, size: 16),
          const SizedBox(width: 8),
          Text(_label(localization), style: TextStyle(color: color, fontWeight: FontWeight.w600)),
          const SizedBox(width: 8),
          Text('$count', style: TextStyle(color: color)),
        ],
      ),
    );
  }

  String _label(AppLocalizations localization) {
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

class _SpendingChart extends StatelessWidget {
  const _SpendingChart({required this.spending});

  final Map<String, double> spending;

  @override
  Widget build(BuildContext context) {
    final maxValue = spending.values.fold<double>(0, (previousValue, element) => element > previousValue ? element : previousValue);
    return Column(
      children: spending.entries
          .map(
            (entry) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Expanded(child: Text(entry.key, style: Theme.of(context).textTheme.bodyMedium)),
                  Expanded(
                    flex: 2,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: LinearProgressIndicator(
                        value: maxValue == 0 ? 0 : entry.value / maxValue,
                        minHeight: 8,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(entry.value.toStringAsFixed(0), style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}

class _CollectionInsightTile extends StatelessWidget {
  const _CollectionInsightTile({
    required this.collection,
    required this.completion,
    required this.budgetRatio,
    required this.localization,
    this.positive = false,
  });

  final CollectionModel collection;
  final double completion;
  final double budgetRatio;
  final AppLocalizations localization;
  final bool positive;

  @override
  Widget build(BuildContext context) {
    final daysLeft = collection.date.difference(DateTime.now()).inDays;
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        color: theme.cardTheme.color,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(collection.title, style: theme.textTheme.titleMedium),
              ),
              Chip(
                label: Text(daysLeft <= 0
                    ? localization.t('todayLabel')
                    : localization.t('daysLeft').replaceFirst('%d', daysLeft.toString())),
              )
            ],
          ),
          Text(collection.location, style: theme.textTheme.bodySmall),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(localization.t('completionLabel'), style: theme.textTheme.labelSmall),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: completion,
                      minHeight: 6,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    const SizedBox(height: 4),
                    Text('${(completion * 100).round()}%'),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(localization.t('budgetPressureLabel'), style: theme.textTheme.labelSmall),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: budgetRatio,
                      minHeight: 6,
                      borderRadius: BorderRadius.circular(8),
                      color: positive ? theme.primaryColor : Colors.redAccent,
                    ),
                    const SizedBox(height: 4),
                    Text('${(budgetRatio * 100).round()}%'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TimelineCard extends StatelessWidget {
  const _TimelineCard({required this.entry, required this.localization});

  final ({CollectionModel collection, TaskModel task}) entry;
  final AppLocalizations localization;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final task = entry.task;
    final collection = entry.collection;
    final hours = task.date.hour.toString().padLeft(2, '0');
    final minutes = task.date.minute.toString().padLeft(2, '0');
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        color: theme.cardTheme.color,
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: theme.primaryColor.withOpacity(0.15),
            child: const Icon(IconlyLight.time_circle),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(task.title, style: theme.textTheme.titleMedium),
                Text(collection.title, style: theme.textTheme.bodySmall),
                Text('${task.date.day}/${task.date.month} $hours:$minutes',
                    style: theme.textTheme.labelSmall),
              ],
            ),
          ),
          Chip(label: Text(task.assignee)),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: Theme.of(context).cardTheme.color,
      ),
      child: Center(
        child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
      ),
    );
  }
}
