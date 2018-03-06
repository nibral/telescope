import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:telescope/model/character_list_item.dart';
import 'package:telescope/repository/character_repository.dart';
import 'package:telescope/repository/repository_factory.dart';
import 'package:telescope/ui/character_detail_page.dart';
import 'package:cached_network_image/cached_network_image.dart';

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

    _loadCharacterList();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('telescope'),
      ),
      body: new Center(
        child: new GridView.builder(
          shrinkWrap: true,
          gridDelegate: new SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 128.0,
            mainAxisSpacing: 4.0,
            crossAxisSpacing: 4.0,
          ),
          padding: const EdgeInsets.all(4.0),
          itemBuilder: (BuildContext context, int index) {
            CharacterListItem character = _characterList[index];
            return new InkWell(
              onTap: () {
                Navigator.of(context).push(new MaterialPageRoute(
                      builder: (_) => new CharacterDetailPage(character.id),
                    ));
              },
              child: new Stack(
                children: <Widget>[
                  _icons[character.id],
                  new Positioned(
                    child: new Container(
                      child: new Text(
                        character.name,
                        style: new TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      decoration: new BoxDecoration(
                        color: const Color.fromRGBO(0, 0, 0, 0.5),
                      ),
                      padding: const EdgeInsets.only(left: 4.0),
                    ),
                    width: 128.0,
                    height: 32.0,
                    left: 0.0,
                    bottom: 0.0,
                  ),
                ],
              ),
            );
          },
          itemCount: _characterList.length,
        ),
      ),
    );
  }

  void _loadCharacterList() async {
    CharacterRepository repository =
        await new RepositoryFactory().getCharacterRepository();
    Widget iconPlaceholder = const SizedBox(
      height: 128.0,
      width: 128.0,
    );

    repository.getList().then((characters) {
      characters.values.forEach((character) {
        setState(() {
          _icons[character.id] = iconPlaceholder;
        });
        repository.find(character.id).then((detail) {
          setState(() {
            _icons[character.id] = new CachedNetworkImage(
              imageUrl: detail.icon_image_ref,
              placeholder: iconPlaceholder,
            );
          });
        });
      });

      setState(() {
        _characterList = characters.values.toList();
        _characterList.sort((a, b) {
          return a.name_kana.compareTo(b.name_kana);
        });
      });
    });
  }
}
