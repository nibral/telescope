class Card {
  const Card(this.id, this.name, this.evolution_id, this.spread_image_ref);

  final int id;
  final String name;
  final int evolution_id;
  final String spread_image_ref;

  static fromJson(json) {
    return new Card(
        json['id'], json['name'], json['evolution_id'], json['spread_image_ref']);
  }
}
