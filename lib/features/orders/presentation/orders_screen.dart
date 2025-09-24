import 'package:flutter/material.dart';
import '../data/orders_repository.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mes commandes')),
      body: FutureBuilder<List<OrderRecord>>(
        future: OrdersRepository().getOrders(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final orders = snapshot.data!;
          if (orders.isEmpty) {
            return const Center(child: Text('Aucune commande'));
          }
          return ListView.separated(
            itemCount: orders.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final o = orders[i];
              return ListTile(
                title: Text('Commande #${o.id}'),
                subtitle: Text(o.createdAt.toLocal().toString()),
                trailing: Text('${o.total.toStringAsFixed(2)}€'),
              );
            },
          );
        },
      ),
    );
  }
}


