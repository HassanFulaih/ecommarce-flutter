import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../providers/cart.dart';

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime dateTime;

  OrderItem({
    required this.id,
    required this.amount,
    required this.products,
    required this.dateTime,
  });
}

final Map<String, String> _categories = {
  'أدوية': 'orders',
  'مواد طبية': 'morders',
  'مواد تجميلية': 'corders',
};

class Orders with ChangeNotifier {
  List<OrderItem> _orders = [];
  String authToken = '';
  String userId = '';

  String _name = '';
  String _phoneNumber = '';
  String _governorate = '';
  String _region = '';

  getData(
    String authTok,
    String uId,
    List<OrderItem> orders, {
    required String name,
    required String phoneNumber,
    required String governorate,
    required String region,
  }) {
    authToken = authTok;
    userId = uId;
    _name = name;
    _phoneNumber = phoneNumber;
    _governorate = governorate;
    _region = region;
    _orders = orders;
    notifyListeners();
  }

  List<OrderItem> get orders {
    return [..._orders];
  }

  List<dynamic> filteredByCategory(
      List<CartItem> cartProduct, String category) {
    double filteredAmount = 0.0;
    return [
      cartProduct.where((cart) {
        if (cart.category == category) {
          filteredAmount += cart.price * cart.quantity;
        }
        return cart.category == category;
      }).toList(),
      filteredAmount
    ];
  }

  Future<void> fetchAndSetOrders() async {
    final dio = Dio();
    dio.options.headers['Authorization'] = 'Bearer $authToken';
    final List<OrderItem> loadedOrders = [];

    try {
      for (var key in _categories.keys) {
        final url = 'http://localhost:8000/api/${_categories[key]}/$userId';

        final Response res = await dio.get(url);
        if (res.data == null) continue;
        //final extractedData = res.data;
        //print('res.data: ${res.data}');

        // final List<dynamic> loadedOrdersData = json.decode(res.data);
        for (var extractedData in res.data) {
          extractedData['products'] = extractedData['products']
              .split(', ')
              .join('","')
              .split(':')
              .join('":"')
              .split('{ ')
              .join('{"')
              .split(' }')
              .join('"}');
          //print('extractedData: ${extractedData['products']}');
          var list = json.decode('${extractedData['products']}');
          loadedOrders.add(
            OrderItem(
              id: extractedData['id'].toString(),
              amount: double.parse(extractedData['amount'].toString()),
              dateTime: DateTime.parse(extractedData['date_time']),
              products: [
                ...list.map((dynamic item) => CartItem(
                      id: item['id'],
                      category: key,
                      price: double.parse(item['price']),
                      quantity: int.parse(item['quantity']),
                      title: item['title'],
                    ))
              ],
            ),
          );
        }
        _orders = loadedOrders.reversed.toList();
        notifyListeners();
      }
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<void> addOrder(List<CartItem> cProduct, double total) async {
    final dio = Dio();
    dio.options.headers['Authorization'] = 'Bearer $authToken';
    for (var key in _categories.keys) {
      var returedValues = filteredByCategory(cProduct, key);
      var cartProduct = returedValues[0];
      if (cartProduct.length == 0) continue;
     // String t = json.encode(cartProduct);
      // t = t
      //     .split('","')
      //     .join(',')
      //     .split('":"')
      //     .join(':')
      //     .split('{"')
      //     .join('{')
      //     .split('"}')
      //     .join('}');
      //cartProduct = json.decode(t);

      String cartPhrase = json.encode(cartProduct
              .map((cp) => {
                    ' id': cp.id,
                    ' title': cp.title,
                    // ignore: prefer_single_quotes
                    ' quantity': "${cp.quantity}",
                    // ignore: prefer_single_quotes
                    ' price': "${cp.price} ",
                  })
              .toList());

        String modifiedCartPhrase = cartPhrase
            .split('","')
            .join(',')
            .split('":"')
            .join(':')
            .split('{"')
            .join('{')
            .split('"}')
            .join('}');

      var filteredAmount = returedValues[1];

      final url = 'http://localhost:8000/api/${_categories[key]}';
      try {
        final timestamp = DateTime.now();
        final res = await dio.post(url, data: {
          'user_id': userId,
          'name': _name,
          'phone_number': _phoneNumber,
          'governorate': _governorate,
          'region': _region,
          'amount': filteredAmount,
          'date_time': timestamp.toIso8601String(),
          'products': modifiedCartPhrase,
        }, queryParameters: {
          'Accept': 'application/json',
        });
        _orders.insert(
            0,
            OrderItem(
              id: res.data['id'].toString(),
              amount: total,
              dateTime: timestamp,
              products: cartProduct,
            ));
        notifyListeners();
      } catch (e) {
        rethrow;
      }
    }
  }
}
