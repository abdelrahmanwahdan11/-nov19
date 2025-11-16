import 'dart:async';

import 'package:flutter/material.dart';

import '../utils/debouncer.dart';
import '../utils/dummy_data.dart';

class CollectionsController extends ChangeNotifier {
  CollectionsController() {
    _visible = [];
    _isLoading = true;
    Future.microtask(() async {
      await Future<void>.delayed(const Duration(milliseconds: 400));
      _visible = List.from(DummyData.collections);
      _isLoading = false;
      notifyListeners();
    });
  }

  List<CollectionModel> _visible = [];
  final Debouncer _debouncer = Debouncer(duration: const Duration(milliseconds: 400));
  bool _isLoading = false;
  bool _isPaginating = false;
  String _query = '';
  String _typeFilter = 'All';
  String _sortOption = 'Newest';
  bool _favouriteOnly = false;
  DateTimeRange? _dateRange;
  final Set<String> _compareSelection = {};

  List<CollectionModel> get visible => _visible;
  bool get isLoading => _isLoading;
  bool get isPaginating => _isPaginating;
  Set<String> get compareSelection => _compareSelection;
  String get typeFilter => _typeFilter;
  String get sortOption => _sortOption;
  bool get favouriteOnly => _favouriteOnly;
  DateTimeRange? get dateRange => _dateRange;

  int get favouriteCount => DummyData.collections.where((c) => c.isFavourite).length;
  int get upcomingTasksCount => DummyData.collections
      .expand((collection) => collection.tasks)
      .where((task) => task.date.isAfter(DateTime.now()) &&
          task.date.isBefore(DateTime.now().add(const Duration(days: 7))))
      .length;
  int get activeCollections => _visible.length;

  CollectionModel byId(String id) => DummyData.collections.firstWhere((element) => element.id == id);

  List<TaskModel> tasksFor(String id) => byId(id).tasks;
  List<MilestoneModel> milestonesFor(String id) => byId(id).milestones;
  List<JournalEntryModel> journalFor(String id) => byId(id).journalEntries;
  List<ItineraryDayModel> itineraryFor(String id) => byId(id).itinerary;
  List<GuestModel> guestsFor(String id) => byId(id).guests;
  List<VendorModel> vendorsFor(String id) => byId(id).vendors;
  List<LogisticItemModel> logisticsFor(String id) => byId(id).logistics;
  List<BudgetLineModel> budgetLinesFor(String id) => byId(id).budgetLines;
  List<DocumentModel> documentsFor(String id) => byId(id).documents;
  List<MemoryHighlightModel> memoriesForCollection(String id) =>
      DummyData.memories.where((element) => element.collectionId == id).toList();

  List<MemoryHighlightModel> latestMemories([int take = 5]) {
    final ordered = [...DummyData.memories]..sort((a, b) => b.date.compareTo(a.date));
    return ordered.take(take).toList();
  }

  List<MemoryHighlightModel> memories({String query = '', JournalMood? mood}) {
    Iterable<MemoryHighlightModel> items = DummyData.memories;
    if (query.isNotEmpty) {
      final lower = query.toLowerCase();
      items = items.where((memory) =>
          memory.title.toLowerCase().contains(lower) ||
          memory.description.toLowerCase().contains(lower) ||
          memory.location.toLowerCase().contains(lower));
    }
    if (mood != null) {
      items = items.where((element) => element.mood == mood);
    }
    final sorted = [...items]..sort((a, b) => b.date.compareTo(a.date));
    return sorted;
  }

  Map<JournalMood, int> memoryMoodSummary() {
    final summary = {for (final mood in JournalMood.values) mood: 0};
    for (final memory in DummyData.memories) {
      summary[memory.mood] = (summary[memory.mood] ?? 0) + 1;
    }
    return summary;
  }

  Map<GuestStatus, int> guestStatusSummary(String id) {
    final guests = guestsFor(id);
    final summary = {for (final status in GuestStatus.values) status: 0};
    for (final guest in guests) {
      summary[guest.status] = (summary[guest.status] ?? 0) + 1;
    }
    return summary;
  }

  int confirmedGuests(String id) => guestStatusSummary(id)[GuestStatus.confirmed] ?? 0;

  Map<VendorStatus, int> vendorStatusSummary(String id) {
    final vendors = vendorsFor(id);
    final summary = {for (final status in VendorStatus.values) status: 0};
    for (final vendor in vendors) {
      summary[vendor.status] = (summary[vendor.status] ?? 0) + 1;
    }
    return summary;
  }

  double vendorTotalCost(String id) => vendorsFor(id).fold(0, (sum, vendor) => sum + vendor.cost);

  Map<LogisticsStatus, int> logisticsStatusSummary(String id) {
    final logistics = logisticsFor(id);
    final summary = {for (final status in LogisticsStatus.values) status: 0};
    for (final item in logistics) {
      summary[item.status] = (summary[item.status] ?? 0) + 1;
    }
    return summary;
  }

  Map<DocumentStatus, int> documentStatusSummary(String id) {
    final documents = documentsFor(id);
    final summary = {for (final status in DocumentStatus.values) status: 0};
    for (final document in documents) {
      summary[document.status] = (summary[document.status] ?? 0) + 1;
    }
    return summary;
  }

  int pendingDocumentCount(String id) {
    final summary = documentStatusSummary(id);
    return (summary[DocumentStatus.draft] ?? 0) + (summary[DocumentStatus.review] ?? 0);
  }

  LogisticItemModel? nextLogistic(String id) {
    final items = logisticsFor(id)
        .where((item) => item.start.isAfter(DateTime.now().subtract(const Duration(hours: 3))))
        .toList()
      ..sort((a, b) => a.start.compareTo(b.start));
    if (items.isEmpty) return null;
    return items.first;
  }

  double budgetProgress(String id) {
    final collection = byId(id);
    if (collection.budgetPlanned == 0) return 0;
    return (collection.budgetUsed / collection.budgetPlanned).clamp(0, 1);
  }

  double budgetLineProgress(BudgetLineModel line) {
    if (line.planned == 0) return 0;
    return (line.spent / line.planned).clamp(0, 1);
  }

  double completionRate(String id) {
    final tasks = tasksFor(id);
    if (tasks.isEmpty) return 0;
    final completed = tasks.where((task) => task.completed).length;
    return completed / tasks.length;
  }

  double get overallCompletionRate {
    final tasks = DummyData.collections.expand((collection) => collection.tasks).toList();
    if (tasks.isEmpty) return 0;
    final completed = tasks.where((task) => task.completed).length;
    return completed / tasks.length;
  }

  Map<String, double> spendingByType() {
    final Map<String, double> spending = {};
    for (final collection in DummyData.collections) {
      spending.update(collection.type, (value) => value + collection.budgetUsed,
          ifAbsent: () => collection.budgetUsed);
    }
    return spending;
  }

  Map<JournalMood, int> overallMoodSummary() {
    final map = {for (final mood in JournalMood.values) mood: 0};
    for (final collection in DummyData.collections) {
      for (final entry in collection.journalEntries) {
        map[entry.mood] = (map[entry.mood] ?? 0) + 1;
      }
    }
    return map;
  }

  List<CollectionModel> collectionsNeedingAttention([int take = 3]) {
    final now = DateTime.now();
    final sorted = [...DummyData.collections]
      ..sort((a, b) => a.date.compareTo(b.date));
    return sorted
        .where((collection) {
          final daysUntil = collection.date.difference(now).inDays;
          final completion = completionRate(collection.id);
          final budgetRatio = collection.budgetPlanned == 0
              ? 0.0
              : collection.budgetUsed / collection.budgetPlanned;
          return (daysUntil <= 14 && completion < 0.6) || budgetRatio > 0.9;
        })
        .take(take)
        .toList();
  }

  List<CollectionModel> leadingCollections([int take = 3]) {
    final ranked = [...DummyData.collections]
      ..sort((a, b) => completionRate(b.id).compareTo(completionRate(a.id)));
    return ranked.take(take).toList();
  }

  double get totalBudgetPlanned =>
      DummyData.collections.fold(0, (previousValue, element) => previousValue + element.budgetPlanned);
  double get totalBudgetUsed =>
      DummyData.collections.fold(0, (previousValue, element) => previousValue + element.budgetUsed);

  double totalBudgetVariance(String id) {
    final collection = byId(id);
    return collection.budgetUsed - collection.budgetPlanned;
  }

  int get totalTasksCount =>
      DummyData.collections.fold(0, (previousValue, element) => previousValue + element.tasks.length);

  int get completedTasksCount => DummyData.collections
      .fold(0, (previousValue, element) => previousValue + element.tasks.where((task) => task.completed).length);

  void toggleMemoryFavourite(String id) {
    final index = DummyData.memories.indexWhere((element) => element.id == id);
    if (index == -1) return;
    final memory = DummyData.memories[index];
    DummyData.memories[index] = memory.copyWith(isFavourite: !memory.isFavourite);
    notifyListeners();
  }

  Future<void> refreshMemories() async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    DummyData.memories.shuffle();
    notifyListeners();
  }

  Future<void> refresh() async {
    _isLoading = true;
    notifyListeners();
    await Future<void>.delayed(const Duration(milliseconds: 800));
    _visible = List.from(DummyData.collections);
    _isLoading = false;
    notifyListeners();
  }

  void search(String query) {
    _query = query;
    _debouncer(() {
      _applyFilters();
    });
  }

  void filterByType(String type) {
    _typeFilter = type;
    _applyFilters();
  }

  void toggleFavouriteFilter(bool value) {
    _favouriteOnly = value;
    _applyFilters();
  }

  void updateDateRange(DateTimeRange? range) {
    _dateRange = range;
    _applyFilters();
  }

  void sortBy(String option) {
    _sortOption = option;
    _sortVisible();
    notifyListeners();
  }

  void resetFilters() {
    _favouriteOnly = false;
    _dateRange = null;
    _sortOption = 'Newest';
    _typeFilter = 'All';
    _applyFilters();
  }

  void toggleFavourite(String id) {
    DummyData.collections = DummyData.collections
        .map((e) => e.id == id ? e.copyWith(isFavourite: !e.isFavourite) : e)
        .toList();
    _applyFilters();
  }

  void toggleTask(String collectionId, String taskId, bool value) {
    final collection = byId(collectionId);
    final updatedTasks = collection.tasks
        .map((task) => task.id == taskId ? task.copyWith(completed: value) : task)
        .toList();
    _replaceCollection(collection.copyWith(tasks: updatedTasks));
  }

  void addTask(String collectionId, TaskModel task) {
    final collection = byId(collectionId);
    final updatedTasks = [...collection.tasks, task];
    _replaceCollection(collection.copyWith(tasks: updatedTasks));
  }

  void addBudgetLine(String collectionId, BudgetLineModel line) {
    final collection = byId(collectionId);
    final updated = [...collection.budgetLines, line];
    _replaceCollection(collection.copyWith(budgetLines: updated));
  }

  void updateBudgetLine(String collectionId, String lineId,
      {double? planned, double? spent, String? note, String? category}) {
    final collection = byId(collectionId);
    final updated = collection.budgetLines.map((line) {
      if (line.id != lineId) return line;
      return line.copyWith(
        planned: planned,
        spent: spent,
        note: note,
        category: category,
      );
    }).toList();
    _replaceCollection(collection.copyWith(budgetLines: updated));
  }

  void addItinerarySlot(String collectionId, String dayId, ItinerarySlotModel slot) {
    final collection = byId(collectionId);
    final updatedDays = collection.itinerary.map((day) {
      if (day.id != dayId) return day;
      final updatedSlots = [...day.slots, slot]
        ..sort((a, b) => _timeToMinutes(a.time).compareTo(_timeToMinutes(b.time)));
      return day.copyWith(slots: updatedSlots);
    }).toList();
    _replaceCollection(collection.copyWith(itinerary: updatedDays));
  }

  void cycleMilestoneStatus(String collectionId, String milestoneId) {
    final collection = byId(collectionId);
    final updated = collection.milestones.map((milestone) {
      if (milestone.id != milestoneId) return milestone;
      final next = switch (milestone.status) {
        MilestoneStatus.planned => MilestoneStatus.progress,
        MilestoneStatus.progress => MilestoneStatus.done,
        MilestoneStatus.done => MilestoneStatus.planned,
      };
      return milestone.copyWith(status: next);
    }).toList();
    _replaceCollection(collection.copyWith(milestones: updated));
  }

  void addJournalEntry(String collectionId, JournalEntryModel entry) {
    final collection = byId(collectionId);
    final updatedEntries = [...collection.journalEntries, entry]
      ..sort((a, b) => b.date.compareTo(a.date));
    _replaceCollection(collection.copyWith(journalEntries: updatedEntries));
  }

  void updateGuestStatus(String collectionId, String guestId, GuestStatus status) {
    final collection = byId(collectionId);
    final updatedGuests = collection.guests
        .map((guest) => guest.id == guestId ? guest.copyWith(status: status) : guest)
        .toList();
    _replaceCollection(collection.copyWith(guests: updatedGuests));
  }

  void addGuest(String collectionId, GuestModel guest) {
    final collection = byId(collectionId);
    final updatedGuests = [...collection.guests, guest];
    _replaceCollection(collection.copyWith(guests: updatedGuests));
  }

  void updateVendorStatus(String collectionId, String vendorId, VendorStatus status) {
    final collection = byId(collectionId);
    final updated = collection.vendors
        .map((vendor) => vendor.id == vendorId ? vendor.copyWith(status: status) : vendor)
        .toList();
    _replaceCollection(collection.copyWith(vendors: updated));
  }

  void addVendor(String collectionId, VendorModel vendor) {
    final collection = byId(collectionId);
    final updated = [...collection.vendors, vendor];
    _replaceCollection(collection.copyWith(vendors: updated));
  }

  void updateLogisticStatus(String collectionId, String logisticId, LogisticsStatus status) {
    final collection = byId(collectionId);
    final updated = collection.logistics
        .map((item) => item.id == logisticId ? item.copyWith(status: status) : item)
        .toList();
    _replaceCollection(collection.copyWith(logistics: updated));
  }

  void addLogistic(String collectionId, LogisticItemModel logistic) {
    final collection = byId(collectionId);
    final updated = [...collection.logistics, logistic]
      ..sort((a, b) => a.start.compareTo(b.start));
    _replaceCollection(collection.copyWith(logistics: updated));
  }

  Map<JournalMood, int> journalMoodSummary(String collectionId) {
    final entries = journalFor(collectionId);
    final map = {for (final mood in JournalMood.values) mood: 0};
    for (final entry in entries) {
      map[entry.mood] = (map[entry.mood] ?? 0) + 1;
    }
    return map;
  }

  List<({CollectionModel collection, JournalEntryModel entry})> recentJournalEntries([int take = 6]) {
    final combined = <({CollectionModel collection, JournalEntryModel entry})>[];
    for (final collection in DummyData.collections) {
      for (final entry in collection.journalEntries) {
        combined.add((collection: collection, entry: entry));
      }
    }
    combined.sort((a, b) => b.entry.date.compareTo(a.entry.date));
    return combined.take(take).toList();
  }

  Map<DateTime, List<TaskModel>> groupedTasks(String collectionId) {
    final tasks = tasksFor(collectionId);
    final Map<DateTime, List<TaskModel>> grouped = {};
    for (final task in tasks) {
      final key = DateTime(task.date.year, task.date.month, task.date.day);
      grouped.putIfAbsent(key, () => []).add(task);
    }
    final sortedKeys = grouped.keys.toList()..sort((a, b) => a.compareTo(b));
    return {for (final key in sortedKeys) key: grouped[key]!};
  }

  Future<void> loadMore() async {
    if (_isPaginating) return;
    _isPaginating = true;
    notifyListeners();
    await Future<void>.delayed(const Duration(milliseconds: 900));
    _isPaginating = false;
    notifyListeners();
  }

  void toggleCompare(String id) {
    if (_compareSelection.contains(id)) {
      _compareSelection.remove(id);
    } else {
      _compareSelection.add(id);
    }
    notifyListeners();
  }

  List<({CollectionModel collection, TaskModel task})> upcomingTimeline([int take = 5]) {
    final entries = <({CollectionModel collection, TaskModel task})>[];
    for (final collection in DummyData.collections) {
      for (final task in collection.tasks) {
        entries.add((collection: collection, task: task));
      }
    }
    entries.sort((a, b) => a.task.date.compareTo(b.task.date));
    return entries
        .where((entry) => entry.task.date.isAfter(DateTime.now().subtract(const Duration(hours: 1))))
        .take(take)
        .toList();
  }

  List<({CollectionModel collection, MilestoneModel milestone})> upcomingMilestones([int take = 3]) {
    final entries = <({CollectionModel collection, MilestoneModel milestone})>[];
    for (final collection in DummyData.collections) {
      for (final milestone in collection.milestones) {
        entries.add((collection: collection, milestone: milestone));
      }
    }
    entries.sort((a, b) => a.milestone.date.compareTo(b.milestone.date));
    return entries
        .where((entry) => entry.milestone.date
            .isAfter(DateTime.now().subtract(const Duration(days: 1))))
        .take(take)
        .toList();
  }

  List<({
    CollectionModel collection,
    ItineraryDayModel day,
    ItinerarySlotModel slot,
    DateTime schedule,
  })> upcomingItinerarySlots([int take = 4]) {
    final entries = <({
      CollectionModel collection,
      ItineraryDayModel day,
      ItinerarySlotModel slot,
      DateTime schedule,
    })>[];
    for (final collection in DummyData.collections) {
      for (final day in collection.itinerary) {
        for (final slot in day.slots) {
          entries.add((
            collection: collection,
            day: day,
            slot: slot,
            schedule: _combine(day, slot),
          ));
        }
      }
    }
    entries.sort((a, b) => a.schedule.compareTo(b.schedule));
    return entries
        .where((entry) => entry.schedule.isAfter(DateTime.now().subtract(const Duration(hours: 2))))
        .take(take)
        .toList();
  }

  ({ItineraryDayModel day, ItinerarySlotModel slot, DateTime schedule})?
      nextItinerarySlot(String collectionId) {
    final collection = byId(collectionId);
    final slots = <({ItineraryDayModel day, ItinerarySlotModel slot, DateTime schedule})>[];
    for (final day in collection.itinerary) {
      for (final slot in day.slots) {
        slots.add((day: day, slot: slot, schedule: _combine(day, slot)));
      }
    }
    slots.sort((a, b) => a.schedule.compareTo(b.schedule));
    final filtered = slots
        .where((entry) => entry.schedule.isAfter(DateTime.now().subtract(const Duration(hours: 2))))
        .toList();
    if (filtered.isEmpty) return null;
    return filtered.first;
  }

  List<({CollectionModel collection, LogisticItemModel item})> upcomingLogistics([int take = 4]) {
    final entries = <({CollectionModel collection, LogisticItemModel item})>[];
    final threshold = DateTime.now().subtract(const Duration(hours: 3));
    for (final collection in DummyData.collections) {
      for (final item in collection.logistics) {
        if (item.start.isAfter(threshold)) {
          entries.add((collection: collection, item: item));
        }
      }
    }
    entries.sort((a, b) => a.item.start.compareTo(b.item.start));
    return entries.take(take).toList();
  }

  List<({CollectionModel collection, BudgetLineModel line})> budgetPressureLines([int take = 4]) {
    final entries = <({CollectionModel collection, BudgetLineModel line})>[];
    for (final collection in DummyData.collections) {
      for (final line in collection.budgetLines) {
        if (line.planned == 0) continue;
        final ratio = line.spent / line.planned;
        if (ratio >= 0.7 || (collection.budgetUsed > collection.budgetPlanned && ratio >= 0.5)) {
          entries.add((collection: collection, line: line));
        }
      }
    }
    entries.sort((a, b) {
      final aRatio = a.line.planned == 0 ? 0.0 : a.line.spent / a.line.planned;
      final bRatio = b.line.planned == 0 ? 0.0 : b.line.spent / b.line.planned;
      return bRatio.compareTo(aRatio);
    });
    return entries.take(take).toList();
  }

  void _applyFilters() {
    _visible = DummyData.collections.where((collection) {
      final matchesQuery = collection.title.toLowerCase().contains(_query.toLowerCase()) ||
          collection.description.toLowerCase().contains(_query.toLowerCase()) ||
          collection.location.toLowerCase().contains(_query.toLowerCase());
      final matchesType = _typeFilter == 'All' || collection.type == _typeFilter;
      final matchesFavourite = !_favouriteOnly || collection.isFavourite;
      final matchesDate = _dateRange == null ||
          (collection.date.isAfter(_dateRange!.start.subtract(const Duration(days: 1))) &&
              collection.date.isBefore(_dateRange!.end.add(const Duration(days: 1))));
      return matchesQuery && matchesType && matchesFavourite && matchesDate;
    }).toList();
    _sortVisible();
    notifyListeners();
  }

  void _sortVisible() {
    switch (_sortOption) {
      case 'Oldest':
        _visible.sort((a, b) => a.date.compareTo(b.date));
        break;
      case 'A-Z':
        _visible.sort((a, b) => a.title.compareTo(b.title));
        break;
      default:
        _visible.sort((a, b) => b.date.compareTo(a.date));
    }
  }

  void _replaceCollection(CollectionModel updated) {
    DummyData.collections = DummyData.collections
        .map((collection) => collection.id == updated.id ? updated : collection)
        .toList();
    _applyFilters();
  }

  DateTime _combine(ItineraryDayModel day, ItinerarySlotModel slot) =>
      DateTime(day.date.year, day.date.month, day.date.day, slot.time.hour, slot.time.minute);

  int _timeToMinutes(TimeOfDay time) => time.hour * 60 + time.minute;

  List<({CollectionModel collection, GuestModel guest})> pendingGuests([int take = 4]) {
    final pending = <({CollectionModel collection, GuestModel guest})>[];
    for (final collection in DummyData.collections) {
      for (final guest in collection.guests) {
        if (guest.status == GuestStatus.invited || guest.status == GuestStatus.tentative) {
          pending.add((collection: collection, guest: guest));
        }
      }
    }
    return pending.take(take).toList();
  }

  List<({CollectionModel collection, VendorModel vendor})> vendorFollowUps([int take = 4]) {
    final entries = <({CollectionModel collection, VendorModel vendor})>[];
    final now = DateTime.now();
    final soon = now.add(const Duration(days: 5));
    for (final collection in DummyData.collections) {
      for (final vendor in collection.vendors) {
        final dueSoon = vendor.dueDate.isBefore(soon) && vendor.status != VendorStatus.paid;
        if (dueSoon || vendor.status == VendorStatus.negotiating) {
          entries.add((collection: collection, vendor: vendor));
        }
      }
    }
    entries.sort((a, b) => a.vendor.dueDate.compareTo(b.vendor.dueDate));
    return entries.take(take).toList();
  }

  List<({CollectionModel collection, DocumentModel document})> documentFollowUps([int take = 4]) {
    final entries = <({CollectionModel collection, DocumentModel document})>[];
    for (final collection in DummyData.collections) {
      for (final document in collection.documents) {
        final needsReview = document.status == DocumentStatus.draft || document.status == DocumentStatus.review;
        if (needsReview) {
          entries.add((collection: collection, document: document));
        }
      }
    }
    entries.sort((a, b) => b.document.updatedAt.compareTo(a.document.updatedAt));
    return entries.take(take).toList();
  }

  void updateDocumentStatus(String collectionId, String documentId, DocumentStatus status) {
    final collection = byId(collectionId);
    final updatedDocs = collection.documents
        .map((doc) => doc.id == documentId ? doc.copyWith(status: status, updatedAt: DateTime.now()) : doc)
        .toList();
    _replaceCollection(collection.copyWith(documents: updatedDocs));
  }

  void addDocument(String collectionId, DocumentModel document) {
    final collection = byId(collectionId);
    final updatedDocs = [...collection.documents, document];
    _replaceCollection(collection.copyWith(documents: updatedDocs));
  }
}
