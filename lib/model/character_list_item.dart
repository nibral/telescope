class CharacterListItem {
  const CharacterListItem(this.id, this.name, this.name_kana);

  final int id;
  final String name;
  final String name_kana;

  static fromJson(json) {
    return new CharacterListItem(
        json['chara_id'], json['kanji_spaced'], json['kana_spaced']);
  }
}
