// lib/features/catalog/presentation/catalog_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../catalog/application/catalog_controller.dart';

class CatalogScreen extends ConsumerStatefulWidget { // <-- MODIFIÉ
  const CatalogScreen({super.key});

  @override
  ConsumerState<CatalogScreen> createState() => _CatalogScreenState(); // <-- MODIFIÉ
}

class _CatalogScreenState extends ConsumerState<CatalogScreen> { // <-- MODIFIÉ

  @override
  void initState() {
    super.initState();
    // On charge les données une seule fois à l'initialisation du widget
    Future.microtask(() => ref.read(catalogControllerProvider.notifier).load());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(catalogControllerProvider);
    // On n'appelle plus load() ici
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Catalogue'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: (v) => ref.read(catalogControllerProvider.notifier).setQuery(v),
              decoration: const InputDecoration(
                hintText: 'Recherche par titre ou catégorie',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
        ),
      ),
      body: Builder(
        builder: (_) {
          if (state.isLoading && state.products.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          final list = ref.read(catalogControllerProvider.notifier).filtered;
          if (list.isEmpty) {
            return const Center(child: Text('Aucun produit'));
          }
          return ListView.separated(
            itemCount: list.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final p = list[index];
              return ListTile(
                leading: const Icon(Icons.shopping_bag_outlined),
                title: Text(p.title),
                subtitle: Text('${p.price.toStringAsFixed(2)}€'),
                onTap: () => context.go('/product/${p.id}'),
              );
            },
          );
        },
      ),
    );
  }
}