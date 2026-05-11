import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'https://task.itprojects.web.id';

  final FlutterSecureStorage storage = const FlutterSecureStorage();

  Future<bool> login(String username, String password) async {
    final url = Uri.parse('$baseUrl/api/auth/login');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'username': username,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      String token = data['data']['token'];

      await storage.write(key: 'token', value: token);
      return true;
    }

    return false;
  }

  Future<String?> getToken() async {
    return await storage.read(key: 'token');
  }

  Future<List<dynamic>> getProducts() async {
    String? token = await getToken();

    final url = Uri.parse('$baseUrl/api/products');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['data']['products'];
    }

    return [];
  }

  Future<bool> createProduct(
    String name,
    int price,
    String description,
  ) async {
    String? token = await getToken();

    final url = Uri.parse('$baseUrl/api/products');

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'name': name,
        'price': price,
        'description': description,
      }),
    );

    return response.statusCode == 200 || response.statusCode == 201;
  }

  Future<bool> deleteProduct(int id) async {
    String? token = await getToken();

    final url = Uri.parse(
      '$baseUrl/api/products/$id',
    );

    final response = await http.delete(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    return response.statusCode == 200;
  }

  Future<Map<String, dynamic>> submitProduct(
    String name,
    int price,
    String description,
    String github,
  ) async {
    try {
      String? token = await getToken();

      final response = await http.post(
        Uri.parse('$baseUrl/api/products/submit'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'name': name,
          'price': price,
          'description': description,
          'github_url': github,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          "success": true,
          "message": data["message"] ?? "Submit berhasil",
        };
      } else {
        return {
          "success": false,
          "message": data["message"] ?? "Submit gagal: ${response.body}",
        };
      }
    } catch (e) {
      return {
        "success": false,
        "message": e.toString(),
      };
    }
  } 
}