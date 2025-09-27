import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class FavoritesRepository {
  static const String _favoritesKey = 'favorites_v1';

  Future<List<String>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_favoritesKey);
    if (jsonString != null) {
      return List<String>.from(json.decode(jsonString) as List);
    }
    return [];
  }

  Future<void> _saveFavorites(List<String> favorites) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_favoritesKey, json.encode(favorites));
  }

  Future<void> addFavorite(String productId) async {
    final favorites = await getFavorites();
    if (!favorites.contains(productId)) {
      favorites.add(productId);
      await _saveFavorites(favorites);
    }
  }

  Future<void> removeFavorite(String productId) async {
    final favorites = await getFavorites();
    if (favorites.contains(productId)) {
      favorites.remove(productId);
      await _saveFavorites(favorites);
    }
  }
}
