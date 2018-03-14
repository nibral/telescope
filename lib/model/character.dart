class Character {
  const Character(this.id, this.name, this.nameKana, this.iconImageUrl);

  final int id;
  final String name;
  final String nameKana;
  final String iconImageUrl;

  static fromJson(json) {
    return new Character(json['id'], json['kanji_spaced'], json['kana_spaced'],
        json['icon_image_ref']);
  }

  toJson() {
    return {
      'id': id,
      'kanji_spaced': name,
      'kana_spaced': nameKana,
      'icon_image_ref': iconImageUrl,
    };
  }
}
