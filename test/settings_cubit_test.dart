import 'package:c_editor/bloc/settings/settings_cubit.dart';
import 'package:c_editor/utils/document_lang.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('document language helper is a no-op off web', () {
    setDocumentLanguage('zh');
    setDocumentLanguage('ru');
  });

  test('setLocale persists the in-app language', () async {
    SharedPreferences.setMockInitialValues({
      'locale': 'en',
      'theme_mode': 'light',
    });
    final prefs = await SharedPreferences.getInstance();
    final cubit = SettingsCubit(prefs);
    addTearDown(cubit.close);

    cubit.setLocale(const Locale('zh'));
    expect(cubit.state.locale.languageCode, 'zh');
    expect(prefs.getString('locale'), 'zh');

    cubit.setLocale(const Locale('ru'));
    expect(cubit.state.locale.languageCode, 'ru');
    expect(prefs.getString('locale'), 'ru');
  });
}
