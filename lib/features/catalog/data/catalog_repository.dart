import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/product.dart';

class CatalogRepository {
  CatalogRepository({http.Client? client}) : _client = client ?? http.Client();

  static const String _cacheProductsKey = 'cache_products_v1';
  static const String _cacheProductPrefix = 'cache_product_';
  final http.Client _client;

  Future<List<Product>> fetchProducts() async {
    // 1. Essaye le réseau avec la bonne URL
    try {
      final uri = Uri.parse('https://fakestoreapi.com/products');
      final response = await _client.get(uri).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        // fakestoreapi retourne une liste directement
        final List list = json.decode(response.body) as List;
        final products = list.map((e) => Product.fromJson(e as Map<String, dynamic>)).toList();
        
        // La logique de cache reste la même
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_cacheProductsKey, json.encode(products.map((e) => e.toJson()).toList()));
        return products;
      }
    } catch (_) {
      // ignore: avoid_catches_without_on_clauses
    }
    // 2. Fallback cache
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString(_cacheProductsKey);
    if (cached != null) {
      final List list = json.decode(cached) as List;
      return list.map((e) => Product.fromJson(e as Map<String, dynamic>)).toList();
    }
    return const <Product>[];
  }

  Future<Product?> fetchProduct(String id) async {
    // 1. Essaye le réseau
    try {
      final uri = Uri.parse('https://fakestoreapi.com/products/$id'); // <-- URL MISE À JOUR
      final response = await _client.get(uri).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final p = Product.fromJson(data);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('$_cacheProductPrefix$id', json.encode(p.toJson()));
        return p;
      }
    } catch (_) {}
    // 2. Fallback cache
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString('$_cacheProductPrefix$id');
    if (cached != null) {
      return Product.fromJson(json.decode(cached) as Map<String, dynamic>);
    }
    return null;
  }
}
// import 'dart:convert';

// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';

// import '../domain/product.dart';

// /// Repository du catalogue utilisant une API publique (Fake Store)
// /// avec un cache local simple via SharedPreferences.
// class CatalogRepository {
//   CatalogRepository({http.Client? client}) : _client = client ?? http.Client();

//   static const String _cacheProductsKey = 'cache_products_v1';
//   static const String _cacheProductPrefix = 'cache_product_';
//   final http.Client _client;

//   Future<List<Product>> fetchProducts() async {
//     // 1. Essaye le réseau
//     try {
//       final uri = Uri.parse('https://dummyjson.com/products?limit=50');
//       final response = await _client.get(uri).timeout(const Duration(seconds: 10));
//       if (response.statusCode == 200) {
//         final data = json.decode(response.body) as Map<String, dynamic>;
//         final List list = (data['products'] as List?) ?? const [];
//         final products = list.map((e) => Product.fromJson(e as Map<String, dynamic>)).toList();
//         // Cache la liste
//         final prefs = await SharedPreferences.getInstance();
//         await prefs.setString(_cacheProductsKey, json.encode(products.map((e) => e.toJson()).toList()));
//         return products;
//       }
//     } catch (_) {
//       // ignore: avoid_catches_without_on_clauses
//     }
//     // 2. Fallback cache
//     final prefs = await SharedPreferences.getInstance();
//     final cached = prefs.getString(_cacheProductsKey);
//     if (cached != null) {
//       final List list = json.decode(cached) as List;
//       return list.map((e) => Product.fromJson(e as Map<String, dynamic>)).toList();
//     }
//     return const <Product>[];
//   }

//   Future<Product?> fetchProduct(String id) async {
//     // 1. Essaye le réseau
//     try {
//       final uri = Uri.parse('https://dummyjson.com/products/$id');
//       final response = await _client.get(uri).timeout(const Duration(seconds: 10));
//       if (response.statusCode == 200) {
//         final data = json.decode(response.body) as Map<String, dynamic>;
//         final p = Product.fromJson(data);
//         final prefs = await SharedPreferences.getInstance();
//         await prefs.setString('$_cacheProductPrefix$id', json.encode(p.toJson()));
//         return p;
//       }
//     } catch (_) {}
//     // 2. Fallback cache
//     final prefs = await SharedPreferences.getInstance();
//     final cached = prefs.getString('$_cacheProductPrefix$id');
//     if (cached != null) {
//       return Product.fromJson(json.decode(cached) as Map<String, dynamic>);
//     }
//     return null;
//   }
// }


