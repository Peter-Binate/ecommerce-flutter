import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../application/cart_controller.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartControllerProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Panier')),
      body: Column(
        children: [
          Expanded(
            child: ListView.separated(
              itemCount: cart.items.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final it = cart.items[i];
                return ListTile(
                  title: Text(it.title),
                  subtitle: Text('Qté: ${it.quantity}'),
                  trailing: Text('${it.price.toStringAsFixed(2)}€'),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Total: ${cart.total.toStringAsFixed(2)}€', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () => context.go('/checkout'),
                  child: const Text('Passer au paiement'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


