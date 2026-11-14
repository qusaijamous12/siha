import 'package:get/get.dart';

import '../../auth/controller/auth_controller.dart';
import '../model/home_tab.dart';

class HomeController extends GetxController {
  HomeController(this._auth);

  final AuthController _auth;
  final selected = HomeTab.home.obs;
  late final Worker _session;

  void select(HomeTab tab) => selected.value = tab;

  @override
  void onInit() {
    super.onInit();
    _session = ever(_auth.account, (_) => select(HomeTab.home));
  }

  @override
  void onClose() {
    _session.dispose();
    super.onClose();
  }
}
