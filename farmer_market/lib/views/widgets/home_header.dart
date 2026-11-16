import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../../core/theme/theme_provider.dart';
import '../../core/utils/formatters.dart';
import '../../models/app_user.dart';
import '../profile/profile_page.dart';

/// Ana sayfaların üstündeki selamlama, tema düğmesi ve profil kısayolu
class HomeHeader extends StatelessWidget {
  final AppUser user;
  final String title;

  const HomeHeader({super.key, required this.user, required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 12, 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Merhaba, ${user.displayName.split(' ').first}',
                  style: theme.textTheme.bodyLarge?.copyWith(color: scheme.onSurfaceVariant),
                ),
                const SizedBox(height: 2),
                Text(title, style: theme.textTheme.headlineSmall),
              ],
            ),
          ),
          IconButton(
            icon: Icon(isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined),
            tooltip: 'Temayı Değiştir',
            onPressed: () => context.read<ThemeProvider>().toggleTheme(),
          ),
          const SizedBox(width: 4),
          Tooltip(
            message: 'Profil',
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ProfilePage(user: user)),
              ),
              child: CircleAvatar(
                radius: 22,
                backgroundColor: scheme.primaryContainer,
                child: Text(
                  initials(user.displayName),
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: scheme.onPrimaryContainer,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
