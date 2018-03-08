class Card {
  const Card(this.id, this.name, this.evolutionCardId, this.spreadImageUrl);

  final int id;
  final String name;
  final int evolutionCardId;
  final String spreadImageUrl;

  static fromJson(json) {
    return new Card(
        json['id'], json['name'], json['evolution_id'], json['spread_image_ref']);
  }
}
