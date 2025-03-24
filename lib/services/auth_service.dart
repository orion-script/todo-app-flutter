import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final String baseUrl =
      "https://todo-33hzc3d83-orionscripts-projects.vercel.app/auth";

  // Login Function
  Future<String?> login(String email, String password) async {
    final response = await http.post(
      Uri.parse("$baseUrl/login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "password": password}),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(response.body);
      final token = data['token'];
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);
      return null;
    } else {
      final data = jsonDecode(response.body);
      return data['message'] ?? "Login failed. Please try again.";
    }
  }

  // Register Function
  Future<String?> register(String name, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/signup"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"name": name, "email": email, "password": password}),
      );

      if (response.statusCode == 201) {
        return null;
      } else {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        return responseData["message"] ?? "Registration failed";
      }
    } catch (e) {
      return "An error occurred. Please try again.";
    }
  }

  // Logout Function
  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }

  // Check if user is authenticated
  Future<bool> isAuthenticated() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token') != null;
  }
}
