import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final String category;
  final double price;
  final String imageUrl;
  bool isFavorite;

  Product({
    required this.id,
    required this.title,
    required this.category,
    required this.description,
    required this.price,
    required this.imageUrl,
    this.isFavorite = false,
  });

  void _setFavValue(bool newValue) {
    isFavorite = newValue;
    notifyListeners();
  }

  Future<void> toggleFavoriteStatus(String? token, String? userId) async {
    final oldStatus = isFavorite;
    isFavorite = !isFavorite;
    notifyListeners();

    if (token == null || userId == null) return;

    Map<String, dynamic> favMap = {};
    final dio = Dio();
    dio.options.headers['Authorization'] = 'Bearer $token';
    String url = 'http://localhost:8000/api/userFavorites';
    final favRes = await dio.get(url);
    for (var favItem in favRes.data) {
      // print('We are in the for loop');
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
        favMap = json.decode(favItem['products_id']) as Map<String, dynamic>;

        // ignore: unnecessary_string_interpolations, prefer_single_quotes
        favMap["$id"] = "$isFavorite";
      }
    }

    // ignore: unnecessary_string_interpolations, prefer_single_quotes
    favMap["$id"] = "$isFavorite";
   

    String modifiedFavMap = json.encode(favMap);
    modifiedFavMap = modifiedFavMap
        .split('","')
        .join(', ')
        .split('":"')
        .join(':')
        .split('{"')
        .join('{')
        .split('"}')
        .join('}');

    // modifiedFavMap = b;
    // b = modifiedFavMap;
    // modifiedFavMap = b;
    // b = modifiedFavMap;
    // modifiedFavMap = b;
    // b = modifiedFavMap;
    // modifiedFavMap = b;

  

    url = 'http://localhost:8000/api/userFavorites/$userId';
    try {
      final res = await dio.put(url, data: {
        'user_id': userId,
        'products_id': modifiedFavMap, // '{"$id":"$isFavorite"}',
      });
      if (res.statusCode! >= 400) {
        _setFavValue(oldStatus);
      }
    } catch (e) {
      log('error: ${e.toString()}');
      _setFavValue(oldStatus);
      rethrow;
    }
  }
}
