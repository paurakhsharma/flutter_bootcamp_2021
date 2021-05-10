import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
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

  final _textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final todoColl = FirebaseFirestore.instance.collection('todos');
    return Scaffold(
        appBar: AppBar(
          title: Text(kIsWeb ? 'Flutter todo web' : 'Flutter todo'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              SizedBox(height: 10),
              SizedBox(
                height: 50,
                child: TextField(
                  controller: _textController,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.all(8),
                    hintText: 'Walk the dog',
                    border: OutlineInputBorder(),
                    suffix: IconButton(
                      icon: Icon(Icons.check),
                      onPressed: () {
                        todoColl.add({'title': text});
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
              ),
              SizedBox(height: 60),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: todoColl.snapshots(),
                  builder: (context, shapshot) {
                    if (!shapshot.hasData) {
                      return Center(child: CircularProgressIndicator());
                    }

                    final documents = shapshot.data.docs;

                    if (documents.isEmpty) {
                      return Text('Noting in todo, please add new todo');
                    }
                    return ListView.separated(
                      itemBuilder: (context, index) {
                        return ListTile(
                          tileColor: Colors.blue,
                          title: Text(
                            documents[index].data()['title'],
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
                                      initialValue:
                                          documents[index].data()['title'],
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
                              todoColl
                                  .doc(documents[index].id)
                                  .update({'title': editedText});
                            },
                          ),
                          trailing: IconButton(
                            icon: Icon(
                              Icons.delete,
                              color: Colors.red,
                            ),
                            onPressed: () {
                              todoColl.doc(documents[index].id).delete();
                            },
                          ),
                        );
                      },
                      itemCount: documents.length,
                      separatorBuilder: (context, index) => SizedBox(height: 2),
                    );
                  },
                ),
              )
            ],
          ),
        ));
  }
}
