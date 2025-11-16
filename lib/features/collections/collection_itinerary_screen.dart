import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';

import '../../core/controllers/app_scope.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/utils/dummy_data.dart';
import '../../core/utils/itinerary_utils.dart';
import '../../core/widgets/quick_settings_button.dart';

class CollectionItineraryScreen extends StatefulWidget {
  const CollectionItineraryScreen({super.key, required this.collectionId});

  final String collectionId;

  @override
  State<CollectionItineraryScreen> createState() => _CollectionItineraryScreenState();
}

class _CollectionItineraryScreenState extends State<CollectionItineraryScreen> {
  String? selectedDayId;

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    final controller = AppScope.of(context).collectionsController;
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final collection = controller.byId(widget.collectionId);
        final days = collection.itinerary;
        final visibleDays = selectedDayId == null
            ? days
            : days.where((day) => day.id == selectedDayId).toList();
        return Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: Text(localization.t('itinerary')),
            actions: [
              IconButton(
                icon: const Icon(IconlyLight.plus),
                onPressed: days.isEmpty ? null : () => _openComposer(context, collection, days),
              ),
              const QuickSettingsButton(),
            ],
          ),
          floatingActionButton: days.isEmpty
              ? null
              : FloatingActionButton.extended(
                  onPressed: () => _openComposer(context, collection, days),
                  icon: const Icon(IconlyLight.plus),
                  label: Text(localization.t('addSlot')),
                ),
          body: days.isEmpty
              ? Center(child: Text(localization.t('itineraryEmpty')))
              : ListView(
                  padding: const EdgeInsets.all(24),
                  children: [
                    Text(collection.title, style: Theme.of(context).textTheme.headlineSmall),
                    const SizedBox(height: 8),
                    Text(localization.t('itineraryPlannerSubtitle')),
                    const SizedBox(height: 16),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          ChoiceChip(
                            label: Text(localization.t('itineraryAllDays')),
                            selected: selectedDayId == null,
                            onSelected: (_) => setState(() => selectedDayId = null),
                          ),
                          ...days.map((day) {
                            final label = MaterialLocalizations.of(context).formatMediumDate(day.date);
                            return Padding(
                              padding: const EdgeInsetsDirectional.only(start: 8),
                              child: ChoiceChip(
                                label: Text(label),
                                selected: selectedDayId == day.id,
                                onSelected: (_) => setState(() => selectedDayId = day.id),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...visibleDays.map(
                      (day) => _ItineraryDayCard(
                        day: day,
                        onAdd: () => _openComposer(context, collection, days, preselectDay: day.id),
                      ),
                    ),
                    const SizedBox(height: 80),
                  ],
                ),
        );
      },
    );
  }

  Future<void> _openComposer(
    BuildContext context,
    CollectionModel collection,
    List<ItineraryDayModel> days, {
    String? preselectDay,
  }) async {
    if (days.isEmpty) return;
    final localization = AppLocalizations.of(context);
    final controller = AppScope.of(context).collectionsController;
    final titleController = TextEditingController();
    final noteController = TextEditingController();
    final tags = const [
      ItineraryTags.experience,
      ItineraryTags.logistics,
      ItineraryTags.culinary,
      ItineraryTags.wellness,
      ItineraryTags.tech,
    ];
    var selectedDay = preselectDay ?? selectedDayId ?? days.first.id;
    var selectedTag = tags.first;
    var selectedTime = TimeOfDay.now();
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 24,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardTheme.color,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            ),
            padding: const EdgeInsets.all(24),
            child: StatefulBuilder(
              builder: (context, setSheetState) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(localization.t('addSlot'), style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: selectedDay,
                      decoration: InputDecoration(labelText: localization.t('slotDay')),
                      items: days
                          .map((day) => DropdownMenuItem(
                                value: day.id,
                                child: Text(MaterialLocalizations.of(context).formatMediumDate(day.date)),
                              ))
                          .toList(),
                      onChanged: (value) => setSheetState(() => selectedDay = value ?? selectedDay),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: titleController,
                      decoration: InputDecoration(labelText: localization.t('slotTitleHint')),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: noteController,
                      decoration: InputDecoration(labelText: localization.t('slotNoteHint')),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: selectedTag,
                            decoration: InputDecoration(labelText: localization.t('slotTag')),
                            items: tags
                                .map((tag) => DropdownMenuItem(
                                      value: tag,
                                      child: Text(localizedItineraryTag(tag, localization)),
                                    ))
                                .toList(),
                            onChanged: (value) => setSheetState(() => selectedTag = value ?? selectedTag),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              final time = await showTimePicker(
                                context: context,
                                initialTime: selectedTime,
                              );
                              if (time != null) {
                                setSheetState(() => selectedTime = time);
                              }
                            },
                            icon: const Icon(IconlyLight.time_circle),
                            label: Text(
                              '${localization.t('slotTime')}: '
                              '${MaterialLocalizations.of(context).formatTimeOfDay(selectedTime)}',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          if (titleController.text.isEmpty) return;
                          final slot = ItinerarySlotModel(
                            id: DateTime.now().millisecondsSinceEpoch.toString(),
                            title: titleController.text,
                            note: noteController.text,
                            time: selectedTime,
                            tag: selectedTag,
                          );
                          controller.addItinerarySlot(collection.id, selectedDay, slot);
                          Navigator.of(sheetContext).pop();
                          ScaffoldMessenger.of(context)
                              .showSnackBar(SnackBar(content: Text(localization.t('slotSaved'))));
                        },
                        child: Text(localization.t('addSlot')),
                      ),
                    )
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class _ItineraryDayCard extends StatelessWidget {
  const _ItineraryDayCard({required this.day, required this.onAdd});

  final ItineraryDayModel day;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        color: theme.cardTheme.color,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (day.cover.isNotEmpty) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: AspectRatio(
                aspectRatio: 16 / 7,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(day.cover, fit: BoxFit.cover),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.black.withOpacity(0.5), Colors.transparent],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                      ),
                    ),
                    Positioned(
                      left: 16,
                      bottom: 16,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            MaterialLocalizations.of(context).formatMediumDate(day.date),
                            style: theme.textTheme.labelLarge?.copyWith(color: Colors.white70),
                          ),
                          Text(day.focus,
                              style: theme.textTheme.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
          Row(
            children: [
              Expanded(child: Text('${localization.t('itineraryFocusLabel')}: ${day.focus}')),
              TextButton(onPressed: onAdd, child: Text(localization.t('addSlot')))
            ],
          ),
          const SizedBox(height: 12),
          ...day.slots.map((slot) => _ItinerarySlotTile(day: day, slot: slot)),
        ],
      ),
    );
  }
}

class _ItinerarySlotTile extends StatelessWidget {
  const _ItinerarySlotTile({required this.day, required this.slot});

  final ItineraryDayModel day;
  final ItinerarySlotModel slot;

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    final time = MaterialLocalizations.of(context).formatTimeOfDay(slot.time);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: Theme.of(context).colorScheme.surface.withOpacity(0.5),
      ),
      child: Row(
        children: [
          Column(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              Container(
                width: 2,
                height: 34,
                color: Theme.of(context).primaryColor.withOpacity(0.3),
              )
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(time, style: Theme.of(context).textTheme.labelMedium),
                Text(slot.title, style: Theme.of(context).textTheme.titleMedium),
                Text(slot.note, style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 8,
                  children: [
                    Chip(
                      label: Text(localizedItineraryTag(slot.tag, localization)),
                      backgroundColor: Theme.of(context).primaryColor.withOpacity(0.15),
                    ),
                    Chip(
                      label: Text(MaterialLocalizations.of(context).formatMediumDate(day.date)),
                      backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                    ),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
