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
  final int _id;
  final List<int> _card_id_list;

  const CharacterDetailPage(this._id, this._card_id_list);

  @override
  State<StatefulWidget> createState() {
    return new _CharacterDetailPageState();
  }
}

class _CharacterDetailPageState extends State<CharacterDetailPage> {
  bool _isLoading = true;
  Widget _characterDetail;
  List<Widget> _cardImages = [];

  @override
  void initState() {
    super.initState();

    _loadCharacterDetail();
  }

  @override
  Widget build(BuildContext context) {
    final Orientation orientation = MediaQuery.of(context).orientation;
    if (orientation == Orientation.portrait) {
      SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);
    } else {
      SystemChrome.setEnabledSystemUIOverlays([]);
    }

    return new Scaffold(
      body: _isLoading
          ? new Center(
              child: new CircularProgressIndicator(),
            )
          : new CustomScrollView(
              slivers: <Widget>[
                new SliverToBoxAdapter(
                  child: _characterDetail,
                ),
                new SliverList(
                  delegate: new SliverChildListDelegate(_cardImages),
                ),
                new SliverToBoxAdapter(
                  child: new Container(
                    height: 32.0,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
    );
  }

  void _loadCharacterDetail() async {
    CharacterRepository characterRepository =
        await new RepositoryFactory().getCharacterRepository();

    Character character = await characterRepository.find(widget._id);
    _characterDetail = new Column(
      children: <Widget>[
        new CachedNetworkImage(imageUrl: character.icon_image_ref),
        new Text(character.name),
        new Text(character.name_kana),
      ],
    );

    setState(() {
      _isLoading = false;
    });

    CardRepository cardRepository = new RepositoryFactory().getCardRepository();
    List<Widget> images = [];

    await Future.forEach(widget._card_id_list, (id) async {
      CharacterCard.Card card = await cardRepository.find(id);
      if (card.spread_image_ref != null) {
        images.add(new CardSpreadImage(card.name, card.spread_image_ref));
      }

      if (card.evolution_id != 0) {
        CharacterCard.Card evo_card =
            await cardRepository.find(card.evolution_id);
        if (evo_card.spread_image_ref != null) {
          images.add(
              new CardSpreadImage(evo_card.name, evo_card.spread_image_ref));
        }
      }
    });

    setState(() {
      _cardImages = images;
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
