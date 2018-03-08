class Character {
  const Character(this.id, this.name, this.nameKana, this.iconImageUrl);

  final int id;
  final String name;
  final String nameKana;
  final String iconImageUrl;

  static fromJson(json) {
    return new Character(
        json['id'], json['name'], json['name_kana'], json['icon_image_ref']);
  }
}
