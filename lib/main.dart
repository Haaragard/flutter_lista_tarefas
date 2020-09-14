import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

void main() { runApp(MyApp()); }

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Lista de tarefas",
      home: Home(),
    );
  }
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final TextEditingController _newTaskController = TextEditingController();
  bool _addEnabled = false;

  List _toDoList = [];

  void initState() {
    super.initState();
    _readData().then((data) {
      _toDoList = (data != null) ? json.decode(data) : [];
      _addEnabled = true;
    });
  }

  void _addToDo() {
    if (_addEnabled) {
      Map<String, dynamic> newToDo = Map();
      newToDo["title"] = _newTaskController.text;
      _newTaskController.text = "";
      newToDo["done"] = false;

      setState(() {
        _toDoList.add(newToDo);
      });

      _saveData();
    }
  }

  void _changeStatusToDo(int index, bool status) {
    setState(() {
      _toDoList[index]["done"] = status;
    });

    _saveData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Lista de tarefas"), centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return Column(
      children: <Widget>[
        Container(
          padding: EdgeInsets.fromLTRB(17.0, 1.0, 7.0, 1.0),
          child: Row(
            children: <Widget>[
              Expanded(
                child: TextField(
                  enabled: _addEnabled,
                  controller: _newTaskController,
                  decoration: InputDecoration(
                    labelText: "Nova Tarefa",
                    labelStyle: TextStyle(color: Colors.blueAccent),
                  ),
                ),
              ),
              RaisedButton(
                color: Colors.blueAccent,
                child: Text("ADD"),
                textColor: Colors.white,
                onPressed: _addToDo,
              ),
            ],
          ),
        ),

        Expanded(
          child: ListView.builder(
              padding: EdgeInsets.only(top: 10.0),
              itemCount: _toDoList.length,
              itemBuilder: (context, index) {
                return CheckboxListTile(
                  title: Text("${_toDoList[index]["title"]}"),
                  value: _toDoList[index]["done"],
                  secondary: CircleAvatar(
                    child: Icon(
                        (_toDoList[index]["done"]) ? Icons.check : Icons.error
                    ),
                  ),
                  onChanged: (status) {
                    _changeStatusToDo(index, status);
                  },
                );
              }
          ),
        )
      ],
    );
  }

  Future<File> _getFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File("${directory.path}/data.json");
  }

  Future<File> _saveData() async {
    String data = json.encode(_toDoList);
    final file = await _getFile();

    return file.writeAsString(data);
  }

  Future<String> _readData() async {
    try{
      final file = await _getFile();

      return file.readAsString();
    } catch (e) {
      return null;
    }
  }
}