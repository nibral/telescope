import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:telescope/model/card.dart' as CharacterCard;
import 'package:telescope/model/character.dart';
import 'package:telescope/repository/card_repository.dart';
import 'package:telescope/repository/character_repository.dart';
import 'package:telescope/repository/repository_factory.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CharacterDetailPage extends StatefulWidget {
  final int id;
  final List<int> cardIdList;

  const CharacterDetailPage(this.id, this.cardIdList);

  @override
  State<StatefulWidget> createState() {
    return new _CharacterDetailPageState();
  }
}

class _CharacterDetailPageState extends State<CharacterDetailPage> {
  bool isLoading = true;
  String characterName = '';
  Widget characterDetail;
  List<Widget> cardImages = [];

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

    return new Scaffold(
      appBar: isPortrait
          ? new AppBar(
              title: new Text(characterName),
              centerTitle: true,
            )
          : null,
      body: isLoading
          ? new Center(
              child: new CircularProgressIndicator(),
            )
          : new CustomScrollView(
              slivers: <Widget>[
                new SliverToBoxAdapter(
                  child: characterDetail,
                ),
                new SliverList(
                  delegate: new SliverChildListDelegate(cardImages),
                ),
                new SliverToBoxAdapter(
                  child: new Container(
                    height: 32.0,
                    color: Colors.transparent,
                  ),
                ),
              ],
            ),
    );
  }

  void _loadCharacterDetail() async {
    CharacterRepository characterRepository =
        await new RepositoryFactory().getCharacterRepository();

    Character character = await characterRepository.find(widget.id);
    characterName = character.name;
    characterDetail = new Column(
      children: <Widget>[
        new CachedNetworkImage(imageUrl: character.iconImageUrl),
        new Text(character.name),
        new Text(character.nameKana),
      ],
    );

    setState(() {
      isLoading = false;
      cardImages = [
        new Center(
          child: new CircularProgressIndicator(),
        )
      ];
    });

    CardRepository cardRepository = new RepositoryFactory().getCardRepository();
    List<Widget> images = [];

    await Future.forEach(widget.cardIdList, (id) async {
      CharacterCard.Card card = await cardRepository.find(id);
      if (card.spreadImageUrl != null) {
        images.add(new CardSpreadImage(card.name, card.spreadImageUrl));
      }

      if (card.evolutionCardId != 0) {
        CharacterCard.Card evoCard =
            await cardRepository.find(card.evolutionCardId);
        if (evoCard.spreadImageUrl != null) {
          images.add(new CardSpreadImage(evoCard.name, evoCard.spreadImageUrl));
        }
      }
    });

    setState(() {
      cardImages = images;
    });
  }
}

class CardSpreadImage extends StatelessWidget {
  final String name;
  final String imageUrl;

  CardSpreadImage(this.name, this.imageUrl);

  @override
  Widget build(BuildContext context) {
    return new Column(
      children: <Widget>[
        new Container(
          height: 32.0,
          child: new Center(
            child: new Text(name),
          ),
        ),
        new CachedNetworkImage(
          imageUrl: imageUrl,
          placeholder: new CircularProgressIndicator(),
        )
      ],
    );
  }
}
