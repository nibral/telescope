class CharacterListItem {
  const CharacterListItem(this.id, this.name, this.nameKana, this.cardIdList);

  final int id;
  final String name;
  final String nameKana;
  final List<int> cardIdList;

  static fromJson(json) {
    return new CharacterListItem(
        json['chara_id'], json['kanji_spaced'], json['kana_spaced'], json['cards']);
  }

  toJson() {
    return {
      'chara_id': id,
      'kanji_spaced': name,
      'kana_spaced': nameKana,
      'cards': cardIdList,
    };
  }
}
