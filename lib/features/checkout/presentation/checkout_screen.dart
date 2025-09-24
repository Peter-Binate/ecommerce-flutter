import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../cart/application/cart_controller.dart';
import '../../orders/data/orders_repository.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  bool isPaying = false;

  Future<void> _mockPay() async {
    setState(() => isPaying = true);
    await Future<void>.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    final cart = ref.read(cartControllerProvider);
    final repo = OrdersRepository();
    await repo.addOrder(OrderRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      total: cart.total,
      createdAt: DateTime.now(),
    ));
    ref.read(cartControllerProvider.notifier).clear();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Paiement réussi (mock)')));
    context.go('/orders');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Récapitulatif de commande (mock)'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: isPaying ? null : _mockPay,
              child: isPaying
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Payer'),
            )
          ],
        ),
      ),
    );
  }
}


