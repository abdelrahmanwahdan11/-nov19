import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';

import '../../core/constants/app_assets.dart';
import '../../core/controllers/app_scope.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/utils/dummy_data.dart';
import '../../core/utils/itinerary_utils.dart';
import '../../core/widgets/quick_settings_button.dart';
import 'widgets/task_composer.dart';

class CollectionDetailsScreen extends StatefulWidget {
  const CollectionDetailsScreen({super.key, required this.collectionId});
  final String collectionId;

  @override
  State<CollectionDetailsScreen> createState() => _CollectionDetailsScreenState();
}

class _CollectionDetailsScreenState extends State<CollectionDetailsScreen> with SingleTickerProviderStateMixin {
  late TabController tabController;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    final collectionsController = AppScope.of(context).collectionsController;
    return AnimatedBuilder(
      animation: collectionsController,
      builder: (context, _) {
        final collection = collectionsController.byId(widget.collectionId);
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: NestedScrollView(
            headerSliverBuilder: (_, __) {
              return [
                SliverAppBar(
                  expandedHeight: 320,
                  pinned: true,
                  actions: const [QuickSettingsButton(iconColor: Colors.white)],
                  flexibleSpace: FlexibleSpaceBar(
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                    Hero(
                      tag: collection.id,
                      child: Image.network(collection.images.first, fit: BoxFit.cover),
                    ),
                    Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.transparent, Colors.black87],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                        Positioned(
                      bottom: 40,
                      left: 24,
                      right: 24,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  collection.title,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(IconlyLight.calendar, color: Colors.white),
                                onPressed: () => Navigator.of(context)
                                    .pushNamed('/collection_itinerary', arguments: collection.id),
                              ),
                              IconButton(
                                icon: const Icon(IconlyLight.paper, color: Colors.white),
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(localization.t('aiLater'))),
                                  );
                                },
                              )
                            ],
                          ),
                          Text(
                            collection.description,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(60),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardTheme.color,
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: TabBar(
                    controller: tabController,
                    indicator: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(40),
                    ),
                    labelColor: Colors.white,
                    unselectedLabelColor: Theme.of(context).textTheme.bodyMedium?.color,
                    tabs: [
                      Tab(text: localization.t('summary')),
                      Tab(text: localization.t('tasks')),
                      Tab(text: localization.t('media')),
                    ],
                  ),
                ),
              ),
            )
          ];
        },
        body: TabBarView(
          controller: tabController,
          children: [
            _SummaryTab(collection: collection),
            _TasksTab(collectionId: collection.id),
            _MediaTab(collection: collection),
          ],
        ),
      ),
    );
      },
    );
  }
}

class _SummaryTab extends StatelessWidget {
  const _SummaryTab({required this.collection});
  final CollectionModel collection;

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    final controller = AppScope.of(context).collectionsController;
    final milestones = collection.milestones;
    final progress = collection.budgetPlanned == 0
        ? 0.0
        : (collection.budgetUsed / collection.budgetPlanned).clamp(0, 1);
    final remaining = (collection.budgetPlanned - collection.budgetUsed).clamp(0, collection.budgetPlanned);
    final itinerary = collection.itinerary;
    final budgetLines = controller.budgetLinesFor(collection.id);
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(collection.description, style: Theme.of(context).textTheme.bodyLarge),
        const SizedBox(height: 16),
        _InfoRow(icon: IconlyLight.time_circle, title: localization.t('startTime'), value: '08:00 AM'),
        _InfoRow(icon: IconlyLight.time_circle, title: localization.t('endTime'), value: '06:00 PM'),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: Theme.of(context).cardTheme.color,
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.network(AppAssets.mapPlaceholder, width: 90, height: 90, fit: BoxFit.cover),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(collection.location, style: Theme.of(context).textTheme.titleMedium),
                    Text(localization.t('mapPreview'), style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              )
            ],
          ),
        ),
        if (collection.guests.isNotEmpty) ...[
          const SizedBox(height: 16),
          _GuestPeekCard(collectionId: collection.id),
        ],
        if (collection.vendors.isNotEmpty) ...[
          const SizedBox(height: 16),
          _VendorPeekCard(collectionId: collection.id),
        ],
        if (collection.logistics.isNotEmpty) ...[
          const SizedBox(height: 16),
          _LogisticsPeekCard(collectionId: collection.id),
        ],
        if (collection.documents.isNotEmpty) ...[
          const SizedBox(height: 16),
          _DocumentPeekCard(collectionId: collection.id),
        ],
        if (itinerary.isNotEmpty) ...[
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: Text(localization.t('itineraryPeek'), style: Theme.of(context).textTheme.titleMedium)),
              TextButton(
                onPressed: () => Navigator.of(context)
                    .pushNamed('/collection_itinerary', arguments: collection.id),
                child: Text(localization.t('openItinerary')),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Column(
            children: itinerary
                .take(2)
                .map((day) => _ItineraryPreviewCard(day: day))
                .toList(),
          ),
        ],
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: LinearGradient(
              colors: [
                Theme.of(context).primaryColor.withOpacity(0.15),
                Theme.of(context).primaryColor.withOpacity(0.4),
              ],
            ),
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
                color: Colors.white,
                backgroundColor: Colors.white24,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _BudgetStat(
                      label: localization.t('budgetPlanned'),
                      value: collection.budgetPlanned.toStringAsFixed(0),
                    ),
                  ),
                  Expanded(
                    child: _BudgetStat(
                      label: localization.t('budgetUsed'),
                      value: collection.budgetUsed.toStringAsFixed(0),
                    ),
                  ),
                  Expanded(
                    child: _BudgetStat(
                      label: localization.t('budgetRemaining'),
                      value: remaining.toStringAsFixed(0),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (budgetLines.isNotEmpty) ...[
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child:
                    Text(localization.t('budgetCategories'), style: Theme.of(context).textTheme.titleMedium),
              ),
              TextButton(
                onPressed: () =>
                    Navigator.of(context).pushNamed('/collection_budget', arguments: collection.id),
                child: Text(localization.t('openBudgetBoard')),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Column(
            children: budgetLines
                .take(3)
                .map(
                  (line) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _BudgetLinePreview(
                      line: line,
                      ratio: controller.budgetLineProgress(line),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
        const SizedBox(height: 16),
        _JournalPeekCard(collectionId: collection.id),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Text(localization.t('milestones'), style: Theme.of(context).textTheme.titleMedium),
            ),
            TextButton.icon(
              onPressed: () => Navigator.of(context)
                  .pushNamed('/collection_roadmap', arguments: collection.id),
              icon: const Icon(IconlyLight.discovery),
              label: Text(localization.t('openRoadmap')),
            )
          ],
        ),
        const SizedBox(height: 8),
        if (milestones.isEmpty)
          Text(localization.t('roadmapEmpty'))
        else ...milestones.take(3).map(
          (milestone) => Card(
            child: ListTile(
              onTap: () => controller.cycleMilestoneStatus(collection.id, milestone.id),
              title: Text(milestone.title),
              subtitle: Text('${milestone.subtitle}\n${_formatDate(milestone.date)}'),
              isThreeLine: true,
              trailing: Chip(
                label: Text(_statusLabel(localization, milestone.status)),
                backgroundColor: _statusColor(context, milestone.status),
              ),
            ),
          ),
        ),
        if (milestones.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              localization.t('tapCycleStatus'),
              style: Theme.of(context).textTheme.labelSmall,
            ),
          )
      ],
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
        return Theme.of(context).primaryColor.withOpacity(0.3);
      case MilestoneStatus.done:
        return Colors.green.withOpacity(0.3);
      default:
        return Colors.amber.withOpacity(0.3);
    }
  }

  String _formatDate(DateTime date) => '${date.day}/${date.month}';
}

class _BudgetStat extends StatelessWidget {
  const _BudgetStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white)),
        Text(label, style: Theme.of(context).textTheme.labelMedium?.copyWith(color: Colors.white70)),
      ],
    );
  }
}

class _BudgetLinePreview extends StatelessWidget {
  const _BudgetLinePreview({required this.line, required this.ratio});

  final BudgetLineModel line;
  final double ratio;

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    final isOver = line.spent > line.planned;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        color: Theme.of(context).cardTheme.color,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(line.category, style: Theme.of(context).textTheme.titleMedium)),
              Chip(
                label: Text(isOver ? localization.t('budgetOverLabel') : localization.t('budgetNearLabel')),
                backgroundColor:
                    isOver ? Colors.red.withOpacity(0.12) : Theme.of(context).primaryColor.withOpacity(0.15),
              )
            ],
          ),
          if (line.note.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4, bottom: 8),
              child: Text(line.note, style: Theme.of(context).textTheme.bodySmall),
            ),
          LinearProgressIndicator(
            value: ratio,
            minHeight: 6,
            borderRadius: BorderRadius.circular(12),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text('${localization.t('budgetPlanned')}: ${line.planned.toStringAsFixed(0)}',
                    style: Theme.of(context).textTheme.labelSmall),
              ),
              Expanded(
                child: Text('${localization.t('budgetUsed')}: ${line.spent.toStringAsFixed(0)}',
                    style: Theme.of(context).textTheme.labelSmall),
              ),
            ],
          )
        ],
      ),
    );
  }
}

class _GuestPeekCard extends StatelessWidget {
  const _GuestPeekCard({required this.collectionId});

  final String collectionId;

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    final controller = AppScope.of(context).collectionsController;
    final guests = controller.guestsFor(collectionId);
    final summary = controller.guestStatusSummary(collectionId);
    final confirmed = summary[GuestStatus.confirmed] ?? 0;
    final pending = (summary[GuestStatus.invited] ?? 0) + (summary[GuestStatus.tentative] ?? 0);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        color: Theme.of(context).cardTheme.color,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(localization.t('guestPeekTitle'), style: Theme.of(context).textTheme.titleMedium)),
              TextButton.icon(
                onPressed: () => Navigator.of(context)
                    .pushNamed('/collection_guests', arguments: collectionId),
                icon: const Icon(IconlyLight.user),
                label: Text(localization.t('guestOpenList')),
              )
            ],
          ),
          const SizedBox(height: 6),
          Text(localization.t('guestPeekSubtitle')), 
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _GuestSummaryStat(
                  label: localization.t('guestStatusConfirmed'),
                  value: '$confirmed',
                ),
              ),
              Expanded(
                child: _GuestSummaryStat(
                  label: localization.t('guestPending'),
                  value: '$pending',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: guests.take(3).map((guest) {
              return Chip(
                avatar: CircleAvatar(backgroundImage: NetworkImage(guest.avatar)),
                label: Text(guest.name),
              );
            }).toList(),
          )
        ],
      ),
    );
  }
}

class _VendorPeekCard extends StatelessWidget {
  const _VendorPeekCard({required this.collectionId});

  final String collectionId;

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    final controller = AppScope.of(context).collectionsController;
    final vendors = controller.vendorsFor(collectionId);
    final summary = controller.vendorStatusSummary(collectionId);
    final dueSoon = vendors
        .where((vendor) => vendor.dueDate.isBefore(DateTime.now().add(const Duration(days: 5))) &&
            vendor.status != VendorStatus.paid)
        .length;
    final booked = summary[VendorStatus.booked] ?? 0;
    final negotiating = summary[VendorStatus.negotiating] ?? 0;
    final committed = controller.vendorTotalCost(collectionId);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        color: Theme.of(context).cardTheme.color,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(localization.t('vendorPeekTitle'), style: Theme.of(context).textTheme.titleMedium)),
              TextButton.icon(
                onPressed: () => Navigator.of(context)
                    .pushNamed('/collection_vendors', arguments: collectionId),
                icon: const Icon(IconlyLight.work),
                label: Text(localization.t('vendorOpenList')),
              )
            ],
          ),
          const SizedBox(height: 6),
          Text(localization.t('vendorPeekSubtitle')),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _VendorSummaryStat(
                  label: localization.t('vendorStatusBooked'),
                  value: '$booked',
                ),
              ),
              Expanded(
                child: _VendorSummaryStat(
                  label: localization.t('vendorStatusNegotiating'),
                  value: '$negotiating',
                ),
              ),
              Expanded(
                child: _VendorSummaryStat(
                  label: localization.t('vendorDueSoon'),
                  value: '$dueSoon',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text('${localization.t('vendorTotalCommitted')}: ${committed.toStringAsFixed(0)}',
              style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 12),
          Column(
            children: vendors.take(3).map((vendor) {
              final dueLabel = MaterialLocalizations.of(context).formatMediumDate(vendor.dueDate);
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(backgroundImage: NetworkImage(vendor.avatar)),
                title: Text(vendor.name),
                subtitle: Text('${vendor.category} · ${localization.t('vendorDueLabel')} $dueLabel'),
                trailing: Chip(label: Text(_statusLabel(localization, vendor.status))),
              );
            }).toList(),
          )
        ],
      ),
    );
  }

  String _statusLabel(AppLocalizations localization, VendorStatus status) {
    switch (status) {
      case VendorStatus.negotiating:
        return localization.t('vendorStatusNegotiating');
      case VendorStatus.booked:
        return localization.t('vendorStatusBooked');
      case VendorStatus.paid:
        return localization.t('vendorStatusPaid');
      default:
        return localization.t('vendorStatusScouting');
    }
  }
}

class _LogisticsPeekCard extends StatelessWidget {
  const _LogisticsPeekCard({required this.collectionId});

  final String collectionId;

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    final controller = AppScope.of(context).collectionsController;
    final logistics = controller.logisticsFor(collectionId);
    final summary = controller.logisticsStatusSummary(collectionId);
    final formatter = MaterialLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        color: Theme.of(context).cardColor.withOpacity(0.95),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(localization.t('logisticsPeekTitle'), style: Theme.of(context).textTheme.titleMedium)),
              TextButton.icon(
                onPressed: () => Navigator.of(context)
                    .pushNamed('/collection_logistics', arguments: collectionId),
                icon: const Icon(IconlyLight.location),
                label: Text(localization.t('logisticsOpenList')),
              )
            ],
          ),
          const SizedBox(height: 6),
          Text(localization.t('logisticsPeekSubtitle')),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: LogisticsStatus.values.map((status) {
              final count = summary[status] ?? 0;
              return Chip(
                avatar: Icon(_statusIcon(status), size: 16),
                label: Text('${_statusLabel(localization, status)} · $count'),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          Column(
            children: logistics.take(2).map((item) {
              final date = formatter.formatMediumDate(item.start);
              final time = formatter.formatTimeOfDay(TimeOfDay.fromDateTime(item.start));
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundColor: Theme.of(context).primaryColor.withOpacity(0.15),
                  child: Icon(_typeIcon(item.type), color: Theme.of(context).primaryColor),
                ),
                title: Text(item.title),
                subtitle: Text('${item.provider} · $date · $time'),
                trailing: Chip(label: Text(_statusLabel(localization, item.status))),
              );
            }).toList(),
          )
        ],
      ),
    );
  }

  String _statusLabel(AppLocalizations localization, LogisticsStatus status) {
    switch (status) {
      case LogisticsStatus.pending:
        return localization.t('logisticsStatusPending');
      case LogisticsStatus.booked:
        return localization.t('logisticsStatusBooked');
      case LogisticsStatus.enRoute:
        return localization.t('logisticsStatusEnRoute');
      case LogisticsStatus.arrived:
        return localization.t('logisticsStatusArrived');
    }
  }

  IconData _statusIcon(LogisticsStatus status) {
    switch (status) {
      case LogisticsStatus.pending:
        return IconlyLight.time_circle;
      case LogisticsStatus.booked:
        return IconlyLight.calendar;
      case LogisticsStatus.enRoute:
        return IconlyLight.location;
      case LogisticsStatus.arrived:
        return IconlyLight.tick_square;
    }
  }

  IconData _typeIcon(LogisticsType type) {
    switch (type) {
      case LogisticsType.transport:
        return IconlyLight.car;
      case LogisticsType.flight:
        return IconlyLight.paper_plane;
      case LogisticsType.stay:
        return IconlyLight.home;
      case LogisticsType.experience:
        return IconlyLight.activity;
    }
  }
}

class _DocumentPeekCard extends StatelessWidget {
  const _DocumentPeekCard({required this.collectionId});

  final String collectionId;

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    final controller = AppScope.of(context).collectionsController;
    final documents = controller.documentsFor(collectionId);
    final summary = controller.documentStatusSummary(collectionId);
    final pending = (summary[DocumentStatus.draft] ?? 0) + (summary[DocumentStatus.review] ?? 0);
    final approved = summary[DocumentStatus.approved] ?? 0;
    final recent = [...documents]
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        color: Theme.of(context).cardColor.withOpacity(0.95),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(localization.t('documentsPeekTitle'), style: Theme.of(context).textTheme.titleMedium)),
              TextButton.icon(
                onPressed: () => Navigator.of(context)
                    .pushNamed('/collection_documents', arguments: collectionId),
                icon: const Icon(IconlyLight.paper),
                label: Text(localization.t('documentsOpenList')),
              )
            ],
          ),
          const SizedBox(height: 6),
          Text(localization.t('documentsPeekSubtitle')),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _DocumentStat(
                  label: localization.t('documentsPendingLabel'),
                  value: '$pending',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _DocumentStat(
                  label: localization.t('documentsApprovedLabel'),
                  value: '$approved',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: recent.take(3).map((doc) {
              final updated = MaterialLocalizations.of(context).formatShortDate(doc.updatedAt);
              return Chip(
                label: Text('${doc.title} · $updated'),
              );
            }).toList(),
          )
        ],
      ),
    );
  }
}

class _DocumentStat extends StatelessWidget {
  const _DocumentStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: Theme.of(context).primaryColor.withOpacity(0.12),
      ),
      child: Column(
        children: [
          Text(value, style: Theme.of(context).textTheme.headlineSmall),
          Text(label, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _VendorSummaryStat extends StatelessWidget {
  const _VendorSummaryStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: Theme.of(context).textTheme.headlineSmall),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _GuestSummaryStat extends StatelessWidget {
  const _GuestSummaryStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: Theme.of(context).textTheme.headlineSmall),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.title, required this.value});
  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).primaryColor),
          const SizedBox(width: 12),
          Expanded(child: Text(title)),
          Text(value, style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }
}

class _JournalPeekCard extends StatelessWidget {
  const _JournalPeekCard({required this.collectionId});

  final String collectionId;

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    final controller = AppScope.of(context).collectionsController;
    final entries = controller.journalFor(collectionId);
    final latest = entries.isNotEmpty ? entries.first : null;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        color: Theme.of(context).cardTheme.color,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(localization.t('latestHighlights'),
                    style: Theme.of(context).textTheme.titleMedium),
              ),
              TextButton(
                onPressed: () => Navigator.of(context)
                    .pushNamed('/collection_journal', arguments: collectionId),
                child: Text(localization.t('openJournal')),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (latest == null)
            Text(localization.t('journalEmptyDescription'))
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(latest.title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(latest.note, maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  children: [
                    Chip(label: Text('${localization.t('mood')}: ${_moodLabel(localization, latest.mood)}')),
                    Chip(label: Text('${latest.date.day}/${latest.date.month}')),
                  ],
                ),
              ],
            ),
        ],
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

class _ItineraryPreviewCard extends StatelessWidget {
  const _ItineraryPreviewCard({required this.day});

  final ItineraryDayModel day;

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    final dateLabel = MaterialLocalizations.of(context).formatMediumDate(day.date);
    final slots = day.slots.take(2).toList();
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: Theme.of(context).cardTheme.color,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(dateLabel, style: Theme.of(context).textTheme.labelMedium),
          Text(day.focus, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          ...slots.map(
            (slot) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Text(
                    MaterialLocalizations.of(context).formatTimeOfDay(slot.time),
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: Text(slot.title)),
                  Chip(
                    label: Text(localizedItineraryTag(slot.tag, localization)),
                    backgroundColor: Theme.of(context).primaryColor.withOpacity(0.15),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

class _TasksTab extends StatelessWidget {
  const _TasksTab({required this.collectionId});
  final String collectionId;

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    final controller = AppScope.of(context).collectionsController;
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final tasks = controller.tasksFor(collectionId);
        return ListView(
          padding: const EdgeInsets.all(24),
          children: [
            TextButton.icon(
              onPressed: () => Navigator.of(context).pushNamed('/collection_tasks', arguments: collectionId),
              icon: const Icon(IconlyLight.calendar),
              label: Text(localization.t('seeFullSchedule')),
            ),
            const SizedBox(height: 12),
            if (tasks.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Text(localization.t('tasksEmpty'), textAlign: TextAlign.center),
              )
            else
              ...tasks.map(
                (task) => Card(
                  child: ListTile(
                    leading: CircleAvatar(child: Text(task.assignee.characters.first)),
                    title: Text(task.title),
                    subtitle: Text('${task.subtitle}\n${_formatDate(task.date)}'),
                    isThreeLine: true,
                    trailing: Checkbox(
                      value: task.completed,
                      onChanged: (value) => controller.toggleTask(collectionId, task.id, value ?? false),
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => showTaskComposer(context, collectionId),
              icon: const Icon(IconlyLight.plus),
              label: Text(localization.t('addTask')),
            )
          ],
        );
      },
    );
  }

  String _formatDate(DateTime date) => '${date.day}/${date.month} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
}

class _MediaTab extends StatelessWidget {
  const _MediaTab({required this.collection});
  final CollectionModel collection;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.9,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: collection.images.length,
      itemBuilder: (_, index) {
        final image = collection.images[index];
        return ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Image.network(image, fit: BoxFit.cover),
        );
      },
    );
  }
}
