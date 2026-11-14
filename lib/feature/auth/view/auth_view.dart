import 'package:material_ui/material_ui.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/care_widgets.dart';
import '../../profile/controller/profile_controller.dart';
import '../controller/auth_controller.dart';

class AuthView extends StatefulWidget {
  const AuthView({super.key});

  @override
  State<AuthView> createState() => _AuthViewState();
}

class _AuthViewState extends State<AuthView> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _hidePassword = true;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    return Scaffold(
      body: SafeArea(
        child: Obx(() {
          final signingUp = auth.registering.value;
          final error = auth.error.value;
          return CareList(
            children: [
              Row(
                children: [
                  const CareIcon(
                    Icons.favorite_rounded,
                    background: AppColors.forest,
                    color: AppColors.lime,
                    size: 42,
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      'brand'.tr,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: Get.find<ProfileController>().toggleLanguage,
                    icon: const Icon(Icons.language_rounded, size: 18),
                    label: Text(isArabic ? 'english'.tr : 'arabic'.tr),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const _WelcomeCard(),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _ModeButton(
                      'sign_in'.tr,
                      !signingUp,
                      auth.switchMode,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _ModeButton(
                      'sign_up'.tr,
                      signingUp,
                      auth.switchMode,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              AutofillGroup(
                child: Form(
                  key: _form,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (signingUp) ...[
                        TextFormField(
                          controller: _name,
                          autofillHints: const [AutofillHints.name],
                          textCapitalization: TextCapitalization.words,
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            labelText: 'name'.tr,
                            prefixIcon: const Icon(Icons.person_outline),
                          ),
                          validator: requiredText,
                        ),
                        const SizedBox(height: 10),
                      ],
                      TextFormField(
                        controller: _email,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.email],
                        decoration: InputDecoration(
                          labelText: 'email'.tr,
                          prefixIcon: const Icon(Icons.mail_outline),
                        ),
                        validator: (value) =>
                            requiredText(value) ??
                            (GetUtils.isEmail(value!.trim())
                                ? null
                                : 'invalid_email'.tr),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _password,
                        obscureText: _hidePassword,
                        autofillHints: [
                          signingUp
                              ? AutofillHints.newPassword
                              : AutofillHints.password,
                        ],
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _submit(auth),
                        decoration: InputDecoration(
                          labelText: 'password'.tr,
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            tooltip:
                                (_hidePassword
                                        ? 'show_password'
                                        : 'hide_password')
                                    .tr,
                            onPressed: () =>
                                setState(() => _hidePassword = !_hidePassword),
                            icon: Icon(
                              _hidePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                          ),
                        ),
                        validator: (value) =>
                            requiredText(value) ??
                            (signingUp && value!.length < 6
                                ? 'invalid_password'.tr
                                : null),
                      ),
                      if (error != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          error.tr,
                          style: const TextStyle(color: AppColors.red),
                        ),
                      ],
                      const SizedBox(height: 12),
                      FilledButton(
                        onPressed: () => _submit(auth),
                        child: Text((signingUp ? 'sign_up' : 'sign_in').tr),
                      ),
                      const SizedBox(height: 5),
                      TextButton.icon(
                        onPressed: auth.openDemo,
                        icon: const Icon(
                          Icons.play_circle_outline_rounded,
                          size: 20,
                        ),
                        label: Text('demo'.tr),
                      ),
                      Text(
                        'demo_note'.tr,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.muted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  void _submit(AuthController auth) {
    if (!_form.currentState!.validate()) return;
    FocusManager.instance.primaryFocus?.unfocus();
    auth.submit(name: _name.text, email: _email.text, password: _password.text);
  }
}

class _ModeButton extends StatelessWidget {
  const _ModeButton(this.label, this.active, this.onTap);

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    selected: active,
    child: TextButton(
      style: TextButton.styleFrom(
        minimumSize: const Size(0, 44),
        backgroundColor: active ? AppColors.mint : Colors.transparent,
        foregroundColor: active ? AppColors.forest : AppColors.muted,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onPressed: onTap,
      child: Text(label, textAlign: TextAlign.center),
    ),
  );
}

class _WelcomeCard extends StatelessWidget {
  const _WelcomeCard();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsetsDirectional.fromSTEB(21, 20, 12, 20),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(25),
      gradient: const LinearGradient(
        colors: [AppColors.forest, Color(0xFF236953)],
        begin: AlignmentDirectional.centerStart,
        end: AlignmentDirectional.bottomEnd,
      ),
    ),
    child: LayoutBuilder(
      builder: (context, constraints) => Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'auth_title'.tr,
                  style: TextStyle(
                    color: AppColors.surface,
                    fontSize: 29,
                    fontWeight: FontWeight.w700,
                    height: 1.18,
                  ),
                ),
                const SizedBox(height: 9),
                Text(
                  'auth_subtitle'.tr,
                  style: const TextStyle(
                    color: Color(0xFFD7EBDF),
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          if (constraints.maxWidth >= 235)
            Image.asset(
              'assets/images/care-heart.png',
              width: (constraints.maxWidth * .34).clamp(75, 156),
              excludeFromSemantics: true,
            ),
        ],
      ),
    ),
  );
}
