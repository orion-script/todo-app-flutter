import 'package:flutter/material.dart';
import 'package:flutter_analog_clock/flutter_analog_clock.dart';
// import '../services/auth_service.dart';
import '../services/user_service.dart';
import '../services/todo_service.dart';
import 'all_tasks_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  String? userName;

  @override
  void initState() {
    super.initState();
    _fetchUserName();
  }

  Future<void> _fetchUserName() async {
    Map<String, dynamic>? userDetails = await UserService.getUserDetails();

    debugPrint("🔍 User details in _fetchUserName(): $userDetails");

    setState(() {
      userName = userDetails?['name']?.split(' ').last ?? 'User';
    });
  }

  // Future<void> _createTodo() async {
  //   Map<String, dynamic>? userDetails = await UserService.getUserDetails();

  //   debugPrint("🔍 User details in _fetchUserName(): $userDetails");

  //   setState(() {
  //     userName = userDetails?['name']?.split(' ').last ?? 'User';
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      HomePage(userName: userName),
      const AllTasksScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: "All Tasks"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  final String? userName;

  const HomePage({super.key, this.userName});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  DateTime? _selectedDate;

  bool _isLoading = false;

  Future<void> _addTodo() async {
    setState(() {
      _isLoading = true;
    });

    String? errorMessage = await TodoService.addTodo(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      dueDate: _dateController.text.trim(),
    );

    setState(() {
      _isLoading = false;
    });

    if (errorMessage == null) {
      if (!mounted) return;
      // Success
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Todo created successfully")),
      );

      // Clear input fields
      _titleController.clear();
      _descriptionController.clear();
      _dateController.clear();
    } else {
      if (!mounted) return;
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    }
  }

  // 📅 Function to open the date picker
  Future<void> _pickDueDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
        _dateController.text =
            "${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 60),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Text(
              "Hey 👋 ${widget.userName ?? '...'}",
              style: const TextStyle(
                color: Color(0xFF252C34),
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 40),

            // 🕰️ Analog Clock
            Center(
              child: SizedBox(
                width: 250,
                height: 250,
                child: AnalogClock(
                  dialColor: null,
                  markingColor: Colors.black,
                  hourNumbers: const [
                    '1',
                    '2',
                    '3',
                    '4',
                    '5',
                    '6',
                    '7',
                    '8',
                    '9',
                    '10',
                    '11',
                    '12'
                  ],
                  hourNumberColor: Colors.blue,
                  dateTime: DateTime.now(),
                ),
              ),
            ),

            const SizedBox(height: 40),

            // 📌 White Box for Inputs
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 5,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                children: [
                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(labelText: "Title"),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(labelText: "Description"),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 10),

                  // 📅 Due Date Picker (Tappable Field)
                  TextField(
                    controller: _dateController,
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: "Due Date",
                      hintText: "Select a date",
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    onTap: () => _pickDueDate(context),
                  ),

                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _addTodo,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF458AE5),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 80, vertical: 14),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            "Add Task",
                            style: TextStyle(color: Colors.white),
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
