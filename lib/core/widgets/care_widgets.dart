import 'package:material_ui/material_ui.dart';
import 'package:get/get.dart';

import '../theme/app_colors.dart';

class CareIcon extends StatelessWidget {
  const CareIcon(
    this.icon, {
    super.key,
    this.background = AppColors.mint,
    this.color = AppColors.green,
    this.size = 46,
  });

  final IconData icon;
  final Color background;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      color: background,
      borderRadius: BorderRadius.circular(size * .31),
    ),
    child: Icon(icon, color: color, size: size * .52),
  );
}

class CareCard extends StatelessWidget {
  const CareCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(16),
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) => Material(
    color: AppColors.surface,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(21),
      side: const BorderSide(color: AppColors.line),
    ),
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      onTap: onTap,
      child: Padding(padding: padding, child: child),
    ),
  );
}

class CareList extends StatelessWidget {
  const CareList({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) => ListView(
      padding: EdgeInsetsDirectional.fromSTEB(
        ((constraints.maxWidth - 660) / 2).clamp(20, double.infinity),
        12,
        ((constraints.maxWidth - 660) / 2).clamp(20, double.infinity),
        24,
      ),
      children: children,
    ),
  );
}

class PageIntro extends StatelessWidget {
  const PageIntro(this.title, this.description, {super.key});

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(title, style: Theme.of(context).textTheme.headlineMedium),
      const SizedBox(height: 7),
      Text(
        description,
        style: const TextStyle(color: AppColors.muted, height: 1.5),
      ),
    ],
  );
}

class SectionTitle extends StatelessWidget {
  const SectionTitle(this.title, {super.key, this.action, this.onTap});

  final String title;
  final String? action;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Text(title, style: Theme.of(context).textTheme.titleLarge),
      ),
      if (action != null) TextButton(onPressed: onTap, child: Text(action!)),
    ],
  );
}

class EmptyCard extends StatelessWidget {
  const EmptyCard(
    this.icon,
    this.message, {
    super.key,
    this.action,
    this.onTap,
  });

  final IconData icon;
  final String message;
  final String? action;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => CareCard(
    padding: const EdgeInsets.all(24),
    child: SizedBox(
      width: double.infinity,
      child: Column(
        children: [
          CareIcon(icon),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.muted),
          ),
          if (action != null) ...[
            const SizedBox(height: 8),
            TextButton(onPressed: onTap, child: Text(action!)),
          ],
        ],
      ),
    ),
  );
}

class StatusPill extends StatelessWidget {
  const StatusPill(
    this.text, {
    super.key,
    this.background = AppColors.mint,
    this.color = AppColors.forest,
  });

  final String text;
  final Color background;
  final Color color;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: background,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
  );
}

String? requiredText(String? value) =>
    value == null || value.trim().isEmpty ? 'required'.tr : null;

Future<bool> confirmAction(
  BuildContext context, {
  required String title,
  required String action,
  String? description,
  String? cancel,
}) async =>
    await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: description == null ? null : Text(description),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(cancel ?? 'cancel'.tr),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(action),
          ),
        ],
      ),
    ) ??
    false;

Future<void> openPage(BuildContext context, Widget page) =>
    Navigator.of(context).push<void>(MaterialPageRoute(builder: (_) => page));
