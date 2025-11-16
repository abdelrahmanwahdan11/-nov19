import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';

import '../../core/controllers/app_scope.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/widgets/skeleton_box.dart';

class CollectionsScreen extends StatefulWidget {
  const CollectionsScreen({super.key});

  @override
  State<CollectionsScreen> createState() => _CollectionsScreenState();
}

class _CollectionsScreenState extends State<CollectionsScreen> {
  final _scrollController = ScrollController();
  final List<String> tabs = const ['All', 'Trip', 'Party', 'Anniversary'];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final controller = AppScope.of(context).collectionsController;
    if (_scrollController.position.pixels > _scrollController.position.maxScrollExtent - 200) {
      controller.loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    final controllers = AppScope.of(context);
    final collectionsController = controllers.collectionsController;
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(localization.t('collections')),
        actions: [
          IconButton(
            icon: const Icon(IconlyLight.setting),
            onPressed: () => Navigator.of(context).pushNamed('/settings'),
          )
        ],
      ),
      body: RefreshIndicator(
        onRefresh: collectionsController.refresh,
        child: AnimatedBuilder(
          animation: collectionsController,
          builder: (context, _) {
            final items = collectionsController.visible;
            return ListView(
              controller: _scrollController,
              padding: const EdgeInsets.all(24),
              children: [
                TextField(
                  decoration: InputDecoration(
                    hintText: localization.t('searchCollections'),
                    prefixIcon: const Icon(IconlyLight.search),
                    suffixIcon: IconButton(
                      icon: const Icon(IconlyLight.filter),
                      onPressed: () => Navigator.of(context).pushNamed('/catalog'),
                    ),
                  ),
                  onChanged: collectionsController.search,
                ),
                const SizedBox(height: 16),
                final labels = {
                  'All': localization.t('galleryFilterAll'),
                  'Trip': localization.t('upcomingTrip'),
                  'Party': localization.t('partyEvent'),
                  'Anniversary': localization.t('anniversary'),
                };
                Wrap(
                  spacing: 12,
                  children: tabs
                      .map((type) => ChoiceChip(
                            label: Text(labels[type] ?? type),
                            selected: collectionsController.typeFilter == type,
                            onSelected: (_) => collectionsController.filterByType(type),
                          ))
                      .toList(),
                ),
                const SizedBox(height: 24),
                if (collectionsController.isLoading)
                  Column(
                    children: const [
                      SkeletonBox(height: 120),
                      SizedBox(height: 12),
                      SkeletonBox(height: 120),
                    ],
                  )
                else ...items.map((collection) => _CollectionTile(collection: collection)),
                if (collectionsController.isPaginating)
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                const SizedBox(height: 80),
                ElevatedButton.icon(
                  onPressed: collectionsController.compareSelection.isNotEmpty
                      ? () => Navigator.of(context).pushNamed('/compare')
                      : null,
                  icon: const Icon(IconlyLight.paper_negative),
                  label: Text(localization.t('compare')),
                )
              ],
            );
          },
        ),
      ),
    );
  }
}

class _CollectionTile extends StatelessWidget {
  const _CollectionTile({required this.collection});
  final CollectionModel collection;

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context).collectionsController;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        color: Theme.of(context).cardTheme.color,
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Image.network(collection.images.first, width: 80, height: 80, fit: BoxFit.cover),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(collection.title, style: Theme.of(context).textTheme.titleMedium),
                Text(collection.description, maxLines: 2, overflow: TextOverflow.ellipsis),
                Text(collection.location, style: Theme.of(context).textTheme.labelMedium),
              ],
            ),
          ),
          Column(
            children: [
              IconButton(
                icon: Icon(collection.isFavourite ? IconlyBold.heart : IconlyLight.heart),
                onPressed: () => controller.toggleFavourite(collection.id),
              ),
              Checkbox(
                value: controller.compareSelection.contains(collection.id),
                onChanged: (_) => controller.toggleCompare(collection.id),
              ),
            ],
          )
        ],
      ),
    );
  }
}
