import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class TodoService {
  static const String baseUrl =
      "https://todo-33hzc3d83-orionscripts-projects.vercel.app";

  // Function to create a new todo
  static Future<String?> addTodo({
    required String title,
    required String description,
    required String dueDate,
  }) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      if (token == null) {
        print("❌ Error: No token found. User might not be logged in.");
        return "User not authenticated";
      }

      print("🔑 Token being used: $token");

      // ✅ Convert dueDate from "d/M/yyyy" → "yyyy-MM-dd"
      try {
        DateTime parsedDate =
            DateFormat("d/M/yyyy").parse(dueDate); // Parse input
        dueDate =
            DateFormat("yyyy-MM-dd").format(parsedDate); // Format correctly
      } catch (e) {
        print("❌ Error parsing date: $e");
        return "Invalid date format. Please use DD/MM/YYYY.";
      }

      final newTodo = {
        "title": title,
        "description": description.isNotEmpty ? description : null,
        "dueDate": dueDate, // Always correctly formatted now
      };

      print("📤 Sending Request...");
      print("📌 API URL: $baseUrl/todos");
      print("📌 Request Body: ${jsonEncode(newTodo)}");

      final response = await http.post(
        Uri.parse("$baseUrl/todos"),
        headers: {
          "Authorization": "Bearer $token",
          'Accept': 'application/json',
          "Content-Type": "application/json",
        },
        body: jsonEncode(newTodo),
      );

      print("📥 Response Status: ${response.statusCode}");
      print("📥 Response Body: ${response.body}");

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return null; // Success
      } else {
        final responseData = jsonDecode(response.body);
        return responseData["message"] ?? "Failed to add todo";
      }
    } catch (error) {
      print("❌ Exception: $error");
      return "An error occurred: $error";
    }
  }
}
