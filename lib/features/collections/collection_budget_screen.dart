import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';

import '../../core/controllers/app_scope.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/utils/dummy_data.dart';
import '../../core/widgets/quick_settings_button.dart';

class CollectionBudgetScreen extends StatefulWidget {
  const CollectionBudgetScreen({super.key, required this.collectionId});

  final String collectionId;

  @override
  State<CollectionBudgetScreen> createState() => _CollectionBudgetScreenState();
}

class _CollectionBudgetScreenState extends State<CollectionBudgetScreen> {
  String _query = '';
  bool _pressureOnly = false;

  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _plannedController = TextEditingController();
  final TextEditingController _spentController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  @override
  void dispose() {
    _categoryController.dispose();
    _plannedController.dispose();
    _spentController.dispose();
    _noteController.dispose();
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
        final lines = controller.budgetLinesFor(widget.collectionId);
        final filtered = lines.where((line) {
          final matchesQuery = _query.isEmpty ||
              line.category.toLowerCase().contains(_query.toLowerCase()) ||
              line.note.toLowerCase().contains(_query.toLowerCase());
          final ratio = controller.budgetLineProgress(line);
          final isPressure = line.spent > line.planned || ratio >= 0.8;
          final matchesFilter = !_pressureOnly || isPressure;
          return matchesQuery && matchesFilter;
        }).toList();
        final overBudgetCount = lines.where((line) => line.spent > line.planned).length;
        final avgBurn = lines.isEmpty
            ? 0.0
            : lines
                    .map((line) => controller.budgetLineProgress(line))
                    .fold<double>(0, (previousValue, element) => previousValue + element) /
                lines.length;
        final progress = controller.budgetProgress(widget.collectionId);
        final variance = controller.totalBudgetVariance(widget.collectionId);
        return Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: Text(localization.t('budgetBoard')),
            actions: const [QuickSettingsButton()],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _openBudgetSheet(context),
            icon: const Icon(IconlyLight.plus),
            label: Text(localization.t('budgetAddLine')),
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 160),
            children: [
              Container(
                padding: const EdgeInsets.all(24),
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
                    Text(collection.title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white)),
                    const SizedBox(height: 4),
                    Text(
                      localization.t('budgetBoardSubtitle'),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                    ),
                    const SizedBox(height: 16),
                    LinearProgressIndicator(
                      value: progress,
                      minHeight: 8,
                      color: Colors.white,
                      backgroundColor: Colors.white24,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _BudgetSummaryStat(
                            label: localization.t('budgetBoardSummaryTracked'),
                            value: '${lines.length}',
                          ),
                        ),
                        Expanded(
                          child: _BudgetSummaryStat(
                            label: localization.t('budgetBoardSummaryOver'),
                            value: '$overBudgetCount',
                          ),
                        ),
                        Expanded(
                          child: _BudgetSummaryStat(
                            label: localization.t('budgetAvgBurn'),
                            value: '${(avgBurn * 100).round()}%',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      variance >= 0
                          ? '${localization.t('budgetOverBudget')} · +${variance.toStringAsFixed(0)}'
                          : '${localization.t('budgetRemaining')} · ${variance.abs().toStringAsFixed(0)}',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.white),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text(localization.t('budgetCategories'), style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 4),
              Text(localization.t('budgetAddDescription')),
              const SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  labelText: localization.t('budgetSearchHint'),
                  prefixIcon: const Icon(IconlyLight.search),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(28)),
                ),
                onChanged: (value) => setState(() => _query = value),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                children: [
                  FilterChip(
                    selected: !_pressureOnly,
                    label: Text(localization.t('budgetFilterAll')),
                    onSelected: (_) => setState(() => _pressureOnly = false),
                  ),
                  FilterChip(
                    selected: _pressureOnly,
                    label: Text(localization.t('budgetFilterPressure')),
                    onSelected: (_) => setState(() => _pressureOnly = true),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (filtered.isEmpty)
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(32),
                    color: Theme.of(context).cardTheme.color,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(localization.t('budgetLineEmpty'),
                          style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 8),
                      Text(localization.t('budgetLineEmptyHint')),
                    ],
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (_, index) {
                    final line = filtered[index];
                    final ratio = controller.budgetLineProgress(line);
                    final badge = line.spent > line.planned
                        ? localization.t('budgetOverLabel')
                        : (ratio >= 0.85 ? localization.t('budgetNearLabel') : null);
                    return _BudgetLineTile(
                      line: line,
                      ratio: ratio,
                      badge: badge,
                      localization: localization,
                      onEdit: () => _openBudgetSheet(context, line: line),
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

  void _openBudgetSheet(BuildContext context, {BudgetLineModel? line}) {
    final localization = AppLocalizations.of(context);
    if (line == null) {
      _categoryController.clear();
      _plannedController.clear();
      _spentController.clear();
      _noteController.clear();
    } else {
      _categoryController.text = line.category;
      _plannedController.text = line.planned.toStringAsFixed(0);
      _spentController.text = line.spent.toStringAsFixed(0);
      _noteController.text = line.note;
    }
    final isEditing = line != null;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(32),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        isEditing ? localization.t('budgetSaveLine') : localization.t('budgetAddLine'),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(IconlyLight.close_square),
                      onPressed: () => Navigator.of(context).pop(),
                    )
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _categoryController,
                  decoration: InputDecoration(labelText: localization.t('budgetCategoryField')),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _plannedController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: localization.t('budgetPlannedField')),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _spentController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: localization.t('budgetSpentField')),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _noteController,
                  decoration: InputDecoration(labelText: localization.t('budgetNoteField')),
                  maxLines: 2,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      final category = _categoryController.text.trim();
                      if (category.isEmpty) {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(SnackBar(content: Text(localization.t('requiredField'))));
                        return;
                      }
                      final planned = double.tryParse(_plannedController.text) ?? 0;
                      final spent = double.tryParse(_spentController.text) ?? 0;
                      final note = _noteController.text.trim();
                      final controller = AppScope.of(context).collectionsController;
                      if (isEditing) {
                        controller.updateBudgetLine(
                          widget.collectionId,
                          line!.id,
                          planned: planned,
                          spent: spent,
                          note: note,
                          category: category,
                        );
                        ScaffoldMessenger.of(context)
                            .showSnackBar(SnackBar(content: Text(localization.t('budgetLineUpdated'))));
                      } else {
                        controller.addBudgetLine(
                          widget.collectionId,
                          BudgetLineModel(
                            id: 'b${DateTime.now().millisecondsSinceEpoch}',
                            category: category,
                            planned: planned,
                            spent: spent,
                            note: note,
                          ),
                        );
                        ScaffoldMessenger.of(context)
                            .showSnackBar(SnackBar(content: Text(localization.t('budgetLineAdded'))));
                      }
                      Navigator.of(context).pop();
                    },
                    child: Text(localization.t('budgetSaveLine')),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}

class _BudgetLineTile extends StatelessWidget {
  const _BudgetLineTile({
    required this.line,
    required this.localization,
    required this.ratio,
    required this.onEdit,
    this.badge,
  });

  final BudgetLineModel line;
  final AppLocalizations localization;
  final double ratio;
  final VoidCallback onEdit;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    final isOver = line.spent > line.planned;
    return InkWell(
      onTap: onEdit,
      borderRadius: BorderRadius.circular(28),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          color: Theme.of(context).cardTheme.color,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(line.category, style: Theme.of(context).textTheme.titleMedium),
                ),
                if (badge != null)
                  Chip(
                    label: Text(badge!),
                    backgroundColor:
                        isOver ? Colors.red.withOpacity(0.15) : Theme.of(context).primaryColor.withOpacity(0.15),
                  ),
                IconButton(
                  onPressed: onEdit,
                  icon: const Icon(IconlyLight.edit_square),
                ),
              ],
            ),
            if (line.note.isNotEmpty) ...[
              Text(line.note, style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 6),
            ],
            LinearProgressIndicator(
              value: ratio,
              minHeight: 6,
              backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text('${localization.t('budgetPlanned')}: ${line.planned.toStringAsFixed(0)}',
                      style: Theme.of(context).textTheme.labelMedium),
                ),
                Expanded(
                  child: Text('${localization.t('budgetUsed')}: ${line.spent.toStringAsFixed(0)}',
                      style: Theme.of(context).textTheme.labelMedium),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BudgetSummaryStat extends StatelessWidget {
  const _BudgetSummaryStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white)),
        Text(label, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.white70)),
      ],
    );
  }
}
