import 'dart:math';

import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';

import '../../core/controllers/app_scope.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/utils/dummy_data.dart';

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  GalleryItem? selectedItem;
  bool showBack = false;

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    final controller = AppScope.of(context).galleryController;
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(localization.t('gallery')),
      ),
      body: AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          final items = controller.items;
          return Stack(
            children: [
              RefreshIndicator(
                onRefresh: () async {
                  await Future<void>.delayed(const Duration(milliseconds: 600));
                },
                child: CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Wrap(
                          spacing: 12,
                          children: [
                            ChoiceChip(
                              label: Text(localization.t('galleryFilterAll')),
                              selected: controller.filter == 'All',
                              onSelected: (_) => controller.filterBy('All'),
                            ),
                            ChoiceChip(
                              label: Text(localization.t('galleryFilterEvent')),
                              selected: controller.filter == 'By Event',
                              onSelected: (_) => controller.filterBy('By Event'),
                            ),
                            ChoiceChip(
                              label: Text(localization.t('galleryFilterFav')),
                              selected: controller.filter == 'Favourites',
                              onSelected: (_) => controller.filterBy('Favourites'),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 120),
                      sliver: SliverGrid(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final item = items[index];
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedItem = item;
                                  showBack = false;
                                });
                              },
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(28),
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    Image.network(item.image, fit: BoxFit.cover),
                                    Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [Colors.black.withOpacity(0.4), Colors.transparent],
                                          begin: Alignment.bottomCenter,
                                          end: Alignment.topCenter,
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: 8,
                                      right: 8,
                                      child: IconButton(
                                        onPressed: () => controller.toggleFavourite(item.id),
                                        icon: Icon(
                                          item.isFavourite ? IconlyBold.heart : IconlyLight.heart,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 16,
                                      left: 16,
                                      right: 16,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item.title,
                                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                          ),
                                          Text(
                                            '${localization.t('linkedTo')}: ${item.collectionId}',
                                            style: const TextStyle(color: Colors.white70, fontSize: 12),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                          childCount: items.length,
                        ),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.8,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (selectedItem != null)
                GestureDetector(
                  onTap: () => setState(() => selectedItem = null),
                  child: Container(
                    color: Colors.black54,
                    child: Center(
                      child: GestureDetector(
                        onTap: () => setState(() => showBack = !showBack),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 400),
                          transitionBuilder: (child, animation) {
                            final rotate = Tween(begin: pi, end: 0).animate(animation);
                            return AnimatedBuilder(
                              animation: rotate,
                              child: child,
                              builder: (context, child) => Transform(
                                transform: Matrix4.identity()
                                  ..setEntry(3, 2, 0.001)
                                  ..rotateY(rotate.value),
                                alignment: Alignment.center,
                                child: child,
                              ),
                            );
                          },
                          child: Container(
                            key: ValueKey(showBack),
                            width: MediaQuery.of(context).size.width * 0.8,
                            height: MediaQuery.of(context).size.height * 0.6,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(32),
                              color: Theme.of(context).cardTheme.color,
                            ),
                            padding: const EdgeInsets.all(24),
                            child: showBack
                                ? Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(selectedItem!.title,
                                          style: Theme.of(context).textTheme.headlineSmall),
                                      const SizedBox(height: 12),
                                      Text(selectedItem!.description),
                                      const Spacer(),
                                      Row(
                                        children: [
                                          const Icon(IconlyLight.location),
                                          const SizedBox(width: 8),
                                          Text('${localization.t('linkedTo')}: ${selectedItem!.collectionId}')
                                        ],
                                      ),
                                    ],
                                  )
                                : Column(
                                    children: [
                                      Expanded(
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(28),
                                          child: Image.network(selectedItem!.image, fit: BoxFit.cover),
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Text(selectedItem!.title,
                                          style: Theme.of(context).textTheme.headlineSmall),
                                      Text(selectedItem!.description),
                                      const SizedBox(height: 12),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const Icon(IconlyLight.heart, size: 16),
                                          const SizedBox(width: 6),
                                          Text(selectedItem!.isFavourite
                                              ? localization.t('favourites')
                                              : localization.t('galleryFilterAll')),
                                        ],
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
