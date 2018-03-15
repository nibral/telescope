class Character {
  const Character(
      this.id, this.name, this.nameKana, this.type, this.iconImageUrl);

  final int id;
  final String name;
  final String nameKana;
  final String type;
  final String iconImageUrl;

  static fromJson(json) {
    return new Character(json['id'], json['kanji_spaced'], json['kana_spaced'],
        json['type'], json['icon_image_ref']);
  }

  toJson() {
    return {
      'id': id,
      'kanji_spaced': name,
      'kana_spaced': nameKana,
      'type': type,
      'icon_image_ref': iconImageUrl,
    };
  }
}
