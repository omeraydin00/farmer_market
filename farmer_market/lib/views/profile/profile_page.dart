import 'package:firebase_auth/firebase_auth.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../../core/theme/theme_provider.dart';
import '../../core/utils/formatters.dart';
import '../../models/app_user.dart';
import 'change_password_page.dart';

class ProfilePage extends StatelessWidget {
  final AppUser user;

  const ProfilePage({super.key, required this.user});

  Future<void> _signOut(BuildContext context) async {
    final navigator = Navigator.of(context);
    await FirebaseAuth.instance.signOut();
    // Giriş ekranını AuthGate gösteriyor, üstteki sayfaları kapatmak yeterli
    navigator.popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final themeProvider = context.watch<ThemeProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Profilim')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          const SizedBox(height: 8),
          Center(
            child: CircleAvatar(
              radius: 44,
              backgroundColor: scheme.primaryContainer,
              child: Text(
                initials(user.displayName),
                style: theme.textTheme.headlineSmall?.copyWith(color: scheme.onPrimaryContainer),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(user.displayName, textAlign: TextAlign.center, style: theme.textTheme.titleLarge),
          const SizedBox(height: 2),
          Text(
            user.email,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: 10),
          Center(
            child: Chip(
              avatar: Icon(
                user.isFarmer ? Icons.agriculture_outlined : Icons.shopping_basket_outlined,
                size: 18,
                color: scheme.onSecondaryContainer,
              ),
              label: Text(user.roleLabel),
              backgroundColor: scheme.secondaryContainer,
              side: BorderSide.none,
            ),
          ),
          const SizedBox(height: 24),
          if (user.isFarmer) ...[
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.phone_outlined),
                    title: const Text('Telefon'),
                    subtitle: Text(user.phone?.isNotEmpty == true ? user.phone! : '-'),
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  ListTile(
                    leading: const Icon(Icons.place_outlined),
                    title: const Text('Konum'),
                    subtitle: Text(user.location?.isNotEmpty == true ? user.location! : '-'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  secondary: const Icon(Icons.dark_mode_outlined),
                  title: const Text('Koyu tema'),
                  value: themeProvider.isDark,
                  onChanged: (_) => themeProvider.toggleTheme(),
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                ListTile(
                  leading: const Icon(Icons.lock_reset),
                  title: const Text('Şifreyi Değiştir'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ChangePasswordPage()),
                  ),
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                ListTile(
                  leading: Icon(Icons.logout, color: scheme.error),
                  title: Text('Çıkış Yap', style: TextStyle(color: scheme.error)),
                  onTap: () => _signOut(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
