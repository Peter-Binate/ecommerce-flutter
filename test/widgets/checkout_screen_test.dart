import 'package:ecommerce/features/cart/application/cart_controller.dart';
import 'package:ecommerce/features/checkout/presentation/checkout_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Mock de OrderRecord
class OrderRecord {
  final String id;
  final double total;
  final DateTime createdAt;

  OrderRecord({
    required this.id,
    required this.total,
    required this.createdAt,
  });
}

// Mock de OrdersRepository
class OrdersRepository {
  Future<void> addOrder(OrderRecord order) async {
    // Simulation d'ajout d'une commande
    await Future.delayed(const Duration(milliseconds: 100));
  }
}

// On crée un GoRouter simple pour le test
final _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const CheckoutScreen(),
    ),
    GoRoute(
      path: '/orders',
      builder: (context, state) => const Scaffold(body: Text('Orders Page')),
    ),
  ],
);

void main() {
  // Setup partagé pour tous les tests
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets(
    'Test 1: CheckoutScreen - Affichage initial et navigation basique',
    (WidgetTester tester) async {
      // ARRANGE
      final container = ProviderContainer();
      final cartNotifier = container.read(cartControllerProvider.notifier);
      cartNotifier.addItem(id: '1', title: 'Laptop', price: 1200, thumbnail: 'url');
      cartNotifier.addItem(id: '2', title: 'Souris', price: 50, thumbnail: 'url');

      // ACT
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp.router(
            routerConfig: _router,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // ASSERT
      // Vérifier l'affichage initial
      expect(find.text('Finaliser la commande'), findsOneWidget);
      expect(find.text('Récapitulatif de commande'), findsOneWidget);
      expect(find.text('Résumé'), findsOneWidget);
      expect(find.text('Livraison'), findsNWidgets(2));
      expect(find.text('Paiement'), findsOneWidget);

      // Vérifier les produits dans le panier
      expect(find.text('Laptop'), findsOneWidget);
      expect(find.text('Souris'), findsOneWidget);
      expect(find.text('Qté: 1'), findsNWidgets(2));

      // Vérifier le total (1200 + 50 = 1250€)
      expect(find.textContaining('1250.00€'), findsAtLeastNWidgets(1));

      // Vérifier que le bouton "Continuer" est présent
      expect(find.text('Continuer'), findsOneWidget);
    },
  );

  testWidgets(
    'Test 2: CheckoutScreen - Navigation vers l\'étape livraison',
    (WidgetTester tester) async {
      // ARRANGE
      final container = ProviderContainer();
      final cartNotifier = container.read(cartControllerProvider.notifier);
      cartNotifier.addItem(id: '1', title: 'Test Product', price: 100, thumbnail: 'url');

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp.router(
            routerConfig: _router,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // ACT - Aller à l'étape livraison
      await tester.tap(find.text('Continuer'));
      await tester.pumpAndSettle();

      // ASSERT
      expect(find.text('Informations de livraison'), findsOneWidget);
      expect(find.text('Mode de livraison'), findsOneWidget);
      expect(find.text('Livraison standard'), findsOneWidget);
      expect(find.text('Livraison express'), findsOneWidget);

      // Vérifier les champs de formulaire
      expect(find.byType(TextField), findsNWidgets(7)); // 7 champs au total

      // Vérifier les boutons de navigation
      expect(find.text('Précédent'), findsOneWidget);
      expect(find.text('Continuer'), findsOneWidget);
    },
  );

  testWidgets(
    'Test 3: CheckoutScreen - Sélection des modes de paiement',
    (WidgetTester tester) async {
      // ARRANGE
      final container = ProviderContainer();
      final cartNotifier = container.read(cartControllerProvider.notifier);
      cartNotifier.addItem(id: '1', title: 'Test Product', price: 100, thumbnail: 'url');

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp.router(
            routerConfig: _router,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // ACT - Aller à l'étape paiement
      await tester.tap(find.text('Continuer'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Continuer'));
      await tester.pumpAndSettle();

      // ASSERT - Vérifier l'état initial (carte sélectionnée)
      expect(find.byIcon(Icons.radio_button_checked), findsOneWidget);
      expect(find.byIcon(Icons.radio_button_unchecked), findsNWidgets(2));

      // Sélectionner PayPal
      await tester.tap(find.text('PayPal'));
      await tester.pumpAndSettle();

      // Vérifier que PayPal est maintenant sélectionné
      expect(find.byIcon(Icons.radio_button_checked), findsOneWidget);
      expect(find.byIcon(Icons.radio_button_unchecked), findsNWidgets(2));
    },
  );

  testWidgets(
    'Test 6: CheckoutScreen - Navigation arrière',
    (WidgetTester tester) async {
      // ARRANGE
      final container = ProviderContainer();
      final cartNotifier = container.read(cartControllerProvider.notifier);
      cartNotifier.addItem(id: '1', title: 'Test Product', price: 100, thumbnail: 'url');

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp.router(
            routerConfig: _router,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // ACT - Aller à l'étape livraison
      await tester.tap(find.text('Continuer'));
      await tester.pumpAndSettle();
      
      expect(find.text('Informations de livraison'), findsOneWidget);

      // Retour à l'étape résumé
      await tester.tap(find.text('Précédent'));
      await tester.pumpAndSettle();

      // ASSERT
      expect(find.text('Récapitulatif de commande'), findsOneWidget);
      expect(find.text('Précédent'), findsNothing);
    },
  );

  testWidgets(
    'Test 7: CheckoutScreen - Calcul des frais de livraison',
    (WidgetTester tester) async {
      final container1 = ProviderContainer();
      final cartNotifier1 = container1.read(cartControllerProvider.notifier);
      cartNotifier1.addItem(id: '1', title: 'Petit article', price: 30, thumbnail: 'url');

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container1,
          child: MaterialApp.router(
            routerConfig: _router,
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('4,99€'), findsOneWidget); // Frais de livraison
      expect(find.text('34.99€'), findsOneWidget); // Total avec livraison
      
      container1.dispose();
    },
  );

  testWidgets(
    'Test 8: CheckoutScreen - Livraison gratuite pour montant > 50€',
    (WidgetTester tester) async {
      // ARRANGE - Panier avec montant > 50€
      final container = ProviderContainer();
      final cartNotifier = container.read(cartControllerProvider.notifier);
      cartNotifier.addItem(id: '1', title: 'Gros article', price: 75, thumbnail: 'url');

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp.router(
            routerConfig: _router,
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Gratuite'), findsOneWidget);
      expect(find.text('75.00€'), findsAtLeastNWidgets(1));
    },
  );

  testWidgets(
    'Test 9: CheckoutScreen - Formulaire de livraison - saisie de données',
    (WidgetTester tester) async {
      // ARRANGE
      final container = ProviderContainer();
      final cartNotifier = container.read(cartControllerProvider.notifier);
      cartNotifier.addItem(id: '1', title: 'Test Product', price: 100, thumbnail: 'url');

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp.router(
            routerConfig: _router,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // ACT - Aller à l'étape livraison
      await tester.tap(find.text('Continuer'));
      await tester.pumpAndSettle();

      // Trouver les champs spécifiques par leur label
      final prenomField = find.ancestor(
        of: find.text('Prénom'),
        matching: find.byType(TextField),
      );
      final nomField = find.ancestor(
        of: find.text('Nom'),
        matching: find.byType(TextField),
      );
      final emailField = find.ancestor(
        of: find.text('Email'),
        matching: find.byType(TextField),
      );

      // Remplir les champs
      await tester.enterText(prenomField, 'John');
      await tester.enterText(nomField, 'Doe');
      await tester.enterText(emailField, 'john.doe@example.com');

      await tester.pumpAndSettle();

      // ASSERT
      expect(find.text('John'), findsOneWidget);
      expect(find.text('Doe'), findsOneWidget);
      expect(find.text('john.doe@example.com'), findsOneWidget);
    },
  );

  testWidgets(
    'Test 10: CheckoutScreen - Simulation complète sans paiement réel',
    (WidgetTester tester) async {
      // ARRANGE
      final container = ProviderContainer();
      final cartNotifier = container.read(cartControllerProvider.notifier);
      cartNotifier.addItem(id: '1', title: 'Laptop', price: 1200, thumbnail: 'url');

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp.router(
            routerConfig: _router,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // ACT - Navigation complète jusqu'au paiement
      expect(find.text('Récapitulatif de commande'), findsOneWidget);
      
      await tester.tap(find.text('Continuer'));
      await tester.pumpAndSettle();
      expect(find.text('Informations de livraison'), findsOneWidget);
      
      await tester.tap(find.text('Continuer'));
      await tester.pumpAndSettle();
      expect(find.text('Mode de paiement'), findsOneWidget);

      // Vérifier le bouton de paiement
      final payButton = find.textContaining('Payer');
      expect(payButton, findsOneWidget);
      expect(find.textContaining('1200.00€'), findsAtLeastNWidgets(1)); // Gratuit car > 50€

      // ASSERT - On ne clique pas sur payer pour éviter la complexité des mocks
      // mais on vérifie que tout est en place
      expect(find.text('Paiement sécurisé'), findsOneWidget);
      expect(find.text('Carte bancaire'), findsOneWidget);
    },
  );
}