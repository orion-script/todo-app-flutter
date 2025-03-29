import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String baseUrl = "https://todo-api-three-snowy.vercel.app/auth";
  // static const String baseUrl =
  //     "https://todo-33hzc3d83-orionscripts-projects.vercel.app/auth";

  // Login Function
  // Login Function
  Future<String?> login(String email, String password) async {
    final response = await http.post(
      Uri.parse("$baseUrl/login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "password": password}),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(response.body);
      final accessToken = data['token']; // This is actually the accessToken
      final refreshToken = data['refreshToken'];
      final user = data['user'];

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          'access_token', accessToken); // ✅ Store as 'access_token'
      await prefs.setString(
          'refresh_token', refreshToken); // ✅ Store refresh token
      await prefs.setString('user', jsonEncode(user));

      print("✅ Login successful.");
      print("🔑 Access Token: $accessToken");
      print("🔄 Refresh Token: $refreshToken");

      return null;
    } else {
      final data = jsonDecode(response.body);
      print("❌ Login Failed: $data");
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

  // Refresh Access Token
  // static Future<bool> refreshAccessToken() async {
  //   try {
  //     SharedPreferences prefs = await SharedPreferences.getInstance();
  //     String? refreshToken =
  //         prefs.getString('refresh_token'); // ✅ Get refresh token correctly

  //     if (refreshToken == null) {
  //       print("❌ No refresh token found, user must log in again.");
  //       return false;
  //     }

  //     final response = await http.post(
  //       Uri.parse("$baseUrl/refresh-token"),
  //       headers: {"Content-Type": "application/json"},
  //       body: jsonEncode({"refreshToken": refreshToken}),
  //     );

  //     print(
  //         "🔄 Refresh Token Response: ${response.statusCode} - ${response.body}");

  //     if (response.statusCode == 200) {
  //       final data = jsonDecode(response.body);
  //       String newAccessToken = data["accessToken"];
  //       String newRefreshToken = data["refreshToken"];

  //       // ✅ Save the new tokens
  //       await prefs.setString('access_token', newAccessToken);
  //       await prefs.setString('refresh_token', newRefreshToken);

  //       print("✅ Token refreshed successfully.");
  //       print("🆕 New Access Token: $newAccessToken");
  //       print("🔄 New Refresh Token: $newRefreshToken");

  //       return true;
  //     } else {
  //       print("❌ Failed to refresh token: ${response.body}");
  //       return false;
  //     }
  //   } catch (error) {
  //     print("❌ Exception during token refresh: $error");
  //     return false;
  //   }
  // }

  static Future<bool> refreshAccessToken() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? refreshToken = prefs.getString('refresh_token');

      if (refreshToken == null) {
        print("❌ No refresh token found, user must log in again.");
        return false;
      }

      final response = await http.post(
        Uri.parse("$baseUrl/refresh-token"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"refreshToken": refreshToken}),
      );

      print(
          "🔄 Refresh Token Response: ${response.statusCode} - ${response.body}");

      // ✅ Check for 200 or 201 (whichever your API returns for success)
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        String newAccessToken = data["token"];
        String newRefreshToken = data["refreshToken"];

        await prefs.setString('access_token', newAccessToken);
        await prefs.setString('refresh_token', newRefreshToken);

        print("✅ Token refreshed successfully.");
        return true;
      } else {
        print("❌ Failed to refresh token: ${response.body}");
        return false;
      }
    } catch (error) {
      print("❌ Exception during token refresh: $error");
      return false;
    }
  }

  // Logout Function
  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('user'); // Remove user details
  }

  // Check if user is authenticated
  Future<bool> isAuthenticated() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token') != null;
  }

  // Get Stored User Details
  // Future<Map<String, dynamic>?> getUserDetails() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   String? userJson = prefs.getString('user');
  //   if (userJson == null) return null;
  //   return jsonDecode(userJson);
  // }
}
