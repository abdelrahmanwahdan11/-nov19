import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';

import '../../core/constants/app_assets.dart';
import '../../core/controllers/app_scope.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/utils/dummy_data.dart';
import '../../core/widgets/quick_settings_button.dart';

class CollectionVendorsScreen extends StatefulWidget {
  const CollectionVendorsScreen({super.key, required this.collectionId});

  final String collectionId;

  @override
  State<CollectionVendorsScreen> createState() => _CollectionVendorsScreenState();
}

class _CollectionVendorsScreenState extends State<CollectionVendorsScreen> {
  String _query = '';
  VendorStatus? _filter;
  final _nameController = TextEditingController();
  final _categoryController = TextEditingController();
  final _contactController = TextEditingController();
  final _costController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    _contactController.dispose();
    _costController.dispose();
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
        final vendors = collections.vendorsFor(widget.collectionId);
        final dueSoonCount = vendors
            .where((vendor) => vendor.dueDate.isBefore(DateTime.now().add(const Duration(days: 5))) &&
                vendor.status != VendorStatus.paid)
            .length;
        final filtered = vendors.where((vendor) {
          final matchesQuery = _query.isEmpty ||
              vendor.name.toLowerCase().contains(_query.toLowerCase()) ||
              vendor.category.toLowerCase().contains(_query.toLowerCase());
          final matchesFilter = _filter == null || vendor.status == _filter;
          return matchesQuery && matchesFilter;
        }).toList();
        final pendingCount = vendors.where((vendor) => vendor.status != VendorStatus.paid).length;
        final committed = collections.vendorTotalCost(widget.collectionId);
        return Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: Text(localization.t('vendorList')),
            actions: const [QuickSettingsButton()],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _openComposer(context),
            icon: const Icon(IconlyLight.work),
            label: Text(localization.t('vendorAdd')),
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
                    Text(localization.t('vendorOverview'),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70)),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _VendorStat(
                            label: localization.t('vendorTotalCommitted'),
                            value: committed.toStringAsFixed(0),
                            icon: IconlyLight.wallet,
                          ),
                        ),
                        Expanded(
                          child: _VendorStat(
                            label: localization.t('vendorPending'),
                            value: pendingCount.toString(),
                            icon: IconlyLight.info_circle,
                          ),
                        ),
                        Expanded(
                          child: _VendorStat(
                            label: localization.t('vendorDueSoon'),
                            value: dueSoonCount.toString(),
                            icon: IconlyLight.time_circle,
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
                  labelText: localization.t('vendorSearch'),
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
                    label: Text(localization.t('vendorFilterAll')),
                    onSelected: (_) => setState(() => _filter = null),
                  ),
                  ...VendorStatus.values.map(
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
                      Text(localization.t('vendorEmpty'), style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 8),
                      Text(localization.t('vendorEmptyDescription')),
                    ],
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (_, index) {
                    final vendor = filtered[index];
                    return _VendorTile(
                      vendor: vendor,
                      localization: localization,
                      onStatusChanged: (status) =>
                          collections.updateVendorStatus(widget.collectionId, vendor.id, status),
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
    final scaffold = ScaffoldMessenger.of(context);
    final controller = AppScope.of(context).collectionsController;
    DateTime selectedDate = DateTime.now().add(const Duration(days: 3));
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setModalState) {
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
                    Text(localization.t('vendorAdd'), style: Theme.of(context).textTheme.titleMedium),
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
                      controller: _categoryController,
                      decoration: InputDecoration(
                        labelText: localization.t('vendorCategory'),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _contactController,
                      decoration: InputDecoration(
                        labelText: localization.t('vendorContact'),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _costController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: localization.t('vendorCost'),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Text(localization.t('vendorDueDate'),
                              style: Theme.of(context).textTheme.bodyMedium),
                        ),
                        TextButton.icon(
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: selectedDate,
                              firstDate: DateTime.now(),
                              lastDate: DateTime.now().add(const Duration(days: 365)),
                            );
                            if (picked != null) {
                              setModalState(() => selectedDate = picked);
                            }
                          },
                          icon: const Icon(IconlyLight.calendar),
                          label: Text(MaterialLocalizations.of(context).formatMediumDate(selectedDate)),
                        )
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          final name = _nameController.text.trim();
                          if (name.isEmpty) return;
                          final vendor = VendorModel(
                            id: DateTime.now().millisecondsSinceEpoch.toString(),
                            name: name,
                            category: _categoryController.text.trim().isEmpty
                                ? localization.t('vendorCategory')
                                : _categoryController.text.trim(),
                            contact: _contactController.text.trim(),
                            avatar: AppAssets.profile,
                            cost: double.tryParse(_costController.text.trim()) ?? 0,
                            dueDate: selectedDate,
                            status: VendorStatus.scouting,
                          );
                          controller.addVendor(widget.collectionId, vendor);
                          _nameController.clear();
                          _categoryController.clear();
                          _contactController.clear();
                          _costController.clear();
                          Navigator.of(context).pop();
                          scaffold.showSnackBar(
                            SnackBar(content: Text(localization.t('vendorSaved'))),
                          );
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
      },
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

class _VendorStat extends StatelessWidget {
  const _VendorStat({required this.label, required this.value, required this.icon});

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
            Icon(icon, size: 16, color: Colors.white70),
            const SizedBox(width: 4),
            Text(value, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white)),
          ],
        ),
        Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white70)),
      ],
    );
  }
}

class _VendorTile extends StatelessWidget {
  const _VendorTile({
    required this.vendor,
    required this.localization,
    required this.onStatusChanged,
  });

  final VendorModel vendor;
  final AppLocalizations localization;
  final ValueChanged<VendorStatus> onStatusChanged;

  @override
  Widget build(BuildContext context) {
    final dueLabel = MaterialLocalizations.of(context).formatMediumDate(vendor.dueDate);
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
              CircleAvatar(backgroundImage: NetworkImage(vendor.avatar), radius: 26),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(vendor.name, style: theme.textTheme.titleSmall),
                    Text(vendor.category, style: theme.textTheme.bodySmall),
                  ],
                ),
              ),
              DropdownButton<VendorStatus>(
                value: vendor.status,
                underline: const SizedBox.shrink(),
                onChanged: (status) {
                  if (status != null) onStatusChanged(status);
                },
                items: VendorStatus.values
                    .map(
                      (status) => DropdownMenuItem(
                        value: status,
                        child: Text(_statusLabel(status)),
                      ),
                    )
                    .toList(),
              )
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              Chip(
                avatar: const Icon(IconlyLight.calendar, size: 16),
                label: Text('${localization.t('vendorDueLabel')} $dueLabel'),
              ),
              Chip(
                avatar: const Icon(IconlyLight.wallet, size: 16),
                label: Text('${vendor.cost.toStringAsFixed(0)}'),
              ),
              Chip(
                avatar: const Icon(IconlyLight.call, size: 16),
                label: Text(vendor.contact.isEmpty ? '--' : vendor.contact),
              ),
            ],
          ),
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
}
