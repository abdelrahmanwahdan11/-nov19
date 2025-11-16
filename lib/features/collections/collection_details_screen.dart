import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';

import '../../core/constants/app_assets.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/utils/dummy_data.dart';

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
    final collection = DummyData.collections.firstWhere((c) => c.id == widget.collectionId);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: NestedScrollView(
        headerSliverBuilder: (_, __) {
          return [
            SliverAppBar(
              expandedHeight: 320,
              pinned: true,
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
            _TasksTab(collection: collection),
            _MediaTab(collection: collection),
          ],
        ),
      ),
    );
  }
}

class _SummaryTab extends StatelessWidget {
  const _SummaryTab({required this.collection});
  final CollectionModel collection;

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
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
        )
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

class _TasksTab extends StatefulWidget {
  const _TasksTab({required this.collection});
  final CollectionModel collection;

  @override
  State<_TasksTab> createState() => _TasksTabState();
}

class _TasksTabState extends State<_TasksTab> {
  late List<TaskModel> tasks;

  @override
  void initState() {
    super.initState();
    tasks = widget.collection.tasks;
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
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
                subtitle: Text(task.subtitle),
                trailing: Checkbox(
                  value: task.completed,
                  onChanged: (value) {
                    setState(() {
                      tasks = tasks
                          .map((e) => e.id == task.id ? e.copyWith(completed: value ?? false) : e)
                          .toList();
                    });
                  },
                ),
              ),
            ),
          ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: () {
            setState(() {
              tasks = [
                ...tasks,
                TaskModel(
                  id: DateTime.now().toIso8601String(),
                  title: localization.t('newTask'),
                  subtitle: localization.t('localAddition'),
                  date: DateTime.now(),
                  assignee: 'AI',
                )
              ];
            });
          },
          icon: const Icon(IconlyLight.plus),
          label: Text(localization.t('addTask')),
        )
      ],
    );
  }
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
