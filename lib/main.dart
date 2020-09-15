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
  Map<String, dynamic> _toDoRemoved;
  int _toDoRemovedPos;

  void initState() {
    super.initState();
    _readData().then((data) {
      try {
        _toDoList = (data != null) ? json.decode(data) : [];
      } catch (e) {
        _toDoList = [];
      }

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

  void _removeDismissible(int index) {
    setState(() {
      _toDoRemoved = Map.from(_toDoList[index]);
      _toDoRemovedPos = index;
      _toDoList.removeAt(index);
    });

    _saveData();
  }

  void _recoverDismissible(int index, BuildContext context) {
    final snackBar = SnackBar(
      content: Text("Tarefa \"${_toDoRemoved["title"]}\" removida!"),
      action: SnackBarAction(label: "Desfazer",
        onPressed: () {
          setState(() {
            _toDoList.insert(_toDoRemovedPos, _toDoRemoved);
            _saveData();
          });

        },
      ),
      duration: Duration(seconds: 2,),
    );
    Scaffold.of(context).removeCurrentSnackBar();
    Scaffold.of(context).showSnackBar(snackBar);
  }

  Future<Null> _refresh() async  {
    await Future.delayed(Duration(seconds: 1));
    setState(() {
      _toDoList.sort((a, b) {
        if (a["done"] && !b["done"]) return 1;
        else if (!a["done"] && b["done"]) return -1;
        else return 0;
      });
    });
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
          child: RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.builder(
                padding: EdgeInsets.only(top: 10.0),
                itemCount: _toDoList.length,
                itemBuilder: _buildItem
            ),
          ),
        )
      ],
    );
  }

  Widget _buildItem(BuildContext context, int index) {
    return Dismissible(
      key: UniqueKey(),
      background: Container(
        color: Colors.red,
        child: Align(
          alignment: Alignment.centerLeft,
          child: Padding(padding: EdgeInsets.only(left: 15.0),
            child: Icon(Icons.delete, color: Colors.white,),
          ),
        ),
      ),
      direction: DismissDirection.startToEnd,
      child: CheckboxListTile(
        title: Text("${_toDoList[index]["title"]}"),
        value: _toDoList[index]["done"],
        secondary: CircleAvatar(
          child: Icon(
              (_toDoList[index]["done"]) ? Icons.check : Icons.error
          ),
        ),
        onChanged: (status) { _changeStatusToDo(index, status); },
      ),
      onDismissed: (direction) {
        _removeDismissible(index);
        _recoverDismissible(index, context);
      },
    );
  }

  Future<File> _getFile() async {
    final directory = await getApplicationDocumentsDirectory();

    final File file = File("${directory.path}/data.json");
    if (!(await file.exists())) {
      await file.create();
    }
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