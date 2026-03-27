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
    final directFix = _replaceKnownBrokenSequences(value);
    if (!_looksMojibake(directFix)) return directFix;
    try {
      final decoded = utf8.decode(latin1.encode(value));
      return _replaceKnownBrokenSequences(decoded);
    } catch (_) {
      return directFix;
    }
  }

  static String _replaceKnownBrokenSequences(String value) {
    const replacements = <String, String>{
      'Ĺ‚': 'ł',
      'Ĺ': 'ł',
      'Ĺ›': 'ś',
      'Ĺ': 'ś',
      'Ĺ„': 'ń',
      'Ĺ': 'ń',
      'Ĺ¼': 'ż',
      'Ĺź': 'ź',
      'Ĺº': 'ź',
      'Ä…': 'ą',
      'Ä‡': 'ć',
      'Ä™': 'ę',
      'Ã³': 'ó',
      'Å‚': 'ł',
      'Åś': 'ś',
      'Å„': 'ń',
      'Å¼': 'ż',
      'Åº': 'ź',
      'Ł›': 'ś',
      'Ł‡': 'ć',
      'Ä‡': 'ć',
    };
    var fixed = value;
    replacements.forEach((broken, correct) {
      fixed = fixed.replaceAll(broken, correct);
    });
    return fixed;
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
