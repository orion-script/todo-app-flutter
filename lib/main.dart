import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter To-Do App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const TodoScreen(),
    );
  }
}

class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});

  @override
  _TodoScreenState createState() => _TodoScreenState();

//  In the above code, we have created a simple To-Do app with the following features:

//  Add a task
//  Remove a task

//  The app has a  TextField  to enter the task and an  IconButton  to add the task. The tasks are displayed in a  ListView  with a delete button to remove the task.
//  The  TodoScreen  class is a  StatefulWidget  that has a list of tasks and a  TextEditingController  to get the task from the  TextField .
//  The  _addTask  method is used to add the task to the list of tasks.
//  The  _removeTask  method is used to remove the task from the list of tasks.
//  The  build  method returns a  Scaffold  with an  AppBar  and a  Column  widget. The  Column  widget has a  TextField  and an  IconButton  to add the task. The tasks are displayed in a  ListView  with a delete button to remove the task.
//  Conclusion
//  In this article, we learned how to create a simple To-Do app in Flutter. We created a simple To-Do app with the following features:

//  Add a task
//  Remove a task

//  The app has a  TextField  to enter the task and an  IconButton  to add the task. The tasks are displayed in a  ListView  with a delete button to remove the task.
//  I hope this article was helpful to you.
//  #flutter #dart #mobile-apps
//  What is GEEK
//  Buddha Community
//  Google's Flutter 1.20 stable announced with new features - Navoki
//  Flutter Google cross-platform UI framework has released a new version 1.20 stable.
//  Flutter is Google’s UI framework to make apps for Android, iOS, Web, Windows, Mac, Linux, and Fuchsia OS. Since the last 2 years, the flutter Framework has already achieved popularity among mobile developers to develop Android and iOS apps. In the last few releases, Flutter also added the support of making web applications and commercial desktop applications.
//  Last month they introduced the support of the Linux desktop app that can be distributed through Canonical Snap Store(Snapcraft), this enables the developers to publish there Linux desktop app for their users and publish on Snap Store.  If you want to learn how to  Publish Flutter Desktop app in Snap Store that here is the tutorial.
//  Flutter 1.20 Framework is built on Google’s made Dart programming language that is
// a cross-platform language providing native performance, new UI widgets, and other more features for the developer usage.
}

class _TodoScreenState extends State<TodoScreen> {
  final List<String> _tasks = [];
  final TextEditingController _controller = TextEditingController();

  void _addTask() {
    if (_controller.text.isNotEmpty) {
      setState(() {
        _tasks.add(_controller.text);
        debugPrint("Task added: ${_controller.text}");
        debugPrint("Current tasks: $_tasks");
        _controller.clear();
      });
    } else {
      debugPrint("Enter your task");
    }
  }

  void _removeTask(int index) {
    setState(() {
      debugPrint("Task removed: ${_tasks[index]}");
      _tasks.removeAt(index);
      debugPrint("Updated tasks: $_tasks");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('To-Do List')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(hintText: 'Enter task'),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _addTask,
                )
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _tasks.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_tasks[index]),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _removeTask(index),
                  ),
                );
              },
            ),
          ),
          // Expanded(
          //     child: Container(
          //   color: Colors.red,
          // ))
        ],
      ),
    );
  }
}
