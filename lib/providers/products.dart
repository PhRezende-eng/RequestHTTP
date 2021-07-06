import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:shop/exceptions/http_exception.dart';
import './product.dart';

class Products with ChangeNotifier {
  List<Product> get items => [..._items];

  int get itemsCount {
    return _items.length;
  }

  List<Product> get favoriteItems {
    return _items.where((prod) => prod.isFavorite).toList();
  }

  List<Product> _items = [];

  Future<void> lodProducts() async {
    final _url = Uri.parse(
        'https://flutter-test-coder-default-rtdb.firebaseio.com/products.json');

    final response = await http.get(_url);

    Map<String, dynamic> data = jsonDecode(response.body);

    _items.clear();

    if (data != null) {
      data.forEach(
        (key, value) {
          _items.add(
            Product(
              id: key,
              title: value['title'],
              description: value['description'],
              price: value['price'],
              imageUrl: value['imageUrl'],
              isFavorite: value['isFavorite'],
            ),
          );
          notifyListeners();
        },
      );
    }
  }

  Future<void> addProduct(Product newProduct) async {
    final _url = Uri.parse(
        'https://flutter-test-coder-default-rtdb.firebaseio.com/products.json');

    final response = await http.post(
      _url,
      body: json.encode({
        'title': newProduct.title,
        'description': newProduct.description,
        'price': newProduct.price,
        'imageUrl': newProduct.imageUrl,
        'isFavorite': newProduct.isFavorite,
      }),
    );

    _items.add(
      Product(
        id: json.decode(response.body)['name'],
        title: newProduct.title,
        description: newProduct.description,
        price: newProduct.price,
        imageUrl: newProduct.imageUrl,
      ),
    );

    notifyListeners();
  }

  Future<void> updateProduct(Product product) async {
    if (product == null || product.id == null) {
      return;
    }

    final index = _items.indexWhere((prod) => prod.id == product.id);

    if (index >= 0) {
      final _urlId = Uri.parse(
          'https://flutter-test-coder-default-rtdb.firebaseio.com/products/${product.id}.json');

      await http.patch(
        _urlId,
        body: jsonEncode(
          {
            'title': product.title,
            'description': product.description,
            'price': product.price,
            'imageUrl': product.imageUrl,
          },
        ),
      );

      _items[index] = product;
      notifyListeners();
    }
  }

  Future<void> deleteProduct(String id) async {
    final index = _items.indexWhere((prod) => prod.id == id);
    if (index >= 0) {
      final product = _items[index];

      _items.removeWhere((prod) => prod.id == id);
      notifyListeners();

      final _urlId = Uri.parse(
          'https://flutter-test-coder-default-rtdb.firebaseio.com/products/${product.id}.json');

      final response = await http.delete(_urlId);

      if (response.statusCode >= 400) {
        _items.insert(index,
            product); // ---> aqui ele devolver para a lista igual estava antes
        notifyListeners();
        throw HttpException(
            'Ocorreu um erro, por isso, o item foi devolvido a lista de produtos!');
      }
    }
  }
}



//json.decoded ou jsonDecode =  transforma um json em map
//json.encode ou jsonEncode = transforma um map em json

//  _items
//         .clear(); // faz com que limpe o estado/lista de produtos sempre que iniciar a tela


// await http.delete(
//   _urlId,
//   body: jsonEncode(
//     {
//       id: id,
//     },
//   ),
// );

// Future<void> toggleFavorite() async {
//     _toggleFavorite();

//     try {
//       final url = Uri.parse(
//           'https://flutter-test-coder-default-rtdb.firebaseio.com/products/$id.json');

//       final response = await http.patch(
//         url,
//         body: jsonEncode(
//           {
//             'isFavorite': isFavorite,
//           },
//         ),
//       );

//       if (response.statusCode >= 400) {
//         notifyListeners();
//         print('error');
//       }
//     } catch (e) {
//       _toggleFavorite();
//     }
//   }