import 'package:ecommerce/features/orders/data/orders_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  // On s'assure que les bindings Flutter sont initialisés pour SharedPreferences
  TestWidgetsFlutterBinding.ensureInitialized();

  group('OrdersRepository Tests', () {
    // Une commande factice
    final fakeOrder = OrderRecord(
      id: '123',
      total: 99.99,
      createdAt: DateTime.now(),
    );

    test(
      'getOrders doit retourner une liste vide si aucune commande n\'est sauvegardée',
      () async {
        // ARRANGE
        SharedPreferences.setMockInitialValues({});
        final repo = OrdersRepository();

        // ACT
        final orders = await repo.getOrders();

        // ASSERT
        expect(orders, isEmpty);
      },
    );

    test(
      'addOrder doit sauvegarder une commande, et getOrders doit la récupérer',
      () async {
        // ARRANGE
        SharedPreferences.setMockInitialValues({});
        final repo = OrdersRepository();

        // ACT
        await repo.addOrder(fakeOrder);
        final orders = await repo.getOrders();

        // ASSERT
        expect(orders.length, 1);
        expect(orders.first.id, '123');
        expect(orders.first.total, 99.99);
      },
    );
  });
}
