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
  Map<int, Widget> _icons = new Map();

  @override
  void initState() {
    super.initState();

    new RepositoryFactory().getCharacterListRepository().findAll().then((r) {
      setState(() {
        r.values.forEach((c) {
          _icons[c.id] = new Icon(Icons.account_circle);
        });
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
          _loadIcon(character.id);
          return new ListTile(
            leading: _icons[character.id],
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
    );
  }

  void _loadIcon(id) {
    new RepositoryFactory().getCharacterRepository().find(id).then((c) {
      setState(() {
        _icons[id] = new Image.network(c.icon_image_ref);
      });
    });
  }
}
