import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:telescope/infrastructure/application_documents_impl.dart';
import 'package:telescope/model/character_list_item.dart';
import 'package:telescope/repository/character_repository.dart';
import 'package:telescope/repository/repository_factory.dart';
import 'package:telescope/ui/character_detail_page.dart';
import 'package:telescope/ui/widget/local_cached_network_image.dart';
import 'package:flutter_search_bar/flutter_search_bar.dart';

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

  SearchBar _searchBar;
  String _searchQuery = '';
  bool _isShowSearchBar = false;

  List<CharacterListItem> _characterList = [];
  Map<int, Widget> _icons = new Map();

  _MyHomePageState() {
    _searchBar = new SearchBar(
      inBar: true,
      setState: (fn) {
        _searchBar.controller.clear();
        _searchQuery = '';
        _isShowSearchBar = !_searchBar.isSearching;
        setState(fn);
      },
      onSubmitted: (query) {
        setState(() {
          _searchQuery = query;
        });
      },
      showClearButton: false,
      clearOnSubmit: false,
      closeOnSubmit: false,
      buildDefaultAppBar: (BuildContext context) {
        return new AppBar(
          title: new Text('telescope'),
          backgroundColor: Colors.black,
          centerTitle: true,
          elevation: 4.0,
          actions: <Widget>[
            _searchBar.getSearchAction(context),
            new IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _handleRefreshButtonPressed,
            ),
          ],
        );
      },
    );
    _searchBar.controller?.addListener(_handleSearchQueryChanged);
  }

  @override
  void initState() {
    super.initState();

    _loadCharacterList();
  }

  @override
  void dispose() {
    _searchBar.controller?.removeListener(_handleSearchQueryChanged);
    super.dispose();
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

    if (_isShowSearchBar) {
      return new Scaffold(
        appBar: _searchBar.build(context),
        body: _searchQuery.isEmpty
            ? new Center()
            : new ListView(
                children: _characterList.where((c) {
                  return c.name.contains(_searchQuery) ||
                      c.nameKana.contains(_searchQuery);
                }).map((e) {
                  return new InkWell(
                    onTap: () => _showCharacterDetail(context, e),
                    child: new ListTile(
                      key: new Key(e.id.toString()),
                      title: new Text(e.name),
                      subtitle: new Text(e.nameKana),
                      trailing: new SizedBox(
                        child: _icons[e.id],
                        height: 48.0,
                        width: 48.0,
                      ),
                    ),
                  );
                }).toList(),
              ),
      );
    }

    return new Scaffold(
      appBar: isPortrait ? _searchBar.build(context) : null,
      body: _characterList.isEmpty
          ? new Center(
              child: new CircularProgressIndicator(
              valueColor: new AlwaysStoppedAnimation<Color>(Colors.grey),
            ))
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
                    onTap: () => _showCharacterDetail(context, character),
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

  void _loadCharacterList() async {
    final CharacterRepository repository =
        await new RepositoryFactory().getCharacterRepository();
    final Widget iconPlaceholder = new SizedBox(
      height: _iconSize,
      width: _iconSize,
    );

    repository.getList().then((characters) {
      characters.values.forEach((character) {
        setState(() {
          _icons[character.id] = iconPlaceholder;
        });
        repository.find(character.id).then((detail) {
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

  void _showCharacterDetail(BuildContext context, CharacterListItem character) {
    Navigator.of(context).push(new MaterialPageRoute(
          builder: (_) => new CharacterDetailPage(
              character.id, character.name, character.cardIdList),
        ));
  }

  void _handleRefreshButtonPressed() async {
    setState(() {
      _characterList = [];
      _icons = new Map();
    });
    new RepositoryFactory().invalidateCache();
    _loadCharacterList();
  }

  void _handleSearchQueryChanged() {
    setState(() {
      _searchQuery = _searchBar.controller.value.text;
    });
  }
}
