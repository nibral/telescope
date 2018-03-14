import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:telescope/model/card.dart' as CharacterCard;
import 'package:telescope/repository/card_repository.dart';
import 'package:telescope/repository/repository_factory.dart';
import 'package:telescope/ui/widget/local_cached_network_image.dart';

class CharacterDetailPage extends StatefulWidget {
  final String name;
  final List<int> cardIdList;

  const CharacterDetailPage(this.name, this.cardIdList);

  @override
  State<StatefulWidget> createState() {
    return new _CharacterDetailPageState();
  }
}

class _CharacterDetailPageState extends State<CharacterDetailPage> {
  bool isLoading = true;
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
              title: new Text(
                widget.name,
                style: new TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              centerTitle: true,
            )
          : null,
      body: isLoading
          ? new Center(
              child: new CircularProgressIndicator(),
            )
          : new CustomScrollView(
              slivers: <Widget>[
                new SliverList(
                    delegate: new SliverChildListDelegate(cardImages)),
                new SliverToBoxAdapter(
                  child: new Container(
                    height: 16.0,
                    color: Colors.transparent,
                  ),
                ),
              ],
            ),
    );
  }

  void _loadCharacterDetail() async {
    CardRepository cardRepository = new RepositoryFactory().getCardRepository();
    List<Widget> images = [];

    await Future.forEach(widget.cardIdList, (id) async {
      CharacterCard.Card card = await cardRepository.find(id);
      if (card.spreadImageUrl != null) {
        images.add(new Container(
          child: new CardSpreadImage(card.name, card.spreadImageUrl),
          padding: const EdgeInsets.only(top: 16.0),
        ));
      }

      if (card.evolutionCardId != 0) {
        CharacterCard.Card evoCard =
            await cardRepository.find(card.evolutionCardId);
        if (evoCard.spreadImageUrl != null) {
          images.add(new Container(
            child: new CardSpreadImage(evoCard.name, evoCard.spreadImageUrl),
            padding: const EdgeInsets.only(top: 16.0),
          ));
        }
      }
    });

    if (images.isEmpty) {
      images.add(new Container(
        child: new Center(
          child: new Text(
            'no card',
            style: new TextStyle(
              color: Colors.grey,
            ),
          ),
        ),
        padding: const EdgeInsets.only(top: 16.0),
      ));
    }

    setState(() {
      cardImages = images;
      isLoading = false;
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
          child: new Text(
            name,
            style: new TextStyle(fontSize: 16.0),
          ),
        ),
        new LocalCachedNetworkImage(
          imageUrl,
          placeholder: new Center(
            child: new AspectRatio(
              aspectRatio: 1.553,
              child: new Container(
                decoration: new BoxDecoration(
                  color: new Color.fromRGBO(238, 238, 238, 1.0),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
