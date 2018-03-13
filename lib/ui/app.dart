import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:telescope/model/character_list_item.dart';
import 'package:telescope/repository/character_repository.dart';
import 'package:telescope/repository/repository_factory.dart';
import 'package:telescope/ui/character_detail_page.dart';

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
  static final double iconSize = 128.0;

  List<CharacterListItem> characterList = [];
  Map<int, Widget> icons = new Map();

  @override
  void initState() {
    super.initState();

    _loadCharacterList();
  }

  @override
  Widget build(BuildContext context) {
    final Orientation orientation = MediaQuery.of(context).orientation;
    final bool isPortrait = orientation == Orientation.portrait;
    if (isPortrait) {
      SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    } else {
      SystemChrome.setEnabledSystemUIOverlays([]);
    }

    return new Scaffold(
      appBar: isPortrait
          ? new AppBar(
              title: new Text('telescope'),
              centerTitle: true,
            )
          : null,
      body: new Center(
        child: new GridView.builder(
          shrinkWrap: true,
          gridDelegate: new SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: iconSize,
            mainAxisSpacing: 2.0,
            crossAxisSpacing: 2.0,
          ),
          padding: const EdgeInsets.all(2.0),
          itemBuilder: (BuildContext context, int index) {
            CharacterListItem character = characterList[index];
            return new InkWell(
              onTap: () {
                Navigator.of(context).push(new MaterialPageRoute(
                      builder: (_) => new CharacterDetailPage(
                          character.name, character.cardIdList),
                    ));
              },
              child: new Stack(
                children: <Widget>[
                  icons[character.id],
                  new Positioned(
                    child: new Container(
                      child: new Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          new Flexible(
                            child: new Text(
                              character.name,
                              style: const TextStyle(color: Colors.white),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      decoration: const BoxDecoration(
                        color: const Color.fromRGBO(0, 0, 0, 0.5),
                      ),
                      padding: const EdgeInsets.only(left: 4.0),
                    ),
                    width: iconSize,
                    height: iconSize / 4,
                    left: 0.0,
                    bottom: 0.0,
                  ),
                ],
              ),
            );
          },
          itemCount: characterList.length,
        ),
      ),
    );
  }

  void _loadCharacterList() async {
    CharacterRepository repository =
        await new RepositoryFactory().getCharacterRepository();
    Widget iconPlaceholder = new SizedBox(
      height: iconSize,
      width: iconSize,
    );

    repository.getList().then((characters) {
      characters.values.forEach((character) {
        setState(() {
          icons[character.id] = iconPlaceholder;
        });
        repository.find(character.id).then((detail) {
          setState(() {
            icons[character.id] = new Image.network(
              detail.iconImageUrl,
              height: iconSize,
              width: iconSize,
              fit: BoxFit.cover,
            );
          });
        });
      });

      setState(() {
        characterList = characters.values.toList();
        characterList.sort((a, b) {
          return a.nameKana.compareTo(b.nameKana);
        });
      });
    });
  }
}
