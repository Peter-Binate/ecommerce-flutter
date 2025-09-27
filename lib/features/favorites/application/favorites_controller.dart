import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/favorites_repository.dart';

final favoritesRepositoryProvider = Provider<FavoritesRepository>(
  (ref) => FavoritesRepository(),
);

final favoritesControllerProvider =
    StateNotifierProvider<FavoritesController, AsyncValue<List<String>>>((ref) {
      final repo = ref.watch(favoritesRepositoryProvider);
      return FavoritesController(repo);
    });

class FavoritesController extends StateNotifier<AsyncValue<List<String>>> {
  FavoritesController(this._repo) : super(const AsyncValue.loading()) {
    _loadFavorites();
  }

  final FavoritesRepository _repo;

  Future<void> _loadFavorites() async {
    try {
      final favorites = await _repo.getFavorites();
      state = AsyncValue.data(favorites);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> toggleFavorite(String productId) async {
    if (state.value == null) return;

    final currentFavorites = List<String>.from(state.value!);

    try {
      if (currentFavorites.contains(productId)) {
        await _repo.removeFavorite(productId);
        currentFavorites.remove(productId);
      } else {
        await _repo.addFavorite(productId);
        currentFavorites.add(productId);
      }
      state = AsyncValue.data(currentFavorites);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
