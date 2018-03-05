import 'package:flutter/material.dart';
import 'package:telescope/repository/character_repository.dart';
import 'package:telescope/repository/repository_factory.dart';

class CharacterDetailPage extends StatefulWidget {
  final int id;

  const CharacterDetailPage(this.id);

  @override
  State<StatefulWidget> createState() {
    return new _CharacterDetailPageState();
  }
}

class _CharacterDetailPageState extends State<CharacterDetailPage> {
  Widget characterDetail = new Text('loading...');

  @override
  void initState() {
    super.initState();

    _loadCharacterDetail();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('detail'),
      ),
      body: characterDetail,
    );
  }

  void _loadCharacterDetail() async {
    CharacterRepository repository =
        await new RepositoryFactory().getCharacterRepository();
    repository.find(widget.id).then((r) {
      setState(() {
        characterDetail = new Column(
          children: <Widget>[
            new Image.network(r.icon_image_ref),
            new Text(r.name),
            new Text(r.name_kana)
          ],
        );
      });
    });
  }
}
