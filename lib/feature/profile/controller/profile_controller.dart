import 'package:get/get.dart';

import '../model/app_language.dart';

class ProfileController extends GetxController {
  final language = AppLanguage.english.obs;

  void selectLanguage(AppLanguage value) {
    Get.locale = value.locale;
    language.value = value;
  }

  void toggleLanguage() => selectLanguage(
    language.value == AppLanguage.english
        ? AppLanguage.arabic
        : AppLanguage.english,
  );
}
