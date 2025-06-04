import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:bleutooth/services/BaseUrl.dart';

class AuthService {
  final String baseUrl = ChromeUrl;

  /// Register a new user
  Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('$baseUrl/register');
    print("🔁 Sending registration to: $url");

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "username": username,
          "email": email,
          "password": password,
        }),
      );

      print("📥 Register response code: ${response.statusCode}");
      print("📥 Register response body: ${response.body}");

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        final responseBody = jsonDecode(response.body);
        throw Exception(responseBody['error'] ?? 'An unknown error occurred during registration');
      }
    } catch (e) {
      print("❌ Registration error: $e");
      throw Exception("Registration failed: $e");
    }
  }

  /// Login with username and password
  Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    final url = Uri.parse('$baseUrl/login');
    print("🔁 Sending login to: $url");

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "username": username,
          "password": password,
        }),
      );

      print("📥 Login response code: ${response.statusCode}");
      print("📥 Login response body: ${response.body}");

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final responseBody = jsonDecode(response.body);
        throw Exception(responseBody['error'] ?? 'Invalid login credentials');
      }
    } catch (e) {
      print("❌ Login error: $e");
      throw Exception("Login failed: $e");
    }
  }

  Future<void> registerFcmToken({

    required String fcmToken,
    String? deviceInfo,
  }) async {
    final url = Uri.parse('$baseUrl/register-token');
    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({"token": fcmToken, "device_info": deviceInfo ?? ""}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to register FCM token');
    }
  }

}
