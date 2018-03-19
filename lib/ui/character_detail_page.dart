import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:telescope/model/card.dart' as CharacterCard;
import 'package:telescope/model/character.dart';
import 'package:telescope/repository/card_repository.dart';
import 'package:telescope/repository/character_repository.dart';
import 'package:telescope/repository/repository_factory.dart';
import 'package:telescope/ui/widget/local_cached_network_image.dart';

class CharacterDetailPage extends StatefulWidget {
  final int id;
  final String name;
  final List<int> cardIdList;

  const CharacterDetailPage(this.id, this.name, this.cardIdList);

  @override
  State<StatefulWidget> createState() {
    return new _CharacterDetailPageState();
  }
}

class _CharacterDetailPageState extends State<CharacterDetailPage> {
  bool _isLoading = true;
  Color _typeColor = Colors.grey;
  List<CharacterCard.Card> _cards = [];

  @override
  void initState() {
    super.initState();

    _loadCharacterDetail();
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

    Widget body;
    if (!_isLoading) {
      if (_cards.isEmpty) {
        body = new Container(
          child: new Center(
            child: new Text(
              'no card',
              style: new TextStyle(
                color: Colors.grey,
              ),
            ),
          ),
          padding: const EdgeInsets.only(top: 16.0),
        );
      } else {
        body = new CustomScrollView(
          slivers: <Widget>[
            new SliverList(
                delegate: new SliverChildBuilderDelegate(
              (_, index) {
                var card = _cards[index];
                return new Container(
                  child: new CardSpreadImage(card.name, card.spreadImageUrl),
                  padding: const EdgeInsets.only(top: 16.0),
                );
              },
              childCount: _cards.length,
            )),
            new SliverToBoxAdapter(
              child: new Container(
                height: 16.0,
                color: Colors.transparent,
              ),
            ),
          ],
        );
      }
    } else {
      body = new Center(
          child: new CircularProgressIndicator(
        valueColor: new AlwaysStoppedAnimation<Color>(_typeColor),
      ));
    }

    return new Scaffold(
      appBar: isPortrait
          ? new AppBar(
              title: new Text(
                widget.name,
                style: new TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              centerTitle: true,
              backgroundColor: _typeColor,
            )
          : null,
      body: body,
    );
  }

  void _loadCharacterDetail() async {
    await (await new RepositoryFactory().getCharacterRepository())
        .find(widget.id)
        .then((character) {
      setState(() {
        switch (character.type) {
          case 'cute':
            _typeColor = Colors.pink;
            break;
          case 'cool':
            _typeColor = Colors.blue;
            break;
          case 'passion':
            _typeColor = Colors.amber;
            break;
          default:
            _typeColor = Colors.black;
        }
      });
    });

    final CardRepository cardRepository =
        await new RepositoryFactory().getCardRepository();
    List<CharacterCard.Card> cards = [];

    cards.addAll(
        await Future.wait<CharacterCard.Card>(widget.cardIdList.map((id) {
      return cardRepository.find(id);
    })));
    cards.addAll(await Future.wait<CharacterCard.Card>(cards.where((card) {
      return card.evolutionCardId != 0;
    }).map((card) {
      return cardRepository.find(card.evolutionCardId);
    })));

    cards.sort((a, b) {
      if (a.id == b.id) {
        return 0;
      }
      return (a.id < b.id) ? -1 : 1;
    });

    setState(() {
      _cards = cards.where((card) {
        return card.spreadImageUrl != null;
      }).toList();
      _isLoading = false;
    });
  }
}

class CardSpreadImage extends StatelessWidget {
  final String name;
  final String imageUrl;

  // 1280x824 = 1.553:1
  final Widget _placeholder = new Center(
    child: new AspectRatio(
      aspectRatio: 1.553,
      child: new Container(
        decoration: new BoxDecoration(
          color: new Color.fromRGBO(238, 238, 238, 1.0),
        ),
      ),
    ),
  );

  CardSpreadImage(this.name, this.imageUrl);

  @override
  Widget build(BuildContext context) {
    return new Column(
      children: <Widget>[
        new Container(
          child: new Text(
            name,
            style: new TextStyle(fontSize: 16.0),
          ),
        ),
        new LocalCachedNetworkImage(
          imageUrl,
          placeholder: _placeholder,
        ),
      ],
    );
  }
}
