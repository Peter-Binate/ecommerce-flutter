import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../cart/application/cart_controller.dart';
import '../application/catalog_controller.dart';

class ProductScreen extends ConsumerWidget {
  final String productId;
  const ProductScreen({super.key, required this.productId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productAsync = ref.watch(productProvider(productId));

    return Scaffold(
      appBar: AppBar(title: Text('Produit')),
      body: productAsync.when(
        // État de chargement
        loading: () => const Center(child: CircularProgressIndicator()),
        // État d'erreur
        error: (err, stack) => Center(child: Text('Erreur: $err')),
        // État avec données
        data: (product) {
          if (product == null) {
            return const Center(child: Text('Produit non trouvé'));
          }
          // On affiche les vraies données du produit
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Image.network(
                  product.thumbnail,
                  height: 250,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 16),
                Text(product.title, style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 8),
                Text(
                  '${product.price.toStringAsFixed(2)}€',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Theme.of(context).colorScheme.primary),
                ),
                const SizedBox(height: 8),
                Text(product.description, style: Theme.of(context).textTheme.bodyMedium),
                const Spacer(),
                ElevatedButton(
                  onPressed: () {
                    ref.read(cartControllerProvider.notifier).addItem(
                          id: product.id,
                          title: product.title,
                          price: product.price,
                        );
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ajouté au panier')));
                  },
                  child: const Text('Ajouter au panier'),
                ),
                Center(
                  child: TextButton(
                    onPressed: () => context.go('/cart'),
                    child: const Text('Voir le panier'),
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}


