import 'package:flutter/material.dart';

import '../utils/dummy_data.dart';

class GalleryController extends ChangeNotifier {
  GalleryController();

  String _filter = 'All';
  List<GalleryItem> _items = DummyData.gallery;

  List<GalleryItem> get items => _items;
  String get filter => _filter;

  void filterBy(String filter) {
    _filter = filter;
    switch (filter) {
      case 'Favourites':
        _items = DummyData.gallery.where((e) => e.isFavourite).toList();
        break;
      case 'By Event':
        _items = DummyData.gallery.take(2).toList();
        break;
      default:
        _items = DummyData.gallery;
    }
    notifyListeners();
  }

  void toggleFavourite(String id) {
    DummyData.gallery = DummyData.gallery
        .map((item) => item.id == id ? item.copyWith(isFavourite: !item.isFavourite) : item)
        .toList();
    filterBy(_filter);
  }
}
