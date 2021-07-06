import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';

import './cart.dart';

class Order {
  final String id;
  final double total;
  final List<CartItem> products;
  final DateTime date;

  Order({
    this.id,
    this.total,
    this.products,
    this.date,
  });
}

class Orders with ChangeNotifier {
  List<Order> _items = [];

  List<Order> get items {
    return [..._items];
  }

  int get itemsCount {
    return _items.length;
  }

  Future<void> addOrder(Cart cart) async {
    try {
      final data = DateTime.now();
      final url = Uri.parse(
          "https://flutter-test-coder-default-rtdb.firebaseio.com/orders.json");
      final response = await http.post(
        url,
        body: jsonEncode(
          {
            'total': cart.totalAmount,
            'date': data.toIso8601String(),
            'products': cart.items.values
                .map((e) => {
                      'id': e.id,
                      'productId': e.productId,
                      'title': e.title,
                      'quantity': e.quantity,
                      'price': e.price,
                    })
                .toList(),
          },
        ),
      );
      _items.insert(
        0,
        Order(
          id: jsonDecode(response.body)['name'],
          total: cart.totalAmount,
          date: data,
          products: cart.items.values.toList(),
        ),
      );

      notifyListeners();
    } catch (e) {}
  }
}
