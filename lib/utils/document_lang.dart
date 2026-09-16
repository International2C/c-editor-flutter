import 'document_lang_stub.dart'
    if (dart.library.js_interop) 'document_lang_web.dart' as impl;

/// Sets `<html lang>` to match the in-app locale. No-op off web.
void setDocumentLanguage(String languageCode) =>
    impl.setDocumentLanguage(languageCode);
