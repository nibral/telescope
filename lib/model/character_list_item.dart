class CharacterListItem {
  const CharacterListItem(this.id, this.name, this.kanaName);

  final int id;
  final String name;
  final String kanaName;

  static fromJson(json) {
    return new CharacterListItem(
        json['chara_id'], json['kanji_spaced'], json['kana_spaced']);
  }
}
