import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:ecommerce/features/catalog/application/catalog_controller.dart';
import 'package:ecommerce/features/catalog/domain/product.dart';

import '../mocks.mocks.dart';
void main() {
  final mockProducts = [
    Product(id: '1', title: 'Laptop Pro', price: 1200, thumbnail: '', images: [], description: '', category: 'electronics'),
    Product(id: '2', title: 'T-shirt Coton', price: 25, thumbnail: '', images: [], description: '', category: 'men\'s clothing'),
    Product(id: '3', title: 'Souris Gamer Pro', price: 80, thumbnail: '', images: [], description: '', category: 'electronics'),
  ];

  group('CatalogController Filtering Tests', () {

    test('Le getter "filtered" doit retourner tous les produits si la recherche est vide', () async { // <-- 1. Ajouter async
      final mockRepo = MockCatalogRepository();
      when(mockRepo.fetchProducts()).thenAnswer((_) async => mockProducts);
      
      final controller = CatalogController(mockRepo);
      await controller.load();

      expect(controller.filtered.length, 3);
    });

    test('Le getter "filtered" doit retourner les produits correspondants à la catégorie', () async {
      final mockRepo = MockCatalogRepository();
      when(mockRepo.fetchProducts()).thenAnswer((_) async => mockProducts);
      
      final controller = CatalogController(mockRepo);
      await controller.load();

      controller.setQuery('electronics');

      expect(controller.filtered.length, 2);
      expect(controller.filtered.every((p) => p.category == 'electronics'), isTrue);
    });

    test('Le getter "filtered" doit retourner les produits correspondants au titre', () async {      final mockRepo = MockCatalogRepository();
      when(mockRepo.fetchProducts()).thenAnswer((_) async => mockProducts);
      final controller = CatalogController(mockRepo);
      await controller.load();

      controller.setQuery('pro');

      expect(controller.filtered.length, 2);
      expect(controller.filtered.any((p) => p.title == 'Laptop Pro'), isTrue);
      expect(controller.filtered.any((p) => p.title == 'Souris Gamer Pro'), isTrue);
    });
     test('Le getter "filtered" ne doit retourner aucun produit si la recherche ne correspond à rien', () async {
      final mockRepo = MockCatalogRepository();
      when(mockRepo.fetchProducts()).thenAnswer((_) async => mockProducts);
      
      final controller = CatalogController(mockRepo);
      await controller.load();

      controller.setQuery('inexistant');

      expect(controller.filtered, isEmpty);
    });
  });
}