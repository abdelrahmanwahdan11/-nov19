import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';

import '../../core/constants/app_assets.dart';
import '../../core/controllers/app_scope.dart';
import '../../core/controllers/collections_controller.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/utils/dummy_data.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/quick_settings_button.dart';

class CollectionDocumentsScreen extends StatefulWidget {
  const CollectionDocumentsScreen({super.key, required this.collectionId});

  final String collectionId;

  @override
  State<CollectionDocumentsScreen> createState() => _CollectionDocumentsScreenState();
}

class _CollectionDocumentsScreenState extends State<CollectionDocumentsScreen> {
  DocumentStatus? _statusFilter;
  String? _categoryFilter;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    final controller = AppScope.of(context).collectionsController;
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final collection = controller.byId(widget.collectionId);
        final documents = controller.documentsFor(collection.id);
        final categories = documents.map((doc) => doc.category).toSet();
        final query = _searchController.text.trim().toLowerCase();
        var filtered = documents.where((doc) {
          final matchesQuery = query.isEmpty ||
              doc.title.toLowerCase().contains(query) ||
              doc.category.toLowerCase().contains(query) ||
              doc.owner.toLowerCase().contains(query);
          final matchesStatus = _statusFilter == null || doc.status == _statusFilter;
          final matchesCategory = _categoryFilter == null ||
              _categoryFilter == 'All' ||
              doc.category == _categoryFilter;
          return matchesQuery && matchesStatus && matchesCategory;
        }).toList();
        filtered.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
        final summary = controller.documentStatusSummary(collection.id);
        return Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: Text(localization.t('documentsScreenTitle')),
            actions: const [QuickSettingsButton()],
          ),
          body: RefreshIndicator(
            onRefresh: controller.refresh,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 140),
              children: [
                Text(collection.title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 6),
                Text(
                  localization.t('documentsSectionHint'),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white70),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: localization.t('documentsSearchHint'),
                    prefixIcon: const Icon(IconlyLight.search),
                    suffixIcon: _searchController.text.isEmpty
                        ? null
                        : IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {});
                            },
                          ),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 16),
                Text(localization.t('documentsStatusFilter'), style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ChoiceChip(
                      label: Text(localization.t('documentsFilterAll')),
                      selected: _statusFilter == null,
                      onSelected: (_) => setState(() => _statusFilter = null),
                    ),
                    ...DocumentStatus.values.map((status) {
                      final selected = _statusFilter == status;
                      return ChoiceChip(
                        label: Text(_statusLabel(status, localization)),
                        selected: selected,
                        onSelected: (_) => setState(() => _statusFilter = selected ? null : status),
                      );
                    })
                  ],
                ),
                const SizedBox(height: 20),
                Text(localization.t('documentsCategoryFilter'), style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ChoiceChip(
                      label: Text(localization.t('documentsFilterAll')),
                      selected: _categoryFilter == null || _categoryFilter == 'All',
                      onSelected: (_) => setState(() => _categoryFilter = null),
                    ),
                    ...categories.map((category) {
                      final selected = _categoryFilter == category;
                      return ChoiceChip(
                        label: Text(category),
                        selected: selected,
                        onSelected: (_) => setState(() => _categoryFilter = selected ? null : category),
                      );
                    }),
                  ],
                ),
                const SizedBox(height: 24),
                _DocumentSummaryRow(summary: summary),
                const SizedBox(height: 16),
                if (filtered.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28),
                      color: Theme.of(context).cardTheme.color,
                    ),
                    child: Column(
                      children: [
                        const Icon(IconlyLight.paper, size: 32),
                        const SizedBox(height: 8),
                        Text(localization.t('documentsEmpty'), textAlign: TextAlign.center),
                      ],
                    ),
                  )
                else
                  ...filtered.map((doc) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _DocumentTile(
                          document: doc,
                          localization: localization,
                          onStatusChange: (status) => controller.updateDocumentStatus(collection.id, doc.id, status),
                        ),
                      )),
                const SizedBox(height: 24),
                PrimaryButton(
                  label: localization.t('documentsAdd'),
                  onPressed: () => _openComposer(context, controller),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _statusLabel(DocumentStatus status, AppLocalizations localization) {
    switch (status) {
      case DocumentStatus.draft:
        return localization.t('documentsStatusDraft');
      case DocumentStatus.review:
        return localization.t('documentsStatusReview');
      case DocumentStatus.approved:
        return localization.t('documentsStatusApproved');
    }
  }

  Future<void> _openComposer(
    BuildContext context,
    CollectionsController controller,
  ) async {
    final localization = AppLocalizations.of(context);
    final titleController = TextEditingController();
    final ownerController = TextEditingController(text: localization.t('documentsOwnerPlanner'));
    final categoryController = TextEditingController(text: localization.t('documentsCategoryGeneral'));
    DocumentStatus selectedStatus = DocumentStatus.review;
    double size = 2.0;
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.98),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                top: 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 48,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    Text(localization.t('documentsComposerTitle'), style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 16),
                    TextField(
                      controller: titleController,
                      decoration: InputDecoration(labelText: localization.t('documentsTitleHint')),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: ownerController,
                      decoration: InputDecoration(labelText: localization.t('documentsOwnerHint')),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: categoryController,
                      decoration: InputDecoration(labelText: localization.t('documentsCategoryHint')),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<DocumentStatus>(
                      value: selectedStatus,
                      decoration: InputDecoration(labelText: localization.t('documentsStatusFilter')),
                      items: DocumentStatus.values
                          .map(
                            (status) => DropdownMenuItem(
                              value: status,
                              child: Text(_statusLabel(status, localization)),
                            ),
                          )
                          .toList(),
                      onChanged: (value) => setSheetState(() {
                        selectedStatus = value ?? DocumentStatus.review;
                      }),
                    ),
                    const SizedBox(height: 12),
                    Text('${localization.t('documentsSizeLabel')} ${size.toStringAsFixed(1)} MB'),
                    Slider(
                      min: 0.5,
                      max: 8,
                      divisions: 15,
                      value: size,
                      onChanged: (value) => setSheetState(() => size = value),
                    ),
                    const SizedBox(height: 20),
                    PrimaryButton(
                      label: localization.t('documentsSave'),
                      onPressed: () {
                        if (titleController.text.trim().isEmpty) return;
                        Navigator.of(context).pop(true);
                      },
                    )
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    if (saved == true) {
      controller.addDocument(
        widget.collectionId,
        DocumentModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: titleController.text.trim(),
          category: categoryController.text.trim().isEmpty
              ? localization.t('documentsCategoryGeneral')
              : categoryController.text.trim(),
          owner: ownerController.text.trim().isEmpty
              ? localization.t('documentsOwnerPlanner')
              : ownerController.text.trim(),
          updatedAt: DateTime.now(),
          status: selectedStatus,
          preview: AppAssets.docPlaceholder,
          sizeMb: double.parse(size.toStringAsFixed(1)),
        ),
      );
      setState(() {});
    }

    titleController.dispose();
    ownerController.dispose();
    categoryController.dispose();
  }
}

class _DocumentSummaryRow extends StatelessWidget {
  const _DocumentSummaryRow({required this.summary});

  final Map<DocumentStatus, int> summary;

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        color: Theme.of(context).cardTheme.color,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(localization.t('documentsPeekTitle'), style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(localization.t('documentsPeekSubtitle')),
          const SizedBox(height: 12),
          Row(
            children: DocumentStatus.values
                .map(
                  (status) => Expanded(
                    child: Column(
                      children: [
                        Text('${summary[status] ?? 0}',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(fontWeight: FontWeight.w700)),
                        Text(
                          _label(status, localization),
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          )
        ],
      ),
    );
  }

  String _label(DocumentStatus status, AppLocalizations localization) {
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

class _DocumentTile extends StatelessWidget {
  const _DocumentTile({
    required this.document,
    required this.localization,
    required this.onStatusChange,
  });

  final DocumentModel document;
  final AppLocalizations localization;
  final ValueChanged<DocumentStatus> onStatusChange;

  @override
  Widget build(BuildContext context) {
    final updatedLabel = MaterialLocalizations.of(context).formatShortDate(document.updatedAt);
    return Container(
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
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.network(document.preview, width: 70, height: 70, fit: BoxFit.cover),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(document.title, style: Theme.of(context).textTheme.titleMedium),
                    Text('${localization.t('documentsOwnerLabel')} ${document.owner}',
                        style: Theme.of(context).textTheme.bodySmall),
                    Wrap(
                      spacing: 8,
                      children: [
                        Chip(
                          label: Text(document.category),
                          backgroundColor: Theme.of(context).primaryColor.withOpacity(0.12),
                        ),
                        Chip(
                          label: Text(_statusLabel(document.status, localization)),
                          backgroundColor: _statusColor(context, document.status),
                        ),
                      ],
                    )
                  ],
                ),
              ),
              PopupMenuButton<DocumentStatus>(
                icon: const Icon(Icons.more_horiz),
                onSelected: onStatusChange,
                itemBuilder: (context) => DocumentStatus.values
                    .map(
                      (status) => PopupMenuItem(
                        value: status,
                        child: Text(_statusLabel(status, localization)),
                      ),
                    )
                    .toList(),
              )
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(IconlyLight.time_circle, size: 16),
              const SizedBox(width: 6),
              Text('${localization.t('documentsUpdatedLabel')} $updatedLabel'),
              const SizedBox(width: 12),
              const Icon(IconlyLight.folder, size: 16),
              const SizedBox(width: 6),
              Text('${document.sizeMb.toStringAsFixed(1)} MB'),
            ],
          )
        ],
      ),
    );
  }

  String _statusLabel(DocumentStatus status, AppLocalizations localization) {
    switch (status) {
      case DocumentStatus.draft:
        return localization.t('documentsStatusDraft');
      case DocumentStatus.review:
        return localization.t('documentsStatusReview');
      case DocumentStatus.approved:
        return localization.t('documentsStatusApproved');
    }
  }

  Color _statusColor(BuildContext context, DocumentStatus status) {
    switch (status) {
      case DocumentStatus.draft:
        return Colors.orange.withOpacity(0.18);
      case DocumentStatus.review:
        return Theme.of(context).primaryColor.withOpacity(0.2);
      case DocumentStatus.approved:
        return Colors.green.withOpacity(0.2);
    }
  }
}
