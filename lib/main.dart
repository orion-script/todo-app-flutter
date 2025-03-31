import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/initial_screen.dart';
import 'screens/home_screen.dart';

void main() {
  testApi();
  runApp(const MyApp());
}

Future<void> testApi() async {
  debugPrint("🔄 Testing API Connection...");
  try {
    var url = Uri.parse("https://todo-api-three-snowy.vercel.app");
    var response = await http.get(url);
    debugPrint("✅ Status Code: ${response.statusCode}");
    debugPrint("📝 Response Body: ${response.body}");
  } catch (e) {
    debugPrint("❌ API Error: $e");
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  bool? isLoggedIn;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isLoggedIn = prefs.getString('token') != null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoggedIn == null) {
      return const MaterialApp(
        home: Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter To-Do App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: isLoggedIn! ? const HomeScreen() : const AccountScreen(),
    );
  }
}
