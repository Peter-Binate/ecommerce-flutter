import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ecommerce/features/catalog/presentation/catalog_screen.dart';
import 'package:ecommerce/features/catalog/domain/product.dart';

void main() {
  // Un produit fictif pour le test
  final fakeProduct = Product(
    id: '1',
    title: 'Test Product',
    price: 99.99,
    thumbnail: 'https://via.placeholder.com/150',
    images: ['https://via.placeholder.com/150'],
    description: 'A test product description.',
    category: 'tests',
  );

  testWidgets('Test 1: _ProductCard affiche les informations et gère l\'ajout au panier', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: ProductCard(product: fakeProduct),
          ),
        ),
      ),
    );

    expect(find.text('Test Product'), findsOneWidget);
    expect(find.text('99.99€'), findsOneWidget);

    expect(find.byType(Image), findsOneWidget);

    final addButton = find.byIcon(Icons.add);
    expect(addButton, findsOneWidget);
    await tester.tap(addButton);
    
    await tester.pumpAndSettle();

    expect(find.text('Test Product ajouté au panier'), findsOneWidget);
  });

  
}