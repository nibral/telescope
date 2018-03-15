import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:telescope/infrastructure/cache_manager.dart';
import 'package:telescope/model/character_list_item.dart';
import 'package:telescope/repository/character_repository.dart';
import 'package:telescope/repository/repository_factory.dart';
import 'package:telescope/ui/character_detail_page.dart';
import 'package:telescope/ui/widget/local_cached_network_image.dart';

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
  static final double _iconSize = 128.0;

  List<CharacterListItem> _characterList = [];
  Map<int, Widget> _icons = new Map();

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
              actions: <Widget>[
                new IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _handleRefreshButtonPressed,
                ),
              ],
            )
          : null,
      body: _characterList.isEmpty
          ? new Center(child: const CircularProgressIndicator())
          : new Center(
              child: new GridView.builder(
                shrinkWrap: true,
                gridDelegate: new SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: _iconSize,
                  mainAxisSpacing: 2.0,
                  crossAxisSpacing: 2.0,
                ),
                padding: const EdgeInsets.all(2.0),
                itemBuilder: (BuildContext context, int index) {
                  CharacterListItem character = _characterList[index];
                  return new InkWell(
                    onTap: () {
                      Navigator.of(context).push(new MaterialPageRoute(
                            builder: (_) => new CharacterDetailPage(
                                character.name, character.cardIdList),
                          ));
                    },
                    child: new Stack(
                      children: <Widget>[
                        _icons[character.id],
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
                          width: _iconSize,
                          height: _iconSize / 4,
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

  void _loadCharacterList({bool refresh: false}) async {
    final CharacterRepository repository =
        await new RepositoryFactory().getCharacterRepository();
    final Widget iconPlaceholder = new SizedBox(
      height: _iconSize,
      width: _iconSize,
    );

    repository.getList(refresh: refresh).then((characters) {
      characters.values.forEach((character) {
        setState(() {
          _icons[character.id] = iconPlaceholder;
        });
        repository.find(character.id, refresh: refresh).then((detail) {
          setState(() {
            _icons[character.id] = new LocalCachedNetworkImage(
              detail.iconImageUrl,
              placeholder: iconPlaceholder,
              height: _iconSize,
              width: _iconSize,
              fit: BoxFit.cover,
            );
          });
        });
      });

      setState(() {
        _characterList = characters.values.toList();
        _characterList.sort((a, b) {
          return a.nameKana.compareTo(b.nameKana);
        });
      });
    });
  }

  void _handleRefreshButtonPressed() {
    setState(() {
      _characterList = [];
      _icons = new Map();
    });
    (new CacheManager()).clear();
    _loadCharacterList(refresh: true);
  }
}
