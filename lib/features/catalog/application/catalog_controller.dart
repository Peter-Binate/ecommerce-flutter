import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/catalog_repository.dart';
import '../domain/product.dart';

final productProvider = FutureProvider.family<Product?, String>((ref, id) {
  final repo = ref.watch(catalogRepositoryProvider);
  return repo.fetchProduct(id);
});

class CatalogState {
  final List<Product> products;
  final String query;
  final bool isLoading;
  final String? error;

  const CatalogState({
    required this.products,
    required this.query,
    required this.isLoading,
    this.error,
  });

  CatalogState copyWith({
    List<Product>? products,
    String? query,
    bool? isLoading,
    String? error,
  }) {
    return CatalogState(
      products: products ?? this.products,
      query: query ?? this.query,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class CatalogController extends StateNotifier<CatalogState> {
  CatalogController(this._repo)
    : super(const CatalogState(products: [], query: '', isLoading: false));

  final CatalogRepository _repo;

  Future<void> load() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final list = await _repo.fetchProducts();
      state = state.copyWith(products: list, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: '$e');
    }
  }

  void setQuery(String q) => state = state.copyWith(query: q);

  List<Product> get filtered {
    if (state.query.isEmpty) return state.products;
    final q = state.query.toLowerCase();
    return state.products
        .where(
          (p) =>
              p.title.toLowerCase().contains(q) ||
              p.category.toLowerCase().contains(q),
        )
        .toList();
  }
}

final catalogRepositoryProvider = Provider<CatalogRepository>(
  (ref) => CatalogRepository(),
);
final catalogControllerProvider =
    StateNotifierProvider<CatalogController, CatalogState>((ref) {
      final repo = ref.watch(catalogRepositoryProvider);
      return CatalogController(repo);
    });
