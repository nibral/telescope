class Character {
  const Character(this.id, this.name, this.name_kana, this.icon_image_ref);

  final int id;
  final String name;
  final String name_kana;
  final String icon_image_ref;

  static fromJson(json) {
    return new Character(
        json['id'], json['name'], json['name_kana'], json['icon_image_ref']);
  }
}
