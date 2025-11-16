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
  final Set<String> _compareSelection = {};

  List<CollectionModel> get visible => _visible;
  bool get isLoading => _isLoading;
  bool get isPaginating => _isPaginating;
  Set<String> get compareSelection => _compareSelection;
  String get typeFilter => _typeFilter;

  CollectionModel byId(String id) => DummyData.collections.firstWhere((element) => element.id == id);

  List<TaskModel> tasksFor(String id) => byId(id).tasks;

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

  void _applyFilters() {
    _visible = DummyData.collections.where((collection) {
      final matchesQuery = collection.title.toLowerCase().contains(_query.toLowerCase()) ||
          collection.description.toLowerCase().contains(_query.toLowerCase()) ||
          collection.location.toLowerCase().contains(_query.toLowerCase());
      final matchesType = _typeFilter == 'All' || collection.type == _typeFilter;
      return matchesQuery && matchesType;
    }).toList();
    notifyListeners();
  }

  void _replaceCollection(CollectionModel updated) {
    DummyData.collections = DummyData.collections
        .map((collection) => collection.id == updated.id ? updated : collection)
        .toList();
    _applyFilters();
  }
}
