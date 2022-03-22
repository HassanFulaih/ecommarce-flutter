import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/http_exception.dart';

class Auth with ChangeNotifier {
  String? _token;
  String? _userId;

  String? name;
  String? phoneNumber;
  String? governorate;
  String? region;

  bool get isAuth {
    return token != null;
  }

  String? get token {
    if (_token != null) {
      return _token;
    }
    return null;
  }

  String? get userId {
    return _userId;
  }

  Future<void> _authenticate(
    phoneNumber,
    password, {
    String? name,
    String? governorate,
    String? region,
  }) async {
    final urlSegment = name != null ? 'register' : 'login';
    final String url = 'http://localhost:8000/api/$urlSegment';
    try {
      var res = await Dio().post(url,
          data: {
            'name': name,
            'phone_number': phoneNumber,
            'governorate': governorate,
            'region': region,
            'password': password,
            'password_confirmation': password,
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

      final responseData = res.data;

      if (responseData['errors'] == null && responseData['message'] != null) {
        throw HttpException(responseData['message']);
      } else if (responseData['errors'] != null &&
          responseData['message'] != null) {
        throw HttpException(responseData['errors']['phone_number'][0]);
      }

      _token = responseData['token'];
      _userId = responseData['user']['id'].toString();
      name = responseData['user']['name'];
      phoneNumber = responseData['user']['phone_number'];
      governorate = responseData['user']['governorate'];
      region = responseData['user']['region'];

      notifyListeners();
      final prefs = await SharedPreferences.getInstance();
      String userData = json.encode({
        'token': _token,
        'userId': _userId,
        'name': name,
        'phoneNumber': phoneNumber,
        'governorate': governorate,
        'region': region,
      });
      prefs.setString('userData', userData);
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<void> update(String name, String phoneNumber, String governorate,
      String region, String password, String passwordConfirmation) async {
    final dio = Dio();
    dio.options.headers['Authorization'] = 'Bearer $token';
    final url = 'http://localhost:8000/api/user/$userId';
    try {
      var res = await dio.put(url, data: {
        'name': name,
        'phone_number': phoneNumber,
        'governorate': governorate,
        'region': region,
        'password': password,
        'password_confirmation': passwordConfirmation,
      }, queryParameters: {
        'Accept': 'application/json',
      });

      if (res.data['errors'] != null) {
        throw HttpException(res.data['message']);
      }
      //_token = res.data['token'];
      //_userId = res.data['user']['id'].toString();
      name = res.data['name'];
      phoneNumber = res.data['phone_number'];
      governorate = res.data['governorate'];
      log(res.data['city']);
      region = res.data['city'];

      notifyListeners();
      final prefs = await SharedPreferences.getInstance();
      String userData = json.encode({
        'token': _token,
        'userId': _userId,
        'name': name,
        'phoneNumber': phoneNumber,
        'governorate': governorate,
        'region': region,
      });
      prefs.setString('userData', userData);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signUp(name, phoneNumber, governorate, region, password) async {
    return _authenticate(phoneNumber, password,
        name: name, governorate: governorate, region: region);
  }

  Future<void> login(String phoneNumber, String password) async {
    return _authenticate(phoneNumber, password);
  }

  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userData')) return false;

    final Map<String, dynamic> extractedData =
        json.decode(prefs.getString('userData')!) as Map<String, dynamic>;

    _userId = extractedData['userId'] as String;
    _token = extractedData['token'] as String;
    name = extractedData['name'] as String;
    phoneNumber = extractedData['phoneNumber'] as String;
    governorate = extractedData['governorate'] as String;
    region = extractedData['region'] as String?;

    notifyListeners();
    return true;
  }

  Future<void> logout() async {
    final dio = Dio();
    dio.options.headers['Authorization'] = 'Bearer $token';
    const url = 'http://127.0.0.1:8000/api/logout';
    try {
      var res = await dio.post(url, queryParameters: {
        'Accept': 'application/json',
      });
      if (res.data['errors'] != null) {
        throw HttpException(res.data['message']);
      }
      //print('res.data: ${res.data}');
      log(res.data['message']);
    } catch (e) {
      log('error: $e');
    }

    name = null;
    phoneNumber = null;
    governorate = null;
    region = null;

    _token = null;
    _userId = null;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    prefs.clear();

    log('logout${prefs.getKeys()}');
  }

  Future<void> delete() async {
    final dio = Dio();
    dio.options.headers['Authorization'] = 'Bearer $token';
    final url = 'http://127.0.0.1:8000/api/user/$userId';
    try {
      var res = await dio.delete(url, queryParameters: {
        'Accept': 'application/json',
      });
      if (res.data['errors'] != null) {
        throw HttpException(res.data['message']);
      }
      //print('res.data: ${res.data}');
      if (res.data['message'] == 'Successfully Deleted') {
        name = null;
        phoneNumber = null;
        governorate = null;
        region = null;

        _token = null;
        _userId = null;
        notifyListeners();

        final prefs = await SharedPreferences.getInstance();
        prefs.clear();
      }
    } catch (e) {
      log('error: $e');
    }
  }
}
