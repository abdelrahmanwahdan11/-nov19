import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';

import '../../core/constants/app_assets.dart';
import '../../core/controllers/app_scope.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/utils/dummy_data.dart';
import '../../core/widgets/quick_settings_button.dart';

class CollectionJournalScreen extends StatefulWidget {
  const CollectionJournalScreen({super.key, required this.collectionId});

  final String collectionId;

  @override
  State<CollectionJournalScreen> createState() => _CollectionJournalScreenState();
}

class _CollectionJournalScreenState extends State<CollectionJournalScreen> {
  final _titleController = TextEditingController();
  final _noteController = TextEditingController();
  JournalMood _selectedMood = JournalMood.excited;

  @override
  void dispose() {
    _titleController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controllers = AppScope.of(context);
    final localization = AppLocalizations.of(context);
    final collections = controllers.collectionsController;
    return AnimatedBuilder(
      animation: collections,
      builder: (context, _) {
        final collection = collections.byId(widget.collectionId);
        final entries = collections.journalFor(widget.collectionId);
        final moodSummary = collections.journalMoodSummary(widget.collectionId);
        return Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: Text(localization.t('journal')),
            actions: [
              IconButton(
                onPressed: () => _openComposer(context),
                icon: const Icon(IconlyLight.plus),
                tooltip: localization.t('addHighlight'),
              ),
              const QuickSettingsButton(),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _openComposer(context),
            icon: const Icon(IconlyLight.edit),
            label: Text(localization.t('addHighlight')),
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 120),
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(32),
                  color: Theme.of(context).cardTheme.color,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(28),
                      child: Stack(
                        children: [
                          Image.network(
                            collection.images.first,
                            height: 140,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                          Positioned.fill(
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Colors.black.withOpacity(0.6), Colors.transparent],
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 16,
                            left: 16,
                            right: 16,
                            child: Text(
                              localization.t('journalSubtitle'),
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(color: Colors.white),
                            ),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(localization.t('todayMood'), style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      children: JournalMood.values
                          .map(
                            (mood) => Chip(
                              label: Text('${_moodLabel(localization, mood)} · ${moodSummary[mood] ?? 0}'),
                              avatar: Icon(_moodIcon(mood), size: 18),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text(localization.t('recentMemories'), style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              if (entries.isEmpty)
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28),
                    color: Theme.of(context).cardTheme.color,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(localization.t('journalEmpty'), style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 8),
                      Text(localization.t('journalEmptyDescription')),
                    ],
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (_, index) {
                    final entry = entries[index];
                    return _JournalEntryCard(
                      entry: entry,
                      collectionTitle: collection.title,
                      localization: localization,
                    );
                  },
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemCount: entries.length,
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
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
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
                Text(localization.t('addHighlight'), style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 12),
                TextField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: localization.t('title'),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _noteController,
                  minLines: 3,
                  maxLines: 5,
                  decoration: InputDecoration(
                    hintText: localization.t('entryHint'),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  children: JournalMood.values
                      .map(
                        (mood) => ChoiceChip(
                          label: Text(_moodLabel(localization, mood)),
                          selected: _selectedMood == mood,
                          onSelected: (_) {
                            setState(() => _selectedMood = mood);
                          },
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () {
                    final title = _titleController.text.trim();
                    final note = _noteController.text.trim();
                    if (title.isEmpty || note.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(localization.t('requiredField'))),
                      );
                      return;
                    }
                    final entry = JournalEntryModel(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      title: title,
                      note: note,
                      date: DateTime.now(),
                      mood: _selectedMood,
                      image: AppAssets.journalOverlay,
                    );
                    AppScope.of(context)
                        .collectionsController
                        .addJournalEntry(widget.collectionId, entry);
                    _titleController.clear();
                    _noteController.clear();
                    if (mounted) {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(localization.t('journalSaved'))),
                      );
                    }
                  },
                  child: Text(localization.t('save')),
                )
              ],
            ),
          ),
        );
      },
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

  IconData _moodIcon(JournalMood mood) {
    switch (mood) {
      case JournalMood.calm:
        return IconlyLight.game;
      case JournalMood.focused:
        return IconlyLight.paper;
      default:
        return IconlyLight.star;
    }
  }
}

class _JournalEntryCard extends StatelessWidget {
  const _JournalEntryCard({
    required this.entry,
    required this.collectionTitle,
    required this.localization,
  });

  final JournalEntryModel entry;
  final String collectionTitle;
  final AppLocalizations localization;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        color: Theme.of(context).cardTheme.color,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Image.network(entry.image, width: 90, height: 90, fit: BoxFit.cover),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(entry.title, style: Theme.of(context).textTheme.titleMedium),
                Text(collectionTitle, style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 6),
                Text(entry.note, maxLines: 3, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Chip(label: Text('${localization.t('mood')}: ${_moodLabel(localization, entry.mood)}')),
                    const Spacer(),
                    Text('${entry.date.day}/${entry.date.month}',
                        style: Theme.of(context).textTheme.labelSmall),
                  ],
                )
              ],
            ),
          )
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
