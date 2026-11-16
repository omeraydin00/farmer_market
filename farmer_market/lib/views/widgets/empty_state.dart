import 'package:material_ui/material_ui.dart';

/// Liste boşken ya da hata olduğunda ortada gösterilen ikon + mesaj
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String text;
  final Widget? action;

  const EmptyState({super.key, required this.icon, required this.text, this.action});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 48, color: theme.colorScheme.outline),
          const SizedBox(height: 12),
          Text(
            text,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
          if (action != null) ...[
            const SizedBox(height: 20),
            action!,
          ],
        ],
      ),
    );
  }
}
