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
        final memoryPeek = controllers.collectionsController.latestMemories(4);
        final totalBudgetPlanned = controllers.collectionsController.totalBudgetPlanned;
        final totalBudgetUsed = controllers.collectionsController.totalBudgetUsed;
        final budgetProgress = totalBudgetPlanned == 0
            ? 0.0
            : (totalBudgetUsed / totalBudgetPlanned).clamp(0, 1);
        final milestonePeek = controllers.collectionsController.upcomingMilestones(3);
        final itineraryPeek = controllers.collectionsController.upcomingItinerarySlots(4);
        final guestFollowUps = controllers.collectionsController.pendingGuests(5);
        final vendorFollowUps = controllers.collectionsController.vendorFollowUps(5);
        final documentFollowUps = controllers.collectionsController.documentFollowUps(5);
        final logisticsPeek = controllers.collectionsController.upcomingLogistics(5);
        final budgetPressure = controllers.collectionsController.budgetPressureLines(4);
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
              if (budgetPressure.isNotEmpty) ...[
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: Text(localization.t('budgetPressureTitle'),
                          style: Theme.of(context).textTheme.titleMedium),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context)
                          .pushNamed('/collection_budget', arguments: budgetPressure.first.collection.id),
                      child: Text(localization.t('openBudgetBoard')),
                    )
                  ],
                ),
                const SizedBox(height: 4),
                Text(localization.t('budgetPressureSubtitle'),
                    style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 12),
                Column(
                  children: budgetPressure
                      .map(
                        (entry) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _BudgetPressureTile(
                            entry: entry,
                            ratio: controllers.collectionsController.budgetLineProgress(entry.line),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
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
              if (guestFollowUps.isNotEmpty) ...[
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child:
                          Text(localization.t('guestFollowups'), style: Theme.of(context).textTheme.titleMedium),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context)
                          .pushNamed('/collection_guests', arguments: guestFollowUps.first.collection.id),
                      child: Text(localization.t('guestOpenList')),
                    )
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 200,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: guestFollowUps.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (_, index) {
                      final entry = guestFollowUps[index];
                      return _GuestFollowUpCard(
                        collection: entry.collection,
                        guest: entry.guest,
                        localization: localization,
                        onConfirm: () => controllers.collectionsController
                            .updateGuestStatus(entry.collection.id, entry.guest.id, GuestStatus.confirmed),
                        onOpen: () => Navigator.of(context)
                            .pushNamed('/collection_guests', arguments: entry.collection.id),
                      );
                    },
                  ),
                ),
              ],
              if (vendorFollowUps.isNotEmpty) ...[
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: Text(localization.t('vendorFollowups'),
                          style: Theme.of(context).textTheme.titleMedium),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context)
                          .pushNamed('/collection_vendors', arguments: vendorFollowUps.first.collection.id),
                      child: Text(localization.t('vendorOpenList')),
                    )
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 190,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: vendorFollowUps.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (_, index) {
                      final entry = vendorFollowUps[index];
                      var nextStatus = entry.vendor.status;
                      switch (entry.vendor.status) {
                        case VendorStatus.scouting:
                          nextStatus = VendorStatus.negotiating;
                          break;
                        case VendorStatus.negotiating:
                          nextStatus = VendorStatus.booked;
                          break;
                        case VendorStatus.booked:
                          nextStatus = VendorStatus.paid;
                          break;
                        case VendorStatus.paid:
                          nextStatus = VendorStatus.paid;
                          break;
                      }
                      return _VendorFollowUpCard(
                        collection: entry.collection,
                        vendor: entry.vendor,
                        localization: localization,
                        onAdvance: entry.vendor.status == VendorStatus.paid
                            ? null
                            : () => controllers.collectionsController
                                .updateVendorStatus(entry.collection.id, entry.vendor.id, nextStatus),
                        onOpen: () => Navigator.of(context)
                            .pushNamed('/collection_vendors', arguments: entry.collection.id),
                      );
                    },
                  ),
                ),
              ],
              if (documentFollowUps.isNotEmpty) ...[
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: Text(localization.t('documentsFollowups'),
                          style: Theme.of(context).textTheme.titleMedium),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context)
                          .pushNamed('/collection_documents', arguments: documentFollowUps.first.collection.id),
                      child: Text(localization.t('documentsOpenList')),
                    )
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 220,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: documentFollowUps.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (_, index) {
                      final entry = documentFollowUps[index];
                      return _DocumentFollowUpCard(
                        entry: entry,
                        localization: localization,
                        onOpen: () => Navigator.of(context)
                            .pushNamed('/collection_documents', arguments: entry.collection.id),
                        onAdvance: entry.document.status == DocumentStatus.approved
                            ? null
                            : () {
                                final nextStatus = entry.document.status == DocumentStatus.draft
                                    ? DocumentStatus.review
                                    : DocumentStatus.approved;
                                controllers.collectionsController
                                    .updateDocumentStatus(entry.collection.id, entry.document.id, nextStatus);
                              },
                      );
                    },
                  ),
                ),
              ],
              if (logisticsPeek.isNotEmpty) ...[
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: Text(localization.t('logisticsFollowUps'),
                          style: Theme.of(context).textTheme.titleMedium),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context)
                          .pushNamed('/collection_logistics', arguments: logisticsPeek.first.collection.id),
                      child: Text(localization.t('logisticsOpenList')),
                    )
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 190,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: logisticsPeek.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (_, index) {
                      final entry = logisticsPeek[index];
                      LogisticsStatus? nextStatus;
                      switch (entry.item.status) {
                        case LogisticsStatus.pending:
                          nextStatus = LogisticsStatus.booked;
                          break;
                        case LogisticsStatus.booked:
                          nextStatus = LogisticsStatus.enRoute;
                          break;
                        case LogisticsStatus.enRoute:
                          nextStatus = LogisticsStatus.arrived;
                          break;
                        case LogisticsStatus.arrived:
                          nextStatus = null;
                          break;
                      }
                      return _LogisticsFollowUpCard(
                        collection: entry.collection,
                        logistic: entry.item,
                        localization: localization,
                        onAdvance: nextStatus == null
                            ? null
                            : () => controllers.collectionsController
                                .updateLogisticStatus(entry.collection.id, entry.item.id, nextStatus),
                        onOpen: () => Navigator.of(context)
                            .pushNamed('/collection_logistics', arguments: entry.collection.id),
                      );
                    },
                  ),
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
              if (memoryPeek.isNotEmpty) ...[
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: Text(localization.t('latestMemories'),
                          style: Theme.of(context).textTheme.titleMedium),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pushNamed('/memories'),
                      child: Text(localization.t('openMemories')),
                    )
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 220,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: memoryPeek.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (_, index) {
                      final memory = memoryPeek[index];
                      final collection = controllers.collectionsController.byId(memory.collectionId);
                      return _MemoryPeekCard(
                        memory: memory,
                        collection: collection,
                      );
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

class _GuestFollowUpCard extends StatelessWidget {
  const _GuestFollowUpCard({
    required this.collection,
    required this.guest,
    required this.localization,
    required this.onConfirm,
    required this.onOpen,
  });

  final CollectionModel collection;
  final GuestModel guest;
  final AppLocalizations localization;
  final VoidCallback onConfirm;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 230,
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
              CircleAvatar(backgroundImage: NetworkImage(guest.avatar), radius: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(guest.name, style: Theme.of(context).textTheme.titleSmall),
                    Text(collection.title,
                        style: Theme.of(context).textTheme.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ),
              )
            ],
          ),
          const SizedBox(height: 12),
          Text(guest.role, maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 8),
          Chip(
            label: Text(_statusLabel(localization, guest.status)),
            backgroundColor: Theme.of(context).primaryColor.withOpacity(0.15),
          ),
          const Spacer(),
          Row(
            children: [
              IconButton(
                onPressed: onOpen,
                icon: const Icon(IconlyLight.setting),
                tooltip: localization.t('guestOpenList'),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: onConfirm,
                  child: Text(localization.t('guestMarkConfirmed')),
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  String _statusLabel(AppLocalizations localization, GuestStatus status) {
    switch (status) {
      case GuestStatus.confirmed:
        return localization.t('guestStatusConfirmed');
      case GuestStatus.tentative:
        return localization.t('guestStatusTentative');
      case GuestStatus.declined:
        return localization.t('guestStatusDeclined');
      default:
        return localization.t('guestStatusInvited');
    }
  }
}

class _VendorFollowUpCard extends StatelessWidget {
  const _VendorFollowUpCard({
    required this.collection,
    required this.vendor,
    required this.localization,
    required this.onOpen,
    this.onAdvance,
  });

  final CollectionModel collection;
  final VendorModel vendor;
  final AppLocalizations localization;
  final VoidCallback? onAdvance;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final dueLabel = MaterialLocalizations.of(context).formatMediumDate(vendor.dueDate);
    final statusLabel = _statusLabel(vendor.status);
    final statusColor = _statusColor(context, vendor.status);
    return Container(
      width: 240,
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
              CircleAvatar(backgroundImage: NetworkImage(vendor.avatar), radius: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(vendor.name, style: Theme.of(context).textTheme.titleSmall),
                    Text(collection.title,
                        style: Theme.of(context).textTheme.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(vendor.category, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              Chip(
                avatar: const Icon(IconlyLight.calendar, size: 16),
                label: Text('${localization.t('vendorDueLabel')} $dueLabel'),
              ),
              Chip(
                avatar: const Icon(IconlyLight.wallet, size: 16),
                label: Text(vendor.cost.toStringAsFixed(0)),
              ),
              Chip(
                label: Text(statusLabel),
                backgroundColor: statusColor,
              ),
            ],
          ),
          const Spacer(),
          Row(
            children: [
              IconButton(
                onPressed: onOpen,
                icon: const Icon(IconlyLight.setting),
                tooltip: localization.t('vendorOpenList'),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: onAdvance,
                  child: Text(
                    vendor.status == VendorStatus.booked
                        ? localization.t('vendorMarkPaid')
                        : vendor.status == VendorStatus.paid
                            ? localization.t('vendorStatusPaid')
                            : localization.t('vendorAdvance'),
                  ),
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  String _statusLabel(VendorStatus status) {
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

  Color _statusColor(BuildContext context, VendorStatus status) {
    switch (status) {
      case VendorStatus.paid:
        return Colors.green.withOpacity(0.2);
      case VendorStatus.booked:
        return Theme.of(context).primaryColor.withOpacity(0.2);
      case VendorStatus.negotiating:
        return Colors.amber.withOpacity(0.2);
      default:
        return Colors.blueGrey.withOpacity(0.2);
    }
  }
}

class _DocumentFollowUpCard extends StatelessWidget {
  const _DocumentFollowUpCard({
    required this.entry,
    required this.localization,
    required this.onOpen,
    this.onAdvance,
  });

  final ({CollectionModel collection, DocumentModel document}) entry;
  final AppLocalizations localization;
  final VoidCallback onOpen;
  final VoidCallback? onAdvance;

  @override
  Widget build(BuildContext context) {
    final updatedLabel = MaterialLocalizations.of(context).formatShortDate(entry.document.updatedAt);
    final statusLabel = _statusLabel(entry.document.status);
    return Container(
      width: 240,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        color: Theme.of(context).cardTheme.color,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.network(entry.document.preview, height: 90, width: double.infinity, fit: BoxFit.cover),
          ),
          const SizedBox(height: 12),
          Text(entry.collection.title, style: Theme.of(context).textTheme.labelSmall),
          Text(entry.document.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleMedium),
          Text('${localization.t('documentsOwnerLabel')} ${entry.document.owner}',
              style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              Chip(
                label: Text(entry.document.category),
                backgroundColor: Theme.of(context).primaryColor.withOpacity(0.12),
              ),
              Chip(
                label: Text(statusLabel),
                backgroundColor: Theme.of(context).primaryColor.withOpacity(0.2),
              ),
            ],
          ),
          const Spacer(),
          Text('${localization.t('documentsUpdatedLabel')} $updatedLabel',
              style: Theme.of(context).textTheme.labelSmall),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: onOpen,
                  child: Text(localization.t('documentsReviewCta')),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                tooltip: localization.t('documentsAdvanceStatus'),
                onPressed: onAdvance,
                icon: const Icon(IconlyLight.tick_square),
              )
            ],
          )
        ],
      ),
    );
  }

  String _statusLabel(DocumentStatus status) {
    switch (status) {
      case DocumentStatus.draft:
        return localization.t('documentsStatusDraft');
      case DocumentStatus.review:
        return localization.t('documentsStatusReview');
      case DocumentStatus.approved:
        return localization.t('documentsStatusApproved');
    }
  }
}

class _LogisticsFollowUpCard extends StatelessWidget {
  const _LogisticsFollowUpCard({
    required this.collection,
    required this.logistic,
    required this.localization,
    required this.onOpen,
    this.onAdvance,
  });

  final CollectionModel collection;
  final LogisticItemModel logistic;
  final AppLocalizations localization;
  final VoidCallback? onAdvance;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final formatter = MaterialLocalizations.of(context);
    final date = formatter.formatMediumDate(logistic.start);
    final time = formatter.formatTimeOfDay(TimeOfDay.fromDateTime(logistic.start));
    final theme = Theme.of(context);
    return Container(
      width: 250,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        color: theme.cardColor.withOpacity(0.95),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(collection.title, style: theme.textTheme.titleSmall),
          const SizedBox(height: 4),
          Text(logistic.title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          Text('${logistic.provider} · ${logistic.location}',
              style: theme.textTheme.bodySmall?.copyWith(color: Colors.white70)),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(_typeIcon(logistic.type), size: 18, color: theme.primaryColor),
              const SizedBox(width: 6),
              Text('$date · $time', style: theme.textTheme.bodySmall),
            ],
          ),
          const Spacer(),
          Row(
            children: [
              _LogisticsStatusChip(status: logistic.status),
              const Spacer(),
              IconButton(
                icon: const Icon(IconlyLight.arrow_right_2),
                onPressed: onOpen,
              ),
            ],
          ),
          if (onAdvance != null)
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: onAdvance,
                child: Text(localization.t('logisticsAdvance')),
              ),
            ),
        ],
      ),
    );
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

class _LogisticsStatusChip extends StatelessWidget {
  const _LogisticsStatusChip({required this.status});

  final LogisticsStatus status;

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    final label = switch (status) {
      LogisticsStatus.pending => localization.t('logisticsStatusPending'),
      LogisticsStatus.booked => localization.t('logisticsStatusBooked'),
      LogisticsStatus.enRoute => localization.t('logisticsStatusEnRoute'),
      LogisticsStatus.arrived => localization.t('logisticsStatusArrived'),
    };
    final color = switch (status) {
      LogisticsStatus.pending => Colors.orange,
      LogisticsStatus.booked => Colors.blue,
      LogisticsStatus.enRoute => Colors.amber,
      LogisticsStatus.arrived => Colors.green,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: color.withOpacity(0.2),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: color, fontWeight: FontWeight.bold),
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
    final guestSummary = controller.guestStatusSummary(collection.id);
    final totalGuests = collection.guests.length;
    final confirmedGuests = guestSummary[GuestStatus.confirmed] ?? 0;
    final vendorSummary = controller.vendorStatusSummary(collection.id);
    final openVendors = (vendorSummary[VendorStatus.scouting] ?? 0) +
        (vendorSummary[VendorStatus.negotiating] ?? 0);
    final bookedVendors = vendorSummary[VendorStatus.booked] ?? 0;
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
                  if (collection.vendors.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(IconlyLight.work, size: 16),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            '${localization.t('vendorPending')}: $openVendors · ${localization.t('vendorStatusBooked')}: $bookedVendors',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context)
                              .pushNamed('/collection_vendors', arguments: collection.id),
                          child: Text(localization.t('vendorOpenList')),
                        )
                      ],
                    ),
                  ],
                  if (totalGuests > 0) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(IconlyLight.user, size: 16),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            '$confirmedGuests / $totalGuests ${localization.t('guestStatusConfirmed')}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                        TextButton(
                          onPressed: () =>
                              Navigator.of(context).pushNamed('/collection_guests', arguments: collection.id),
                          child: Text(localization.t('guestOpenList')),
                        )
                      ],
                    ),
                  ]
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

class _BudgetPressureTile extends StatelessWidget {
  const _BudgetPressureTile({required this.entry, required this.ratio});

  final ({CollectionModel collection, BudgetLineModel line}) entry;
  final double ratio;

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    final collection = entry.collection;
    final line = entry.line;
    final isOver = line.spent > line.planned;
    final badge = isOver ? localization.t('budgetOverLabel') : localization.t('budgetNearLabel');
    return InkWell(
      onTap: () => Navigator.of(context).pushNamed('/collection_budget', arguments: collection.id),
      borderRadius: BorderRadius.circular(28),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          color: Theme.of(context).cardTheme.color,
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: Theme.of(context).primaryColor.withOpacity(0.15),
              child: const Icon(IconlyLight.wallet),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(line.category, style: Theme.of(context).textTheme.titleMedium),
                  Text(collection.title, style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(height: 6),
                  LinearProgressIndicator(
                    value: ratio,
                    minHeight: 6,
                    backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('${(ratio * 100).round()}%',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Chip(
                  label: Text(badge),
                  backgroundColor:
                      isOver ? Colors.red.withOpacity(0.15) : Theme.of(context).primaryColor.withOpacity(0.15),
                ),
              ],
            )
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

class _MemoryPeekCard extends StatelessWidget {
  const _MemoryPeekCard({required this.memory, required this.collection});

  final MemoryHighlightModel memory;
  final CollectionModel collection;

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    return GestureDetector(
      onTap: () => Navigator.of(context).pushNamed('/memories'),
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
              child: Image.network(memory.image, height: 110, width: double.infinity, fit: BoxFit.cover),
            ),
            const SizedBox(height: 8),
            Text(collection.title, style: Theme.of(context).textTheme.labelSmall),
            Text(memory.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text(memory.description, maxLines: 2, overflow: TextOverflow.ellipsis),
            const Spacer(),
            Row(
              children: [
                Chip(label: Text(_moodLabel(localization, memory.mood))),
                const Spacer(),
                Text('${memory.date.day}/${memory.date.month}',
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
