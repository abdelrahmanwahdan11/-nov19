import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';

import '../../core/controllers/app_scope.dart';
import '../../core/controllers/collections_controller.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/utils/dummy_data.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/quick_settings_button.dart';

class CollectionLogisticsScreen extends StatefulWidget {
  const CollectionLogisticsScreen({super.key, required this.collectionId});

  final String collectionId;

  @override
  State<CollectionLogisticsScreen> createState() => _CollectionLogisticsScreenState();
}

class _CollectionLogisticsScreenState extends State<CollectionLogisticsScreen> {
  LogisticsType? _typeFilter;
  LogisticsStatus? _statusFilter;

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    final controller = AppScope.of(context).collectionsController;
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final collection = controller.byId(widget.collectionId);
        final summary = controller.logisticsStatusSummary(collection.id);
        final next = controller.nextLogistic(collection.id);
        var items = controller.logisticsFor(collection.id);
        if (_typeFilter != null) {
          items = items.where((element) => element.type == _typeFilter).toList();
        }
        if (_statusFilter != null) {
          items = items.where((element) => element.status == _statusFilter).toList();
        }
        items.sort((a, b) => a.start.compareTo(b.start));
        return Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: Text(localization.t('logisticsScreenTitle')),
            backgroundColor: Colors.transparent,
            elevation: 0,
            actions: const [QuickSettingsButton()],
          ),
          body: RefreshIndicator(
            onRefresh: controller.refresh,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 140),
              children: [
                Text(collection.title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(localization.t('logisticsSectionHint'),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white70)),
                if (next != null) ...[
                  const SizedBox(height: 20),
                  _LogisticsNextCard(logistic: next),
                ],
                const SizedBox(height: 24),
                Text(localization.t('logisticsStatusFilter'), style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ChoiceChip(
                      label: Text(localization.t('logisticsFilterAll')),
                      selected: _statusFilter == null,
                      onSelected: (_) => setState(() => _statusFilter = null),
                    ),
                    ...LogisticsStatus.values.map((status) {
                      final selected = _statusFilter == status;
                      return ChoiceChip(
                        label: Text(_statusLabel(status, localization)),
                        selected: selected,
                        onSelected: (_) => setState(() => _statusFilter = selected ? null : status),
                      );
                    }),
                  ],
                ),
                const SizedBox(height: 20),
                Text(localization.t('logisticsTypeFilter'), style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ChoiceChip(
                      label: Text(localization.t('logisticsFilterAll')),
                      selected: _typeFilter == null,
                      onSelected: (_) => setState(() => _typeFilter = null),
                    ),
                    ...LogisticsType.values.map((type) {
                      final selected = _typeFilter == type;
                      return ChoiceChip(
                        label: Text(_typeLabel(type, localization)),
                        selected: selected,
                        onSelected: (_) => setState(() => _typeFilter = selected ? null : type),
                      );
                    }),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(child: Text(localization.t('logisticsStatusFilter'))),
                    Text('${localization.t('logisticsStatusPending')}: ${summary[LogisticsStatus.pending] ?? 0}')
                  ],
                ),
                const SizedBox(height: 12),
                if (items.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28),
                      color: Theme.of(context).cardColor.withOpacity(0.9),
                    ),
                    child: Column(
                      children: [
                        const Icon(IconlyLight.location),
                        const SizedBox(height: 8),
                        Text(localization.t('logisticsEmpty'), textAlign: TextAlign.center),
                      ],
                    ),
                  )
                else
                  ...items.map((item) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _LogisticsListTile(
                          collectionId: collection.id,
                          item: item,
                        ),
                      )),
                const SizedBox(height: 24),
                PrimaryButton(
                  label: localization.t('logisticsAdd'),
                  onPressed: () => _openComposer(context, controller, collection.id),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _statusLabel(LogisticsStatus status, AppLocalizations localization) {
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

  String _typeLabel(LogisticsType type, AppLocalizations localization) {
    switch (type) {
      case LogisticsType.transport:
        return localization.t('logisticsTypeTransport');
      case LogisticsType.flight:
        return localization.t('logisticsTypeFlight');
      case LogisticsType.stay:
        return localization.t('logisticsTypeStay');
      case LogisticsType.experience:
        return localization.t('logisticsTypeExperience');
    }
  }

  Future<void> _openComposer(
    BuildContext context,
    CollectionsController controller,
    String collectionId,
  ) async {
    final localization = AppLocalizations.of(context);
    final titleController = TextEditingController();
    final providerController = TextEditingController();
    final locationController = TextEditingController();
    final noteController = TextEditingController();
    LogisticsType selectedType = LogisticsType.transport;
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.98),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            left: 24,
            right: 24,
            top: 24,
          ),
          child: StatefulBuilder(
            builder: (context, setSheetState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(localization.t('logisticsComposerTitle'),
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 16),
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(labelText: localization.t('logisticsComposerHint')),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: providerController,
                    decoration: InputDecoration(labelText: localization.t('logisticsProviderLabel')),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: locationController,
                    decoration: InputDecoration(labelText: localization.t('logisticsLocationLabel')),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<LogisticsType>(
                    value: selectedType,
                    decoration: InputDecoration(labelText: localization.t('logisticsTypeLabel')),
                    items: LogisticsType.values
                        .map((type) => DropdownMenuItem(
                              value: type,
                              child: Text(_typeLabel(type, localization)),
                            ))
                        .toList(),
                    onChanged: (value) => setSheetState(() => selectedType = value ?? selectedType),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: noteController,
                    minLines: 2,
                    maxLines: 4,
                    decoration: InputDecoration(labelText: localization.t('logisticsNotesLabel')),
                  ),
                  const SizedBox(height: 20),
                  PrimaryButton(
                    label: localization.t('logisticsCreate'),
                    onPressed: () {
                      if (titleController.text.isEmpty || providerController.text.isEmpty) {
                        return;
                      }
                      final now = DateTime.now().add(const Duration(days: 1));
                      final item = LogisticItemModel(
                        id: 'log${DateTime.now().millisecondsSinceEpoch}',
                        title: titleController.text,
                        provider: providerController.text,
                        location:
                            locationController.text.isEmpty ? localization.t('location') : locationController.text,
                        reference: '#${DateTime.now().millisecondsSinceEpoch % 10000}',
                        type: selectedType,
                        start: now,
                        end: now.add(const Duration(hours: 2)),
                        note: noteController.text,
                        cost: 0,
                        status: LogisticsStatus.pending,
                      );
                      controller.addLogistic(collectionId, item);
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}

class _LogisticsNextCard extends StatelessWidget {
  const _LogisticsNextCard({required this.logistic});

  final LogisticItemModel logistic;

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final dateFormatter = MaterialLocalizations.of(context);
    final startLabel = dateFormatter.formatMediumDate(logistic.start);
    final timeLabel = dateFormatter.formatTimeOfDay(TimeOfDay.fromDateTime(logistic.start));
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: LinearGradient(
          colors: [theme.primaryColor.withOpacity(0.15), theme.primaryColor.withOpacity(0.4)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(localization.t('logisticsNextDeparture'), style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(logistic.title, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text('${logistic.location} · ${logistic.provider}', style: theme.textTheme.bodyMedium),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: Text('$startLabel · $timeLabel')),
              _StatusPill(status: logistic.status),
            ],
          ),
        ],
      ),
    );
  }
}

class _LogisticsListTile extends StatelessWidget {
  const _LogisticsListTile({required this.collectionId, required this.item});

  final String collectionId;
  final LogisticItemModel item;

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    final controller = AppScope.of(context).collectionsController;
    final formatter = MaterialLocalizations.of(context);
    final time = formatter.formatTimeOfDay(TimeOfDay.fromDateTime(item.start));
    final date = formatter.formatMediumDate(item.start);
    final nextStatus = _nextStatus(item.status);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: Theme.of(context).cardColor.withOpacity(0.95),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Theme.of(context).primaryColor.withOpacity(0.2),
            child: Icon(_typeIcon(item.type), color: Theme.of(context).primaryColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title, style: Theme.of(context).textTheme.titleMedium),
                Text('${item.provider} · ${item.location}', style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 6),
                Text('$date · $time', style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _StatusPill(status: item.status),
                    const SizedBox(width: 12),
                    if (nextStatus != null)
                      TextButton(
                        onPressed: () => controller.updateLogisticStatus(collectionId, item.id, nextStatus),
                        child: Text(localization.t('logisticsAdvance')),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  LogisticsStatus? _nextStatus(LogisticsStatus status) {
    switch (status) {
      case LogisticsStatus.pending:
        return LogisticsStatus.booked;
      case LogisticsStatus.booked:
        return LogisticsStatus.enRoute;
      case LogisticsStatus.enRoute:
        return LogisticsStatus.arrived;
      case LogisticsStatus.arrived:
        return null;
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

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status});

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
    Color color;
    switch (status) {
      case LogisticsStatus.pending:
        color = Colors.orange;
        break;
      case LogisticsStatus.booked:
        color = Colors.blue;
        break;
      case LogisticsStatus.enRoute:
        color = Colors.amber;
        break;
      case LogisticsStatus.arrived:
        color = Colors.green;
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: color, fontWeight: FontWeight.w600),
      ),
    );
  }
}
