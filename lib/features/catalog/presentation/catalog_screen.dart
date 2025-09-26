import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:math';
import '../../catalog/application/catalog_controller.dart';
import '../../cart/application/cart_controller.dart';
import '../domain/product.dart';

class CatalogScreen extends ConsumerStatefulWidget {
  const CatalogScreen({super.key});

  @override
  ConsumerState<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends ConsumerState<CatalogScreen> {
  @override
  void initState() {
    super.initState();
    // On utilise microtask pour s'assurer que le contexte est disponible.
    Future.microtask(() => ref.read(catalogControllerProvider.notifier).load());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(catalogControllerProvider);
    final list = ref.read(catalogControllerProvider.notifier).filtered;
    // On écoute le panier pour le badge
    final cartItemsCount = ref.watch(cartControllerProvider).items.length;

    return Scaffold(
      appBar: AppBar(
        // Icône à gauche
        leading: IconButton(
          onPressed: () {
            // Logique pour le menu ou autre
          },
          icon: const Icon(Icons.apps_outlined),
        ),
        // Le titre est automatiquement centré par défaut
        title: const Text('Home'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black87,
        actions: [
          // Icône panier avec un badge
          IconButton(
            onPressed: () => context.go('/cart'),
            icon: Badge(
              label: Text('$cartItemsCount'),
              isLabelVisible: cartItemsCount > 0,
              child: const Icon(Icons.shopping_basket_outlined),
            ),
          ),
          // Avatar utilisateur
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: CircleAvatar(
              radius: 16,
              backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=1'), // Image de placeholder
            ),
          ),
        ],
        // Nouvelle barre de recherche
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: (v) => ref.read(catalogControllerProvider.notifier).setQuery(v),
                    decoration: InputDecoration(
                      hintText: 'Search...',
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: EdgeInsets.zero,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Theme.of(context).primaryColor),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // Bouton de filtre
                Container(
                  decoration: BoxDecoration(
                    color: Colors.pinkAccent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    onPressed: () {
                      // Logique pour afficher les filtres
                    },
                    icon: const Icon(Icons.filter_list, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Builder(
        builder: (_) {
          if (state.isLoading && state.products.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (list.isEmpty) {
            return const Center(child: Text('Aucun produit trouvé'));
          }
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.7,
            ),
            itemCount: list.length,
            itemBuilder: (context, index) {
              final p = list[index];
              return ProductCard(product: p);
            },
          );
        },
      ),
      backgroundColor: Colors.grey[50],
    );
  }
}

class ProductCard extends ConsumerWidget {
  const ProductCard({required this.product});
  final Product product;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final simulatedRating = 3.5 + Random().nextDouble() * 1.5;

    return GestureDetector(
      onTap: () => context.go('/product/${product.id}'),
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Image.network(
                        product.thumbnail,
                        fit: BoxFit.contain,
                        loadingBuilder: (context, child, progress) {
                          return progress == null ? child : const Center(child: CircularProgressIndicator(strokeWidth: 2));
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.image_not_supported_outlined, color: Colors.grey, size: 40);
                        },
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Icon(
                      Random().nextBool() ? Icons.favorite : Icons.favorite_border,
                      color: Colors.redAccent,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${product.price.toStringAsFixed(2)}€',
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                      ),
                      CircleAvatar(
                        radius: 14,
                        backgroundColor: Colors.pinkAccent,
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          iconSize: 16,
                          icon: const Icon(Icons.add, color: Colors.white),
                         onPressed: () {
                          ref.read(cartControllerProvider.notifier).addItem(
                            id: product.id.toString(),
                            title: product.title,
                            price: product.price,
                            thumbnail: product.thumbnail,
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('${product.title} ajouté au panier')),
                          );
                        },
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: List.generate(5, (index) {
                      return Icon(
                        index < simulatedRating.floor() ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                        size: 16,
                      );
                    }),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}