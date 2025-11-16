import 'package:flutter/material.dart';

import '../utils/dummy_data.dart';

class CatalogController extends ChangeNotifier {
  CatalogController();

  List<CollectionModel> _items = List.from(DummyData.collections);
  String _sort = 'Newest';
  bool _grid = true;

  List<CollectionModel> get items => _items;
  bool get isGrid => _grid;
  String get sort => _sort;

  void search(String query) {
    _items = DummyData.collections
        .where((element) => element.title.toLowerCase().contains(query.toLowerCase()) ||
            element.description.toLowerCase().contains(query.toLowerCase()) ||
            element.location.toLowerCase().contains(query.toLowerCase()))
        .toList();
    sortBy(_sort);
  }

  void sortBy(String option) {
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
    notifyListeners();
  }

  void toggleView() {
    _grid = !_grid;
    notifyListeners();
  }
}
