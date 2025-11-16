import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';

import '../../core/controllers/app_scope.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/utils/dummy_data.dart';

class CollectionRoadmapScreen extends StatefulWidget {
  const CollectionRoadmapScreen({super.key, required this.collectionId});

  final String collectionId;

  @override
  State<CollectionRoadmapScreen> createState() => _CollectionRoadmapScreenState();
}

class _CollectionRoadmapScreenState extends State<CollectionRoadmapScreen> {
  MilestoneStatus? filter;

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context).collectionsController;
    final localization = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: Text(localization.t('roadmap'))),
      body: AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          final collection = controller.byId(widget.collectionId);
          var milestones = controller.milestonesFor(widget.collectionId);
          if (filter != null) {
            milestones = milestones.where((m) => m.status == filter).toList();
          }
          milestones.sort((a, b) => a.date.compareTo(b.date));
          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  color: Theme.of(context).cardTheme.color,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(collection.title, style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 8),
                    Text(localization.t('roadmapHint')),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      children: [
                        FilterChip(
                          selected: filter == null,
                          onSelected: (_) => setState(() => filter = null),
                          label: Text(localization.t('galleryFilterAll')),
                        ),
                        FilterChip(
                          selected: filter == MilestoneStatus.planned,
                          onSelected: (_) => setState(() => filter = MilestoneStatus.planned),
                          label: Text(localization.t('statusPlanned')),
                        ),
                        FilterChip(
                          selected: filter == MilestoneStatus.progress,
                          onSelected: (_) => setState(() => filter = MilestoneStatus.progress),
                          label: Text(localization.t('statusProgress')),
                        ),
                        FilterChip(
                          selected: filter == MilestoneStatus.done,
                          onSelected: (_) => setState(() => filter = MilestoneStatus.done),
                          label: Text(localization.t('statusDone')),
                        ),
                      ],
                    )
                  ],
                ),
              ),
              const SizedBox(height: 24),
              if (milestones.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Text(localization.t('roadmapEmpty'), textAlign: TextAlign.center),
                )
              else
                ...milestones.map(
                  (milestone) => _RoadmapCard(
                    collectionId: collection.id,
                    milestone: milestone,
                  ),
                )
            ],
          );
        },
      ),
    );
  }
}

class _RoadmapCard extends StatelessWidget {
  const _RoadmapCard({required this.collectionId, required this.milestone});

  final String collectionId;
  final MilestoneModel milestone;

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context).collectionsController;
    final localization = AppLocalizations.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        color: Theme.of(context).cardTheme.color,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              const Icon(IconlyLight.time_circle),
              Container(
                width: 2,
                height: 80,
                margin: const EdgeInsets.symmetric(vertical: 8),
                color: Theme.of(context).primaryColor.withOpacity(0.3),
              )
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(milestone.title, style: Theme.of(context).textTheme.titleMedium),
                Text(milestone.subtitle),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Chip(
                      label: Text(_statusLabel(localization, milestone.status)),
                      backgroundColor: _statusColor(context, milestone.status),
                    ),
                    const SizedBox(width: 12),
                    Text('${milestone.date.day}/${milestone.date.month}'),
                  ],
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () => controller.cycleMilestoneStatus(collectionId, milestone.id),
                  child: Text(localization.t('tapCycleStatus')),
                )
              ],
            ),
          )
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

  Color _statusColor(BuildContext context, MilestoneStatus status) {
    switch (status) {
      case MilestoneStatus.progress:
        return Theme.of(context).primaryColor.withOpacity(0.2);
      case MilestoneStatus.done:
        return Colors.green.withOpacity(0.2);
      default:
        return Colors.amber.withOpacity(0.2);
    }
  }
}
