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
}
