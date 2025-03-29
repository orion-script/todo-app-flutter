import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'auth_service.dart';

class TodoService {
  static const String baseUrl = "https://todo-api-three-snowy.vercel.app";
  // static const String baseUrl =
  //     "https://todo-33hzc3d83-orionscripts-projects.vercel.app";

  static Future<List<Map<String, dynamic>>?> getTodos() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('access_token');

      if (token == null) {
        // print("Error: No token found. User might not be logged in.");
        return null;
      }

      // print("🔑 Token being used: $token");

      final response = await http.get(
        Uri.parse("$baseUrl/todos"),
        headers: {
          "Authorization": "Bearer $token",
          'Accept': 'application/json',
        },
      );

      // print("Response Status Code: ${response.statusCode}");
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else if (response.statusCode == 401) {
        // print("🔄 Token expired, trying to refresh...");

        // Call the refresh token function
        bool refreshed = await AuthService.refreshAccessToken();
        if (refreshed) {
          return await getTodos();
        } else {
          // print("❌ Token refresh failed, user must log in again.");
          return null;
        }
      } else {
        // print("Error: ${response.statusCode}");
        // print("Response Body: ${response.body}");
        return null;
      }
    } catch (error) {
      // print("Exception: $error");
      return null;
    }
  }

  // Function to create a new todo
  static Future<String?> addTodo({
    required String title,
    required String description,
    required String dueDate,
  }) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('access_token');

      if (token == null) {
        print("❌ No token found.");
        return "User not authenticated";
      }

      // Convert dueDate from "dd/MM/yyyy" to "yyyy-MM-dd"
      DateTime parsedDate = DateFormat("dd/MM/yyyy").parse(dueDate);
      String formattedDate = DateFormat("yyyy-MM-dd").format(parsedDate);

      print("🔑 Using Token: $token");

      final newTodo = {
        "title": title,
        "description": description,
        "dueDate": formattedDate,
      };

      final response = await http.post(
        Uri.parse("$baseUrl/todos"),
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
          "Content-Type": "application/json",
        },
        body: jsonEncode(newTodo),
      );
      print("newTodo: $newTodo");
      print("Response Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 201) {
        return null;
      } else if (response.statusCode == 401) {
        print("🔄 Token expired, refreshing...");
        bool refreshed = await AuthService.refreshAccessToken();
        if (refreshed) {
          print("✅ Retrying with new token...");
          return await addTodo(
              title: title, description: description, dueDate: dueDate);
        }
      }

      print("❌ Error adding Todo: ${response.body}");
      return "Failed to add Todo";
    } catch (error) {
      print("❌ Exception: $error");
      return "An error occurred: $error";
    }
  }

// ✅ Mark Todo as Completed
  static Future<bool> markTodoCompleted(String id) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('access_token');
      if (token == null) return false;

      final response = await http.patch(
        Uri.parse("$baseUrl/todos/$id/complete"),
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        },
      );

      print("🔹 Response Status Code: ${response.statusCode}");
      print("🔹 Response Body: ${response.body}");

      if (response.statusCode == 200) return true;

      if (response.statusCode == 401) {
        print("🔄 Token expired. Trying to refresh...");
        bool refreshed = await AuthService.refreshAccessToken();
        return refreshed ? await markTodoCompleted(id) : false;
      }

      print("❌ Error: Failed to mark todo as completed.");
      return false;
    } catch (error) {
      print("❌ Exception: $error");
      return false;
    }
  }

  // ✅ Delete a Todo
  static Future<bool> deleteTodo(String id) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('access_token');
      if (token == null) return false;

      final response = await http.delete(
        Uri.parse("$baseUrl/todos/$id"),
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        },
      );

      print("🔹 Response Status Code: ${response.statusCode}");
      print("🔹 Response Body: ${response.body}");

      if (response.statusCode == 200) return true;
      if (response.statusCode == 401) {
        print("🔄 Token expired. Trying to refresh...");
        bool refreshed = await AuthService.refreshAccessToken();
        return refreshed ? await deleteTodo(id) : false;
      }
      print("❌ Error: Failed to mark todo as completed.");
      return false;
    } catch (error) {
      print("❌ Exception: $error");
      return false;
    }
  }
}
