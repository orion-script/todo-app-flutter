import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class UserService {
  static Future<String> getUserName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) {
      throw Exception("User not logged in");
    }

    final response = await http.get(
      Uri.parse(
          'https://todo-33hzc3d83-orionscripts-projects.vercel.app/users/profile'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['name'];
    } else {
      throw Exception("Failed to fetch user name");
    }
  }

  //Get User Details
  // static Future<Map<String, dynamic>?> getUserDetails() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   String? token = prefs.getString('token');

  //   if (token == null) {
  //     throw Exception("User not logged in");
  //   }

  //   final response = await http.get(
  //     Uri.parse(
  //         'https://todo-33hzc3d83-orionscripts-projects.vercel.app/users/profile'),
  //     headers: {'Authorization': 'Bearer $token'},
  //   );

  //   if (response.statusCode == 200) {
  //     final data = json.decode(response.body);
  //     return data;
  //   } else {
  //     throw Exception("Failed to fetch user details");
  //   }
  // }

  static Future<Map<String, dynamic>?> getUserDetails() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      if (token == null) {
        print("⚠️ No token found. User might not be logged in.");
        return null;
      }

      final response = await http.get(
        Uri.parse(
            'https://todo-33hzc3d83-orionscripts-projects.vercel.app/users/profile'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print("✅ User details fetched successfully: $data");
        return data;
      } else {
        print("❌ Failed to fetch user details: ${response.body}");
        return null;
      }
    } catch (e) {
      print("❌ Error fetching user details: $e");
      return null;
    }
  }
}
