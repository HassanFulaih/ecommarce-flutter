import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../models/http_exception.dart';
import './product.dart';

class Products with ChangeNotifier {
  List<Product> _items = [
    // Product(
    //   id: 'p1',
    //   title: 'Red Shirt',
    //   description: 'A red shirt - it is pretty red!',
    //   price: 29.99,
    //   imageUrl:
    //       'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
    // ),
    // Product(
    //   id: 'p2',
    //   title: 'Trousers',
    //   description: '59.99',
    //   price: 59.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
    // ),
    // Product(
    //   id: 'p3',
    //   title: 'Yellow Scarf',
    //   description: 'Warm and cozy - exactly what you need for the winter.',
    //   price: 19.99,
    //   imageUrl:
    //       'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
    // ),
    // Product(
    //   id: 'p4',
    //   title: 'A Pan',
    //   description: 'Prepare any meal you want.',
    //   price: 49.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
    // ),
  ];
  String? authToken;
  String? userId;

  bool isListView = false;
  String catView = 'أدوية';

  switchView() {
    isListView = !isListView;
    notifyListeners();
  }

  switchCatView(String cat) {
    catView = cat;
    isListView = !isListView;
    notifyListeners();
  }

  getData(String? authTok, String? uId, List<Product> products) {
    authToken = authTok;
    userId = uId;
    _items = products;
    notifyListeners();
  }

  List<Product> get items {
    return [..._items];
  }

  List<Product> get favoriteItems {
    return _items.where((prodItem) => prodItem.isFavorite).toList();
  }

  _getFavState() async {
    final dio = Dio();
    dio.options.headers['Authorization'] = 'Bearer $authToken';
    const url = 'http://localhost:8000/api/userFavorites';

    final favRes = await dio.get(url);
    //print('favRes.data: ${favRes.data}');
    for (var favItem in favRes.data) {
      if (favItem['user_id'] == userId) {
        favItem['products_id'] = favItem['products_id']
            .split(', ')
            .join('","')
            .split(':')
            .join('":"')
            .split('{')
            .join('{"')
            .split('}')
            .join('"}');
        // favItem['products_id'] = b;
        // b = favItem['products_id'];
        // favItem['products_id'] = b;
        // b = favItem['products_id'];
        // favItem['products_id'] = b;
        // b = favItem['products_id'];
        // favItem['products_id'] = b;

        // print('favItem[user_id]: ${favItem['user_id']}');
        // print('favItem[products_id]: ${favItem['products_id']}');
        final Map<String, dynamic> favMap =
            json.decode(favItem['products_id']) as Map<String, dynamic>;
        // print('favMap.entries: ${favMap.entries}');
        favMap.forEach((String key, dynamic value) {
          // print('key: $key, value: $value');
          _items.firstWhere((prod) => prod.id == key).isFavorite =
              (value == 'true');
        });
      }
    }
  }

  Product findById(String id) {
    // var url = 'http://127.0.0.1:8000/api/products/$id';
    // Dio().get(url, queryParameters: {
    //   'Accept': 'application/json',
    // }).then((res) {
    //   return Product(
    //       id: res.data['id'].toString(),
    //       title: res.data['name'],
    //       category: res.data['category'],
    //       description: res.data['description'].toString(), //description
    //       price: double.parse(res.data['price']),
    //       isFavorite: false,
    //       imageUrl: res.data['image_url'],
    //     );
    // });

    return _items.firstWhere((prod) => prod.id == id);
  }

  Future<void> fetchAndSetProducts([bool filterByUser = false]) async {
    //final filterString = filterByUser ? 'orderBy="creatorId"&equalTo="$userId"' : '';
    var url = 'http://127.0.0.1:8000/api/products';
    try {
      // final res = await http.get(Uri.parse(url), headers: {
      //   'Accept': 'application/json',
      // });

      //final extractedData = json.decode(res.body) as List<dynamic>;
      // if (extractedData == null) {
      //   return;
      // }
      final res = await Dio().get(url, queryParameters: {
        'Accept': 'application/json',
      });
      final List<Product> loadedProducts = [];

      for (var prodData in res.data) {
        loadedProducts.add(
          Product(
            id: prodData['id'].toString(),
            title: prodData['name'],
            category: prodData['category'],
            description: prodData['description'] ?? '',
            price: double.parse(prodData['price']),
            isFavorite: false,
            imageUrl: prodData['image_url'],
          ),
        );
      }
      _items = loadedProducts;
      await _getFavState();
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> addProduct(Product product) async {
    final dio = Dio();
    dio.options.headers['Authorization'] = 'Bearer $authToken';
    const url = 'http://127.0.0.1:8000/api/products';
    try {
      var res = await dio.post(url,
          data: {
            'name': product.title,
            'category': product.category,
            'description': product.description,
            'image_url': product.imageUrl,
            'price': product.price,
          },
          queryParameters: {
            'Accept': 'application/json',
          },
          options: Options(
            followRedirects: false,
            validateStatus: (status) {
              return status! < 500;
            },
          ));
      if (res.data['errors'] != null) {
        throw HttpException(res.data['message']);
      }
      final newProduct = Product(
        id: res.data['id'].toString(),
        title: product.title,
        category: product.category,
        description: product.description,
        imageUrl: product.imageUrl,
        price: product.price,
      );
      _items.add(newProduct);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateProduct(String id, Product product) async {
    final dio = Dio();
    dio.options.headers['Authorization'] = 'Bearer $authToken';
    final prodIndex = _items.indexWhere((prod) => prod.id == id);
    if (prodIndex >= 0) {
      final url = 'http://127.0.0.1:8000/api/products/$id';
      await dio.put(url,
          data: {
            'name': product.title,
            'category': product.category,
            'description': product.description,
            'image_url': product.imageUrl,
            'price': product.price,
          },
          options: Options(
            followRedirects: false,
            validateStatus: (status) {
              return status! < 500;
            },
          ));
      _items[prodIndex] = product;
      notifyListeners();
    } else {
      //print('...');
    }
  }

  Future<void> deleteProduct(String id) async {
    final dio = Dio();
    dio.options.headers['Authorization'] = 'Bearer $authToken';
    final url = 'http://127.0.0.1:8000/api/products/$id';
    final existingproductIndex = _items.indexWhere((prod) => prod.id == id);
    Product? existingproduct = _items[existingproductIndex];
    _items.removeAt(existingproductIndex);
    notifyListeners();

    final res = await dio.delete(url);
    if (res.statusCode! >= 400) {
      _items.insert(existingproductIndex, existingproduct);
      notifyListeners();
      throw HttpException('لا يمكن حذف المنتج');
    }
    existingproduct = null;
  }
}
