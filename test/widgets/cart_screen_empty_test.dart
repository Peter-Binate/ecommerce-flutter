import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ecommerce/features/cart/presentation/cart_screen.dart';

void main() {
  testWidgets(
    'Test 2: CartScreen affiche le widget _EmptyCart quand le panier est vide',
    (WidgetTester tester) async {
      // ARRANGE
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: CartScreen())),
      );

      expect(find.byIcon(Icons.shopping_cart_outlined), findsOneWidget);

      expect(find.text('Your cart is empty'), findsOneWidget);
      expect(
        find.text('Looks like you haven\'t added anything yet.'),
        findsOneWidget,
      );

      final shoppingButton = find.widgetWithText(
        ElevatedButton,
        'Start Shopping',
      );
      expect(shoppingButton, findsOneWidget);
    },
  );
}
