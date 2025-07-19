import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
class CategoryProvider extends ChangeNotifier {
  List<String> _categories = [];
  List<String> _hiddenCategories = [];

  List<String> get categories => _categories;
  List<String> get visibleCategories =>
      _categories.where((c) => !_hiddenCategories.contains(c)).toList();
  List<String> get hiddenCategories => _hiddenCategories;

  CategoryProvider() {
    _loadCategories();
  }

  void addCategory(String newCategory) async {
    if (!_categories.contains(newCategory)) {
      _categories.add(newCategory);
      await _saveCategories();
      notifyListeners();
    }
  }
  void updateCategoryOrder(List<String> newOrder) {
  _categories = ['No Category', ...newOrder];
  notifyListeners();
}


  void editCategory(String oldCategory, String newCategory) async {
    final index = _categories.indexOf(oldCategory);
    if (index != -1) {
      _categories[index] = newCategory;

      final hiddenIndex = _hiddenCategories.indexOf(oldCategory);
      if (hiddenIndex != -1) {
        _hiddenCategories[hiddenIndex] = newCategory;
      }

      await _saveCategories();
      notifyListeners();
    }
  }

  void removeCategory(String category) async {
    _categories.remove(category);
    _hiddenCategories.remove(category);
    await _saveCategories();
    notifyListeners();
  }

  void hideCategory(String category) async {
    if (!_hiddenCategories.contains(category)) {
      _hiddenCategories.add(category);
      await _saveCategories();
      notifyListeners();
    }
  }

  void showCategory(String category) async {
    _hiddenCategories.remove(category);
    await _saveCategories();
    notifyListeners();
  }

  Future<void> _saveCategories() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList('categories', _categories);
    prefs.setStringList('hiddenCategories', _hiddenCategories);
  }

  Future<void> _loadCategories() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList('categories');
    final hidden = prefs.getStringList('hiddenCategories');

    _categories = saved != null && saved.isNotEmpty
        ? saved
        : ['No Category', 'Work', 'Personal', 'Shopping', 'Others'];

    _hiddenCategories = hidden ?? [];

    notifyListeners();
  }

  bool isCategoryHidden(String category) {
    return _hiddenCategories.contains(category);
  }
}

