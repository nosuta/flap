String detectLanguage({required String string}) {
  String lang = 'en';

  // final RegExp english = RegExp(r'^[a-zA-Z]+');
  final RegExp persian = RegExp(r'^[\u0600-\u06FF]+');
  final RegExp arabic = RegExp(r'^[\u0621-\u064A]+');
  final RegExp chinese = RegExp(r'^[\u4E00-\u9FFF]+');
  final RegExp japanese = RegExp(r'^[\u3040-\u30FF]+');
  final RegExp korean = RegExp(r'^[\uAC00-\uD7AF]+');
  final RegExp ukrainian = RegExp(r'^[\u0400-\u04FF\u0500-\u052F]+');
  final RegExp russian = RegExp(r'^[\u0400-\u04FF]+');
  final RegExp italian = RegExp(r'^[\u00C0-\u017F]+');
  final RegExp french = RegExp(r'^[\u00C0-\u017F]+');
  final RegExp spanish = RegExp(
      r'[\u00C0-\u024F\u1E00-\u1EFF\u2C60-\u2C7F\uA720-\uA7FF\u1D00-\u1D7F]+');

  // if (english.hasMatch(string)) lang = 'en';
  if (persian.hasMatch(string)) lang = 'fa';
  if (arabic.hasMatch(string)) lang = 'ar';
  if (chinese.hasMatch(string)) lang = 'zh';
  if (japanese.hasMatch(string)) lang = 'ja';
  if (korean.hasMatch(string)) lang = 'ko';
  if (russian.hasMatch(string)) lang = 'ru';
  if (ukrainian.hasMatch(string)) lang = 'uk';
  if (italian.hasMatch(string)) lang = 'it';
  if (french.hasMatch(string)) lang = 'fr';
  if (spanish.hasMatch(string)) lang = 'es';

  return lang;
}
