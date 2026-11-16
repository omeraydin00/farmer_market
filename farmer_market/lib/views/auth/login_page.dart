import 'package:firebase_auth/firebase_auth.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../../core/theme/theme_provider.dart';
import '../../core/utils/auth_errors.dart';
import '../../core/utils/validators.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  AutovalidateMode _autovalidate = AutovalidateMode.disabled;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      setState(() => _autovalidate = AutovalidateMode.onUserInteraction);
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Başarılı girişte yönlendirme yapmıyoruz, AuthGate oturumu görüp
      // rolüne göre doğru sayfayı açıyor
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
    } on FirebaseAuthException catch (e) {
      _showSnackBar(authErrorMessage(e));
    } catch (e) {
      _showSnackBar('Hata: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _resetPassword() async {
    final email = _emailController.text.trim();
    if (validateEmail(email) != null) {
      _showSnackBar('Önce e-posta adresinizi yazın.');
      return;
    }

    try {
      await FirebaseAuth.instance.setLanguageCode('tr');
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      _showSnackBar('Şifre sıfırlama bağlantısı gönderildi: $email');
    } on FirebaseAuthException catch (e) {
      _showSnackBar(authErrorMessage(e));
    }
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Form(
                    key: _formKey,
                    autovalidateMode: _autovalidate,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Logo
                        Center(child: Image.asset('assets/images/logo.png', height: 136)),
                        const SizedBox(height: 12),
                        Text(
                          'Farmer Market',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Taze ürünler, doğrudan çiftçiden.',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyLarge?.copyWith(color: scheme.onSurfaceVariant),
                        ),
                        const SizedBox(height: 36),

                        // Giriş formu
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          autofillHints: const [AutofillHints.email],
                          textInputAction: TextInputAction.next,
                          validator: validateEmail,
                          decoration: const InputDecoration(
                            labelText: 'E-posta',
                            prefixIcon: Icon(Icons.mail_outline),
                          ),
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          autofillHints: const [AutofillHints.password],
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _isLoading ? null : _login(),
                          validator: (v) => requiredField(v, message: 'Şifre gerekli'),
                          decoration: InputDecoration(
                            labelText: 'Şifre',
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              tooltip: _obscurePassword ? 'Şifreyi göster' : 'Şifreyi gizle',
                              icon: Icon(_obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: _isLoading ? null : _resetPassword,
                            child: const Text('Şifremi unuttum'),
                          ),
                        ),
                        const SizedBox(height: 8),
                        FilledButton(
                          onPressed: _isLoading ? null : _login,
                          child: _isLoading
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(strokeWidth: 2.5),
                                )
                              : const Text('Giriş Yap'),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Hesabın yok mu?', style: theme.textTheme.bodyMedium),
                            TextButton(
                              onPressed: _isLoading
                                  ? null
                                  : () => Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (_) => const RegisterPage()),
                                      ),
                              child: const Text('Kayıt Ol'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 4,
              right: 4,
              child: IconButton(
                onPressed: () => context.read<ThemeProvider>().toggleTheme(),
                icon: Icon(theme.brightness == Brightness.dark ? Icons.light_mode_outlined : Icons.dark_mode_outlined),
                tooltip: 'Temayı Değiştir',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
