import 'package:flutter/material.dart';

import '../utils/dummy_data.dart';

class CatalogController extends ChangeNotifier {
  CatalogController();

  List<CollectionModel> _items = List.from(DummyData.collections);
  String _sort = 'Newest';
  bool _grid = true;
  String _query = '';
  String _typeFilter = 'All';
  bool _favouriteOnly = false;
  DateTimeRange? _dateRange;

  List<CollectionModel> get items => _items;
  bool get isGrid => _grid;
  String get sort => _sort;
  String get typeFilter => _typeFilter;
  bool get favouriteOnly => _favouriteOnly;
  DateTimeRange? get dateRange => _dateRange;

  void search(String query) {
    _query = query;
    _applyFilters();
  }

  void filterType(String type) {
    _typeFilter = type;
    _applyFilters();
  }

  void toggleFavouriteOnly(bool value) {
    _favouriteOnly = value;
    _applyFilters();
  }

  void updateDateRange(DateTimeRange? range) {
    _dateRange = range;
    _applyFilters();
  }

  void sortBy(String option, {bool notify = true}) {
    _sort = option;
    switch (option) {
      case 'Oldest':
        _items.sort((a, b) => a.date.compareTo(b.date));
        break;
      case 'A-Z':
        _items.sort((a, b) => a.title.compareTo(b.title));
        break;
      default:
        _items.sort((a, b) => b.date.compareTo(a.date));
    }
    if (notify) {
      notifyListeners();
    }
  }

  void toggleView() {
    _grid = !_grid;
    notifyListeners();
  }

  void _applyFilters() {
    _items = DummyData.collections.where((collection) {
      final query = _query.toLowerCase();
      final matchesQuery = collection.title.toLowerCase().contains(query) ||
          collection.description.toLowerCase().contains(query) ||
          collection.location.toLowerCase().contains(query);
      final matchesType = _typeFilter == 'All' || collection.type == _typeFilter;
      final matchesFavourite = !_favouriteOnly || collection.isFavourite;
      final matchesRange = _dateRange == null ||
          (collection.date.isAfter(_dateRange!.start.subtract(const Duration(days: 1))) &&
              collection.date.isBefore(_dateRange!.end.add(const Duration(days: 1))));
      return matchesQuery && matchesType && matchesFavourite && matchesRange;
    }).toList();
    sortBy(_sort, notify: false);
    notifyListeners();
  }
}
