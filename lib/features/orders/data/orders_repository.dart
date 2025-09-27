import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class OrderRecord {
  final String id;
  final double total;
  final DateTime createdAt;
  const OrderRecord({
    required this.id,
    required this.total,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'total': total,
    'createdAt': createdAt.toIso8601String(),
  };

  factory OrderRecord.fromJson(Map<String, dynamic> json) => OrderRecord(
    id: json['id'] as String,
    total: (json['total'] as num).toDouble(),
    createdAt: DateTime.parse(json['createdAt'] as String),
  );
}

class OrdersRepository {
  static const String _ordersKey = 'orders_v1';

  Future<List<OrderRecord>> getOrders() async {
    final prefs = await SharedPreferences.getInstance();
    final s = prefs.getString(_ordersKey);
    if (s == null) return const <OrderRecord>[];
    final List list = json.decode(s) as List;
    return list
        .map((e) => OrderRecord.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> addOrder(OrderRecord order) async {
    final list = await getOrders();
    final updated = [order, ...list];
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _ordersKey,
      json.encode(updated.map((e) => e.toJson()).toList()),
    );
  }
}
