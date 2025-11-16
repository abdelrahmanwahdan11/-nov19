import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';

import '../../core/controllers/app_scope.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/utils/dummy_data.dart';
import '../../core/widgets/quick_settings_button.dart';

class CollectionGuestsScreen extends StatefulWidget {
  const CollectionGuestsScreen({super.key, required this.collectionId});

  final String collectionId;

  @override
  State<CollectionGuestsScreen> createState() => _CollectionGuestsScreenState();
}

class _CollectionGuestsScreenState extends State<CollectionGuestsScreen> {
  String _query = '';
  GuestStatus? _filter;
  final _nameController = TextEditingController();
  final _roleController = TextEditingController();
  final _contactController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _roleController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    final controllers = AppScope.of(context);
    final collections = controllers.collectionsController;
    return AnimatedBuilder(
      animation: collections,
      builder: (_, __) {
        final collection = collections.byId(widget.collectionId);
        final guests = collections.guestsFor(widget.collectionId);
        final stats = collections.guestStatusSummary(widget.collectionId);
        final filtered = guests.where((guest) {
          final matchesQuery = _query.isEmpty ||
              guest.name.toLowerCase().contains(_query.toLowerCase()) ||
              guest.role.toLowerCase().contains(_query.toLowerCase());
          final matchesFilter = _filter == null || guest.status == _filter;
          return matchesQuery && matchesFilter;
        }).toList();
        final pendingCount = (stats[GuestStatus.invited] ?? 0) + (stats[GuestStatus.tentative] ?? 0);
        return Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: Text(localization.t('guestList')),
            actions: const [QuickSettingsButton()],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _openComposer(context),
            icon: const Icon(IconlyLight.add_user),
            label: Text(localization.t('guestAdd')),
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 120),
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(32),
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).primaryColor.withOpacity(0.15),
                      Theme.of(context).primaryColor.withOpacity(0.35),
                    ],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(collection.title, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white)),
                    const SizedBox(height: 8),
                    Text(localization.t('guestOverview'),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70)),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _GuestStat(
                            label: localization.t('guestStatusConfirmed'),
                            value: stats[GuestStatus.confirmed]?.toString() ?? '0',
                            icon: IconlyLight.tick_square,
                          ),
                        ),
                        Expanded(
                          child: _GuestStat(
                            label: localization.t('guestPending'),
                            value: pendingCount.toString(),
                            icon: IconlyLight.time_circle,
                          ),
                        ),
                        Expanded(
                          child: _GuestStat(
                            label: localization.t('guestStatusDeclined'),
                            value: stats[GuestStatus.declined]?.toString() ?? '0',
                            icon: IconlyLight.close_square,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                decoration: InputDecoration(
                  labelText: localization.t('guestSearch'),
                  prefixIcon: const Icon(IconlyLight.search),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
                ),
                onChanged: (value) => setState(() => _query = value),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                children: [
                  FilterChip(
                    selected: _filter == null,
                    label: Text(localization.t('guestFilterAll')),
                    onSelected: (_) => setState(() => _filter = null),
                  ),
                  ...GuestStatus.values.map(
                    (status) => FilterChip(
                      selected: _filter == status,
                      label: Text(_statusLabel(localization, status)),
                      onSelected: (_) => setState(() => _filter = status),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (filtered.isEmpty)
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28),
                    color: Theme.of(context).cardTheme.color,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(localization.t('guestEmpty'), style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 8),
                      Text(localization.t('guestEmptyDescription')),
                    ],
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (_, index) {
                    final guest = filtered[index];
                    return _GuestTile(
                      guest: guest,
                      onStatusChanged: (status) =>
                          collections.updateGuestStatus(widget.collectionId, guest.id, status),
                    );
                  },
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemCount: filtered.length,
                ),
            ],
          ),
        );
      },
    );
  }

  void _openComposer(BuildContext context) {
    final localization = AppLocalizations.of(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(localization.t('guestAdd'), style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 16),
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: localization.t('name'),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _roleController,
                  decoration: InputDecoration(
                    labelText: localization.t('guestRole'),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _contactController,
                  decoration: InputDecoration(
                    labelText: localization.t('guestContact'),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: ElevatedButton(
                    onPressed: () {
                      final name = _nameController.text.trim();
                      if (name.isEmpty) return;
                      final controllers = AppScope.of(context);
                      controllers.collectionsController.addGuest(
                        widget.collectionId,
                        GuestModel(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          name: name,
                          role: _roleController.text.trim().isEmpty
                              ? localization.t('guest')
                              : _roleController.text.trim(),
                          contact: _contactController.text.trim(),
                          avatar: 'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?auto=format&fit=crop&w=200&q=80',
                        ),
                      );
                      _nameController.clear();
                      _roleController.clear();
                      _contactController.clear();
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context)
                          .showSnackBar(SnackBar(content: Text(localization.t('guestSaved'))));
                    },
                    child: Text(localization.t('save')),
                  ),
                )
              ],
            ),
          ),
        );
      },
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

class _GuestStat extends StatelessWidget {
  const _GuestStat({required this.label, required this.value, required this.icon});

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.white),
        const SizedBox(height: 6),
        Text(value, style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white)),
        Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white70)),
      ],
    );
  }
}

class _GuestTile extends StatelessWidget {
  const _GuestTile({
    required this.guest,
    required this.onStatusChanged,
  });

  final GuestModel guest;
  final ValueChanged<GuestStatus> onStatusChanged;

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        color: Theme.of(context).cardTheme.color,
      ),
      child: Row(
        children: [
          CircleAvatar(backgroundImage: NetworkImage(guest.avatar), radius: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(guest.name, style: Theme.of(context).textTheme.titleMedium),
                Text('${guest.role}${guest.contact.isEmpty ? '' : ' · ${guest.contact}'}'),
                const SizedBox(height: 6),
                Chip(
                  label: Text(_statusLabel(localization, guest.status)),
                  backgroundColor: _statusColor(context, guest.status),
                ),
              ],
            ),
          ),
          PopupMenuButton<GuestStatus>(
            icon: const Icon(IconlyLight.setting),
            onSelected: onStatusChanged,
            itemBuilder: (_) => GuestStatus.values
                .map(
                  (status) => PopupMenuItem(
                    value: status,
                    child: Text(_statusLabel(localization, status)),
                  ),
                )
                .toList(),
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

  Color _statusColor(BuildContext context, GuestStatus status) {
    switch (status) {
      case GuestStatus.confirmed:
        return Colors.green.withOpacity(0.2);
      case GuestStatus.tentative:
        return Colors.amber.withOpacity(0.2);
      case GuestStatus.declined:
        return Colors.red.withOpacity(0.2);
      default:
        return Theme.of(context).primaryColor.withOpacity(0.2);
    }
  }
}
