import 'package:flutter_riverpod/flutter_riverpod.dart';

class CartItem {
  final String productId;
  final String title;
  final double price;
  final int quantity;
  final String thumbnail;

  const CartItem({
    required this.productId,
    required this.title,
    required this.price,
    required this.quantity,
    required this.thumbnail,
  });

  CartItem copyWith({int? quantity}) => CartItem(
    productId: productId,
    title: title,
    price: price,
    quantity: quantity ?? this.quantity,
    thumbnail: thumbnail,
  );
}

class CartState {
  final List<CartItem> items;
  const CartState(this.items);
  double get total => items.fold(0, (s, i) => s + i.price * i.quantity);
}

class CartController extends StateNotifier<CartState> {
  CartController() : super(const CartState(<CartItem>[]));

  void addItem({
    required String id,
    required String title,
    required double price,
    required String thumbnail,
  }) {
    final idx = state.items.indexWhere((e) => e.productId == id);
    if (idx == -1) {
      state = CartState([
        ...state.items,
        CartItem(
          productId: id,
          title: title,
          price: price,
          quantity: 1,
          thumbnail: thumbnail,
        ),
      ]);
    } else {
      final updated = [...state.items];
      updated[idx] = updated[idx].copyWith(quantity: updated[idx].quantity + 1);
      state = CartState(updated);
    }
  }

  void updateQty(String id, int qty) {
    final idx = state.items.indexWhere((e) => e.productId == id);
    if (idx == -1) return;
    final updated = [...state.items];
    if (qty <= 0) {
      updated.removeAt(idx);
    } else {
      updated[idx] = updated[idx].copyWith(quantity: qty);
    }
    state = CartState(updated);
  }

  void clear() => state = const CartState(<CartItem>[]);
}

final cartControllerProvider = StateNotifierProvider<CartController, CartState>(
  (ref) => CartController(),
);
