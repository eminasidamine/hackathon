import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../core/theme.dart';

bool isNarrowAdmin(BuildContext context) =>
    MediaQuery.sizeOf(context).width < 700;

double adminDialogWidth(BuildContext context, double desired) {
  // AlertDialog reserves its own inset padding (40 per side by default) plus
  // internal content padding on top of whatever width we ask for here — if
  // we don't budget for that too, the content we request gets squeezed
  // narrower than expected once actually laid out inside the dialog, which
  // is what made the gender SegmentedButton wrap its "Women" label on phones.
  return (MediaQuery.sizeOf(context).width - 112).clamp(200, desired);
}

class AdminPageHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? action;

  const AdminPageHeader(
      {super.key, required this.title, this.subtitle, this.action});

  @override
  Widget build(BuildContext context) {
    final narrow = isNarrowAdmin(context);
    final titleBlock = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AdminTheme.ink)),
        if (subtitle != null) ...[
          const SizedBox(height: 3),
          Text(subtitle!,
              style: const TextStyle(fontSize: 13, color: AdminTheme.muted)),
        ],
      ],
    );
    return Padding(
      padding: EdgeInsets.fromLTRB(narrow ? 16 : 28, 20, narrow ? 16 : 28, 16),
      child: narrow
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                titleBlock,
                if (action != null) ...[const SizedBox(height: 14), action!],
              ],
            )
          : Row(
              children: [
                Expanded(child: titleBlock),
                if (action != null) action!,
              ],
            ),
    );
  }
}

class AdminCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const AdminCard(
      {super.key, required this.child, this.padding = const EdgeInsets.all(4)});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AdminTheme.card,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
              color: Color(0x0A000000), blurRadius: 2, offset: Offset(0, 1))
        ],
      ),
      padding: padding,
      child: child,
    );
  }
}

class AdminStatusPill extends StatelessWidget {
  final String label;
  final Color color;

  const AdminStatusPill({super.key, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(20)),
      child: Text(label,
          style: TextStyle(
              color: color, fontWeight: FontWeight.w600, fontSize: 12)),
    );
  }
}

Future<bool> confirmDialog(BuildContext context,
    {required String title, required String message}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel')),
        FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Confirm')),
      ],
    ),
  );
  return result ?? false;
}

void showAdminError(BuildContext context, Object error) {
  debugPrint('Erreur admin : $error');
  // A SnackBar renders behind a dialog's own modal barrier when called from
  // inside one (e.g. a create/edit dialog's error handler) — invisible to
  // the user, who just sees nothing happen. A dialog stacks reliably on top
  // of another dialog (or a plain screen), so it's always actually seen.
  showDialog<void>(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Something went wrong'),
      content: const Text(
          "Try again, and if it keeps happening, check your internet connection."),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('OK'),
        ),
      ],
    ),
  );
}
