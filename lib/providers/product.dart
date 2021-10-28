import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shop/utils/constantes.dart';

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavorite;

  Product({
    this.id,
    this.isFavorite = false,
    @required this.title,
    @required this.description,
    @required this.price,
    @required this.imageUrl,
  });

  void _toggleFavorite() {
    isFavorite = !isFavorite;
    notifyListeners();
  }

  Future<void> toggleFavorite() async {
    _toggleFavorite();

    try {
      final url = Uri.parse('${Constantes.PRODUCTS_API_URL}/$id.json');

      final response = await http.patch(
        url,
        body: jsonEncode(
          {
            'isFavorite': isFavorite,
          },
        ),
      );

      if (response.statusCode >= 400) {
        notifyListeners();
      }
    } catch (e) {
      _toggleFavorite();
    }
  }
}
