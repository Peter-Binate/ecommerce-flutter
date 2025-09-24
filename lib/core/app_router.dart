import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/presentation/login_screen.dart';
import '../features/auth/presentation/register_screen.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/catalog/presentation/catalog_screen.dart';
import '../features/catalog/presentation/product_screen.dart';
import '../features/cart/presentation/cart_screen.dart';
import '../features/checkout/presentation/checkout_screen.dart';
import '../features/orders/presentation/orders_screen.dart';

GoRouter createAppRouter() {
  final auth = FirebaseAuth.instance;

  return GoRouter(
    initialLocation: '/catalog',
    refreshListenable: GoRouterRefreshStream(auth.authStateChanges()),
    redirect: (context, state) {
      final bool isLoggedIn = auth.currentUser != null;
      final bool isAuthRoute = state.matchedLocation == '/login' || state.matchedLocation == '/register';

      if (!isLoggedIn && !isAuthRoute) {
        return '/login';
      }
      if (isLoggedIn && isAuthRoute) {
        return '/catalog';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/catalog',
        builder: (context, state) => const CatalogScreen(),
        routes: [
          GoRoute(
            path: 'product/:id',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return ProductScreen(productId: id);
            },
          ),
        ],
      ),
      GoRoute(
        path: '/product/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return ProductScreen(productId: id);
        },
      ),
      GoRoute(
        path: '/cart',
        builder: (context, state) => const CartScreen(),
      ),
      GoRoute(
        path: '/checkout',
        builder: (context, state) => const CheckoutScreen(),
      ),
      GoRoute(
        path: '/orders',
        builder: (context, state) => const OrdersScreen(),
      ),
    ],
  );
}

/// Permet de rafraîchir GoRouter lorsque le stream d'auth change
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListener = () => notifyListeners();
    subscription = stream.asBroadcastStream().listen((_) => notifyListener());
  }

  late final VoidCallback notifyListener;
  late final StreamSubscription<dynamic> subscription;

  @override
  void dispose() {
    subscription.cancel();
    super.dispose();
  }
}


