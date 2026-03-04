class WordPair {
  WordPair({required this.en, required this.pl});

  final String en;
  final String pl;

  factory WordPair.fromJson(Map<String, dynamic> json) =>
      WordPair(en: json['en'] as String, pl: json['pl'] as String);
}
