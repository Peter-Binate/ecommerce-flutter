import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:ecommerce/features/auth/data/auth_repository.dart';
import 'package:ecommerce/features/catalog/data/catalog_repository.dart';
import 'package:ecommerce/features/cart/application/cart_controller.dart';

@GenerateMocks([AuthRepository, CatalogRepository])
void main() {
  group('CartController Tests', () {
    test('Test 1: Le panier initial doit être vide', () {
      // ARRANGE
      final cartController = CartController();
      // ASSERT
      expect(cartController.debugState.items, isEmpty);
      expect(cartController.debugState.total, 0.0);
    });

    test('Test 2: Ajouter un nouvel article au panier doit fonctionner', () {
      // ARRANGE
      final cartController = CartController();
      // ACT
      cartController.addItem(
        id: '1',
        title: 'Produit 1',
        price: 10.0,
        thumbnail: 'url',
      );
      // ASSERT
      expect(cartController.debugState.items.length, 1);
      expect(cartController.debugState.items.first.productId, '1');
      expect(cartController.debugState.total, 10.0);
    });

    test(
      'Test 3: Ajouter un article existant doit incrémenter sa quantité',
      () {
        // ARRANGE
        final cartController = CartController();
        cartController.addItem(
          id: '1',
          title: 'Produit 1',
          price: 10.0,
          thumbnail: 'url',
        );
        // ACT
        cartController.addItem(
          id: '1',
          title: 'Produit 1',
          price: 10.0,
          thumbnail: 'url',
        );
        // ASSERT
        expect(cartController.debugState.items.length, 1);
        expect(cartController.debugState.items.first.quantity, 2);
        expect(cartController.debugState.total, 20.0);
      },
    );

    test('Test 4: Mettre à jour la quantité à 0 doit supprimer l\'article', () {
      // ARRANGE
      final cartController = CartController();
      cartController.addItem(
        id: '1',
        title: 'Produit 1',
        price: 10.0,
        thumbnail: 'url',
      );
      // ACT
      cartController.updateQty('1', 0);
      // ASSERT
      expect(cartController.debugState.items, isEmpty);
      expect(cartController.debugState.total, 0.0);
    });

    test('Test 5: Vider le panier doit supprimer tous les articles', () {
      // ARRANGE
      final cartController = CartController();
      cartController.addItem(id: '1', title: 'P1', price: 10, thumbnail: 'url');
      cartController.addItem(id: '2', title: 'P2', price: 25, thumbnail: 'url');
      // ACT
      cartController.clear();
      // ASSERT
      expect(cartController.debugState.items, isEmpty);
      expect(cartController.debugState.total, 0.0);
    });
  });
}
