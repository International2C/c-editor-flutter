import 'package:web/web.dart' as web;

void setDocumentLanguage(String languageCode) {
  final lang = languageCode.trim();
  if (lang.isEmpty) return;
  web.document.documentElement?.setAttribute('lang', lang);
}
