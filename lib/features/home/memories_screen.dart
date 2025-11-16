import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';

import '../../core/controllers/app_scope.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/utils/dummy_data.dart';
import '../../core/widgets/quick_settings_button.dart';

class MemoriesScreen extends StatefulWidget {
  const MemoriesScreen({super.key});

  @override
  State<MemoriesScreen> createState() => _MemoriesScreenState();
}

class _MemoriesScreenState extends State<MemoriesScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ValueNotifier<String> _query = ValueNotifier('');
  final ValueNotifier<JournalMood?> _moodFilter = ValueNotifier(null);

  @override
  void dispose() {
    _searchController.dispose();
    _query.dispose();
    _moodFilter.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    final controllers = AppScope.of(context);
    final listenable = Listenable.merge([
      controllers.collectionsController,
      _query,
      _moodFilter,
    ]);

    return AnimatedBuilder(
      animation: listenable,
      builder: (context, _) {
        final filtered = controllers.collectionsController
            .memories(query: _query.value, mood: _moodFilter.value);
        final moodSummary = controllers.collectionsController.memoryMoodSummary();
        return Scaffold(
          appBar: AppBar(
            title: Text(localization.t('memoriesTitle')),
            actions: const [QuickSettingsButton()],
          ),
          body: RefreshIndicator(
            onRefresh: controllers.collectionsController.refreshMemories,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 48),
              children: [
                Text(
                  localization.t('memoriesSubtitle'),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _searchController,
                  onChanged: (value) => _query.value = value,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(IconlyLight.search),
                    hintText: localization.t('memoriesSearch'),
                    suffixIcon: _searchController.text.isEmpty
                        ? null
                        : IconButton(
                            icon: const Icon(IconlyLight.close_square),
                            onPressed: () {
                              _searchController.clear();
                              _query.value = '';
                            },
                          ),
                  ),
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          selected: _moodFilter.value == null,
                          label: Text(localization.t('memoriesMoodAll')),
                          onSelected: (_) => _moodFilter.value = null,
                        ),
                      ),
                      ...JournalMood.values.map(
                        (mood) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            selected: _moodFilter.value == mood,
                            label: Text(_moodLabel(localization, mood)),
                            onSelected: (_) => _moodFilter.value =
                                _moodFilter.value == mood ? null : mood,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _MoodSummaryRow(moodSummary: moodSummary),
                const SizedBox(height: 24),
                if (filtered.isEmpty)
                  _EmptyMemoriesState(message: localization.t('memoriesEmpty'))
                else
                  ...filtered.map(
                    (memory) => Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: _MemoryCard(
                        memory: memory,
                        collection: controllers.collectionsController
                            .byId(memory.collectionId),
                        onToggleFavourite: () => controllers.collectionsController
                            .toggleMemoryFavourite(memory.id),
                      ),
                    ),
                  ),
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
}

class _MoodSummaryRow extends StatelessWidget {
  const _MoodSummaryRow({required this.moodSummary});

  final Map<JournalMood, int> moodSummary;

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    final cards = JournalMood.values
        .map(
          (mood) => Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.symmetric(horizontal: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                color: Theme.of(context).cardTheme.color,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    localization.t('moodPulse'),
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                  Text(
                    _label(localization, mood),
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${moodSummary[mood] ?? 0} ${localization.t('memoriesCountLabel')}',
                    style: Theme.of(context).textTheme.labelMedium,
                  )
                ],
              ),
            ),
          ),
        )
        .toList();

    return Row(children: cards);
  }

  String _label(AppLocalizations localization, JournalMood mood) {
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

class _MemoryCard extends StatelessWidget {
  const _MemoryCard({
    required this.memory,
    required this.collection,
    required this.onToggleFavourite,
  });

  final MemoryHighlightModel memory;
  final CollectionModel collection;
  final VoidCallback onToggleFavourite;

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        color: theme.cardTheme.color,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            child: Image.network(
              memory.image,
              height: 220,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            collection.title,
                            style: theme.textTheme.labelMedium,
                          ),
                          Text(
                            memory.title,
                            style: theme.textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: onToggleFavourite,
                      icon: Icon(
                        memory.isFavourite
                            ? IconlyBold.heart
                            : IconlyLight.heart,
                        color:
                            memory.isFavourite ? theme.primaryColor : theme.iconTheme.color,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  memory.description,
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(IconlyLight.location, size: 18, color: theme.primaryColor),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        memory.location,
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                    Text(
                      '${memory.date.day}/${memory.date.month}',
                      style: theme.textTheme.labelSmall,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    Chip(
                      avatar: const Icon(IconlyLight.smile, size: 18),
                      label: Text(_moodLabel(localization, memory.mood)),
                    ),
                    ActionChip(
                      avatar: const Icon(IconlyLight.paper),
                      label: Text(localization.t('memoryOpenCollection')),
                      onPressed: () => Navigator.of(context)
                          .pushNamed('/collection_details', arguments: collection.id),
                    ),
                    ActionChip(
                      avatar: const Icon(IconlyLight.image),
                      label: Text(localization.t('openMemoriesGallery')),
                      onPressed: () => Navigator.of(context)
                          .pushNamed('/gallery'),
                    ),
                  ],
                )
              ],
            ),
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

class _EmptyMemoriesState extends StatelessWidget {
  const _EmptyMemoriesState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        color: Theme.of(context).cardTheme.color,
      ),
      child: Column(
        children: [
          Icon(IconlyLight.image, size: 48, color: Theme.of(context).primaryColor),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
