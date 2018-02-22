import 'package:flutter/material.dart';
import 'package:telescope/model/character_list_item.dart';
import 'package:telescope/repository/repository_factory.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(home: new MyHomePage());
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new _MyHomePageState();
  }
}

class _MyHomePageState extends State<MyHomePage> {
  List<CharacterListItem> _characterList = [];

  @override
  void initState() {
    super.initState();

    new RepositoryFactory().getCharacterListRepository().findAll().then((r) {
      setState(() {
        _characterList = r.values.toList();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('telescope'),
      ),
      body: new ListView.builder(

        itemBuilder: (BuildContext context, int index) {
          var character = _characterList[index];
          return new ListTile(
            title: new Text(character.name),
            subtitle: new Text(character.kanaName),
            onTap: () {
              Scaffold.of(context).showSnackBar(
                  new SnackBar(content: new Text(character.name)));
            },
          );
        },
        itemCount: _characterList.length,
      ),
      floatingActionButton: new FloatingActionButton(
        onPressed: _incrementCounter,
        child: new Icon(Icons.add),
      ),
    );
  }

  void _incrementCounter() {
    // nothing to do
  }
}
