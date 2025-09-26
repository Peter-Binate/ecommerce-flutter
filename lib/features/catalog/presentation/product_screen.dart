import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../cart/application/cart_controller.dart';
import '../application/catalog_controller.dart';
import 'dart:math'; // Pour simuler la note

class ProductScreen extends ConsumerWidget {
  final String productId;
  const ProductScreen({super.key, required this.productId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productAsync = ref.watch(productProvider(productId));
    final Color pageBackgroundColor = Colors.grey.shade100;

    return Scaffold(
      backgroundColor: pageBackgroundColor,
      // --- AppBar Personnalisée ---
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: Colors.grey.shade700),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.favorite_border, color: Colors.redAccent),
            onPressed: () {
              /* Logique pour les favoris */
            },
          ),
        ],
      ),
      body: productAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Erreur: $err')),
        data: (product) {
          if (product == null) {
            return const Center(child: Text('Produit non trouvé'));
          }

          // Données simulées pour l'UI
          final rating = (3.8 + Random().nextDouble() * 1.2).toStringAsFixed(1);
          final sizes = ['US 6', 'US 7', 'US 8', 'US 9'];
          final colors = [
            Colors.orange.shade800,
            Colors.teal,
            Colors.green,
            Colors.yellow.shade700,
          ];

          return Column(
            children: [
              // --- Partie Supérieure : Image ---
              Expanded(
                flex: 4,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Image.network(
                    product.thumbnail,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.error, color: Colors.red);
                    },
                  ),
                ),
              ),

              // --- Partie Inférieure : Fiche de détails ---
              Expanded(
                flex: 6,
                child: Container(
                  padding: const EdgeInsets.all(24.0),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(30),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Titre, Prix et Note
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        product.title,
                                        style: Theme.of(context)
                                            .textTheme
                                            .headlineSmall
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'By ${product.category}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium
                                            ?.copyWith(color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '${product.price.toStringAsFixed(2)}€',
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineSmall
                                          ?.copyWith(
                                            color: Colors.deepPurple,
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.star,
                                          color: Colors.amber,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          rating,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            // Sélecteur de taille
                            _SizeSelector(sizes: sizes),
                            const SizedBox(height: 24),
                            // Sélecteur de couleur
                            _ColorSelector(colors: colors),
                            const SizedBox(height: 24),
                            // Description
                            Text(
                              'Description',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              product.description,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: Colors.grey.shade600),
                            ),
                            const SizedBox(
                              height: 80,
                            ), // Espace pour le bouton flottant
                          ],
                        ),
                      ),
                      // Bouton d'ajout au panier flottant
                      Positioned(
                        bottom: 16,
                        right: 16,
                        child: FloatingActionButton(
                          onPressed: () {
                            ref
                                .read(cartControllerProvider.notifier)
                                .addItem(
                                  id: product.id,
                                  title: product.title,
                                  price: product.price,
                                  thumbnail: product.thumbnail,
                                );
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Ajouté au panier')),
                            );
                          },
                          backgroundColor: Colors.deepPurple,
                          child: const Icon(
                            Icons.shopping_basket_outlined,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// Widget pour le sélecteur de taille
class _SizeSelector extends StatefulWidget {
  final List<String> sizes;
  const _SizeSelector({required this.sizes});

  @override
  State<_SizeSelector> createState() => _SizeSelectorState();
}

class _SizeSelectorState extends State<_SizeSelector> {
  String? _selectedSize;

  @override
  void initState() {
    super.initState();
    if (widget.sizes.isNotEmpty) {
      _selectedSize = widget.sizes[1]; // Sélection par défaut
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Size',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8.0,
          children: widget.sizes.map((size) {
            final isSelected = _selectedSize == size;
            return ChoiceChip(
              label: Text(size),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedSize = size;
                });
              },
              backgroundColor: Colors.grey.shade200,
              selectedColor: Colors.deepPurple,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              side: BorderSide.none,
            );
          }).toList(),
        ),
      ],
    );
  }
}

// Widget pour le sélecteur de couleur
class _ColorSelector extends StatefulWidget {
  final List<Color> colors;
  const _ColorSelector({required this.colors});

  @override
  State<_ColorSelector> createState() => _ColorSelectorState();
}

class _ColorSelectorState extends State<_ColorSelector> {
  Color? _selectedColor;

  @override
  void initState() {
    super.initState();
    if (widget.colors.isNotEmpty) {
      _selectedColor = widget.colors.first;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Color',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12.0,
          children: widget.colors.map((color) {
            final isSelected = _selectedColor == color;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedColor = color;
                });
              },
              child: CircleAvatar(
                radius: 18,
                backgroundColor: isSelected
                    ? Colors.deepPurple
                    : Colors.transparent,
                child: CircleAvatar(radius: 15, backgroundColor: color),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
