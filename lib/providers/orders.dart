import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:shop/exceptions/http_exception.dart';
import 'package:shop/utils/constantes.dart';

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

  Future<void> loadOrder() async {
    try {
      final url = Uri.parse("${Constantes.ORDERS_API_URL}.json");
      final response = await http.get(url);
      Map<String, dynamic> data = jsonDecode(response.body);
      _items
          .clear(); //serve pra limpar a lista e não adicionar a mesma quando der o refresh
      if (data != null) {
        data.forEach((id, data) {
          _items.add(Order(
            id: id,
            total: data['total'],
            date: DateTime.parse(data['date']),
            products: (data['products'] as List<dynamic>).map((e) {
              return CartItem(
                id: e['id'],
                productId: e['productId'],
                title: e['title'],
                quantity: e['quantity'],
                price: e['price'],
              );
            }).toList(),
          ));
        });
        // _items = _items.reversed.toList();
        // return Future.value();
        notifyListeners();
      }
    } catch (e) {
      throw HttpException(e);
    }
  }

  Future<void> addOrder(Cart cart) async {
    try {
      final data = DateTime.now();
      final url = Uri.parse("${Constantes.ORDERS_API_URL}.json");
      // loadOrder();
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
