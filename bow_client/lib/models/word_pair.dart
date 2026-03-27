import 'dart:convert';

class WordPair {
  WordPair({required this.en, required this.pl});

  final String en;
  final String pl;

  factory WordPair.fromJson(Map<String, dynamic> json) => WordPair(
        en: _repairMojibake(json['en'] as String),
        pl: _repairMojibake(json['pl'] as String),
      );

  static String _repairMojibake(String value) {
    if (!_looksMojibake(value)) return value;
    try {
      return utf8.decode(latin1.encode(value));
    } catch (_) {
      return value;
    }
  }

  static bool _looksMojibake(String value) {
    // Typical mojibake markers for UTF-8 read as Latin-1/Windows-1252.
    return value.contains('Ã') ||
        value.contains('Å') ||
        value.contains('Ä') ||
        value.contains('Ĺ') ||
        value.contains('Ă');
  }
}
