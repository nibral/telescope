class CharacterListItem {
  const CharacterListItem(this.id, this.name, this.name_kana, this.card_id_list);

  final int id;
  final String name;
  final String name_kana;
  final List<int> card_id_list;

  static fromJson(json) {
    return new CharacterListItem(
        json['chara_id'], json['kanji_spaced'], json['kana_spaced'], json['cards']);
  }

  toJson() {
    return {
      'chara_id': id,
      'kanji_spaced': name,
      'kana_spaced': name_kana,
      'cards': card_id_list,
    };
  }
}
