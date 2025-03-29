import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/todo_service.dart';

class AllTasksScreen extends StatefulWidget {
  const AllTasksScreen({super.key});

  @override
  State<AllTasksScreen> createState() => _AllTasksScreenState();
}

class _AllTasksScreenState extends State<AllTasksScreen> {
  List<Map<String, dynamic>>? todos;
  bool isLoading = true;

  // Tracks loading states for each todo
  Set<String> loadingTodos = {};

  @override
  void initState() {
    super.initState();
    _fetchTodos();
  }

  Future<void> _fetchTodos() async {
    setState(() => isLoading = true);
    List<Map<String, dynamic>>? fetchedTodos = await TodoService.getTodos();
    setState(() {
      todos = fetchedTodos;
      isLoading = false;
    });
  }

  // ✅ Mark Todo as Completed with Loading State
  Future<void> _markAsCompleted(String id) async {
    setState(() => loadingTodos.add(id));

    bool success = await TodoService.markTodoCompleted(id);

    setState(() => loadingTodos.remove(id));

    if (!mounted) return;
    if (success) {
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Todo marked as completed")),
      );
      _fetchTodos();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to mark as completed")),
      );
    }
  }

  // ❌ Delete Todo with Loading State
  Future<void> _deleteTodo(String id) async {
    setState(() => loadingTodos.add(id));

    bool success = await TodoService.deleteTodo(id);

    setState(() => loadingTodos.remove(id));
    if (!mounted) return;
    if (success) {
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Todo deleted successfully")),
      );
      _fetchTodos();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to delete todo")),
      );
    }
  }

  // Calculate remaining days for due date
  String getRemainingDays(String dueDate) {
    try {
      DateTime due = DateTime.parse(dueDate);
      DateTime today = DateTime.now();
      int daysLeft = due.difference(today).inDays;

      if (daysLeft == 0) return "Due Today";
      if (daysLeft == 1) return "1 day left";
      if (daysLeft == -1) return "Due Yesterday";
      if (daysLeft < -1) return "Due ${-daysLeft} days ago";
      return "$daysLeft days left";
    } catch (e) {
      return "Invalid date";
    }
  }

  // ✅ Bottom Sheet with Loading Indicators
  void _showTodoDetails(Map<String, dynamic> todo) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                controller: scrollController,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(todo['title'],
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(
                        "Description: ${todo['description'] ?? 'No description'}"),
                    const SizedBox(height: 8),
                    Text(
                        "Due Date: ${DateFormat('yyyy-MM-dd').format(DateTime.parse(todo['dueDate']))}"),
                    const SizedBox(height: 8),
                    Text("Status: ${todo['status']}"),
                    const SizedBox(height: 16),

                    // ✅ Mark as Completed Button with Loading Indicator
                    if (todo['status'] == 'pending') ...[
                      ElevatedButton(
                        onPressed: loadingTodos.contains(todo['_id'])
                            ? null
                            : () => _markAsCompleted(todo['_id']),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                        child: loadingTodos.contains(todo['_id'])
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              )
                            : const Text("Mark as Completed"),
                      ),
                      const SizedBox(height: 8),
                    ],

                    // ❌ Delete Button with Loading Indicator
                    ElevatedButton(
                      onPressed: loadingTodos.contains(todo['_id'])
                          ? null
                          : () => _deleteTodo(todo['_id']),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      child: loadingTodos.contains(todo['_id'])
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text("Delete Todo"),
                    ),

                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Close"),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        title: const Text('All Todos'),
        automaticallyImplyLeading: false,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : todos == null || todos!.isEmpty
              ? const Center(child: Text("No tasks available"))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: todos!.length,
                  itemBuilder: (context, index) {
                    final todo = todos![index];
                    return Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 3,
                      child: ListTile(
                        title: Text(todo['title'],
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(
                          todo['dueDate'] != null
                              ? getRemainingDays(todo['dueDate'])
                              : "No due date",
                        ),
                        contentPadding: const EdgeInsets.all(16),
                        trailing: Text(todo['status'],
                            style: TextStyle(
                                color: todo['status'] == 'pending'
                                    ? Colors.red
                                    : Colors.green)),
                        onTap: () => _showTodoDetails(todo),
                      ),
                    );
                  },
                ),
    ));
  }
}
