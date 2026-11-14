import 'package:get/get.dart';
import 'package:material_ui/material_ui.dart';

import 'core/localization/app_strings.dart';
import 'core/network/demo_gateway.dart';
import 'core/theme/app_theme.dart';
import 'feature/auth/controller/auth_controller.dart';
import 'feature/auth/view/auth_view.dart';
import 'feature/chat/controller/chat_controller.dart';
import 'feature/doctors/controller/doctors_controller.dart';
import 'feature/health/controller/health_controller.dart';
import 'feature/home/controller/home_controller.dart';
import 'feature/home/view/home_view.dart';
import 'feature/profile/controller/profile_controller.dart';
import 'feature/profile/model/app_language.dart';

void main() => runApp(const SahaApp());

class SahaApp extends StatefulWidget {
  const SahaApp({super.key, this.now = DateTime.now});

  final DateTime Function() now;

  @override
  State<SahaApp> createState() => _SahaAppState();
}

class _SahaAppState extends State<SahaApp> {
  late final ProfileController _profile;
  final _theme = AppTheme.light();

  @override
  void initState() {
    super.initState();
    final gateway = DemoGateway(widget.now());
    final auth = Get.put(AuthController(gateway));
    Get.put(HomeController(auth));
    Get.put(HealthController(gateway, auth, widget.now));
    Get.put(DoctorsController(gateway, auth, widget.now));
    Get.put(ChatController(gateway, auth, widget.now));
    _profile = Get.put(ProfileController());
    Get.addTranslations(AppStrings().keys);
    Get.fallbackLocale = AppLanguage.english.locale;
    _profile.selectLanguage(AppLanguage.english);
  }

  @override
  void dispose() {
    Get.delete<ProfileController>();
    Get.delete<ChatController>();
    Get.delete<DoctorsController>();
    Get.delete<HealthController>();
    Get.delete<HomeController>();
    Get.delete<AuthController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Obx(
    () => MaterialApp(
      debugShowCheckedModeBanner: false,
      onGenerateTitle: (_) => 'brand'.tr,
      theme: _theme,
      locale: _profile.language.value.locale,
      supportedLocales: AppStrings.locales,
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      home: const _SessionView(),
    ),
  );
}

class _SessionView extends StatelessWidget {
  const _SessionView();

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();
    return Obx(() {
      final account = auth.account.value;
      return account == null ? const AuthView() : HomeView(account);
    });
  }
}
