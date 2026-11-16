import 'package:firebase_auth/firebase_auth.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/utils/auth_errors.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  bool _isSending = false;

  Future<void> _sendPasswordResetEmail() async {
    final email = FirebaseAuth.instance.currentUser?.email;

    if (email == null) {
      _showSnackBar('Kullanıcı e-postası alınamadı.');
      return;
    }

    setState(() => _isSending = true);
    try {
      await FirebaseAuth.instance.setLanguageCode('tr');
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      _showSnackBar('Şifre sıfırlama e-postası gönderildi: $email');
    } on FirebaseAuthException catch (e) {
      _showSnackBar(authErrorMessage(e));
    } catch (e) {
      _showSnackBar('Hata oluştu: $e');
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final email = FirebaseAuth.instance.currentUser?.email ?? '';

    return Scaffold(
      appBar: AppBar(title: const Text('Şifre Değiştir')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 24),
          CircleAvatar(
            radius: 36,
            backgroundColor: theme.colorScheme.primaryContainer,
            child: Icon(Icons.lock_reset, size: 36, color: theme.colorScheme.onPrimaryContainer),
          ),
          const SizedBox(height: 20),
          Text(
            'Şifreni sıfırlamak için e-posta adresine bir bağlantı gönderilecek.',
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 6),
          Text(
            email,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 28),
          FilledButton.icon(
            onPressed: _isSending ? null : _sendPasswordResetEmail,
            icon: const Icon(Icons.mail_outline),
            label: Text(_isSending ? 'Gönderiliyor...' : 'E-posta Gönder'),
          ),
        ],
      ),
    );
  }
}
