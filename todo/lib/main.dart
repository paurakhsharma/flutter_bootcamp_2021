import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String text = 'Place holder text';
  List<String> todos = [];

  final _textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(kIsWeb ? 'Flutter todo web' : 'Flutter todo'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              SizedBox(height: 10),
              TextField(
                controller: _textController,
                decoration: InputDecoration(
                  hintText: 'Walk the dog',
                  border: OutlineInputBorder(),
                  suffix: IconButton(
                    icon: Icon(Icons.check),
                    onPressed: () {
                      setState(() {
                        todos.add(text);
                      });
                      _textController.clear();
                    },
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    text = value;
                  });
                },
              ),
              SizedBox(height: 60),
              if (todos.isNotEmpty)
                Expanded(
                  child: ListView.separated(
                    itemBuilder: (context, index) {
                      return ListTile(
                        tileColor: Colors.blue,
                        title: Text(
                          todos[index],
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                        leading: IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () async {
                            String editedText;
                            await showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: Text('Edit todo'),
                                  content: TextFormField(
                                    initialValue: todos[index],
                                    onChanged: (value) {
                                      editedText = value;
                                    },
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: Text('Save'),
                                    ),
                                  ],
                                );
                              },
                            );
                            setState(() {
                              todos[index] = editedText;
                            });
                          },
                        ),
                        trailing: IconButton(
                          icon: Icon(
                            Icons.delete,
                            color: Colors.red,
                          ),
                          onPressed: () {
                            setState(() {
                              todos.removeAt(index);
                            });
                          },
                        ),
                      );
                    },
                    itemCount: todos.length,
                    separatorBuilder: (context, index) => SizedBox(height: 2),
                  ),
                )
              else
                Text('Not item in todo')
            ],
          ),
        ));
  }
}
