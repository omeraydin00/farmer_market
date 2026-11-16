import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/utils/auth_errors.dart';
import '../../core/utils/validators.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _locationController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordAgainController = TextEditingController();

  // Rol sonradan değiştirilemediği için varsayılan seçim yok, kullanıcı bilerek seçsin
  String? _selectedRole;
  bool _showRoleError = false;
  AutovalidateMode _autovalidate = AutovalidateMode.disabled;
  bool _isLoading = false;
  bool _obscurePassword = true;

  bool get _isFarmer => _selectedRole == 'farmer';

  Future<void> _register() async {
    final formOk = _formKey.currentState!.validate();
    setState(() {
      _showRoleError = _selectedRole == null;
      // İlk denemeden sonra hatalar yazarken güncellensin, düzelen alanda kalmasın
      _autovalidate = AutovalidateMode.onUserInteraction;
    });
    if (!formOk || _selectedRole == null) return;

    setState(() => _isLoading = true);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    UserCredential? credential;
    try {
      credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      await FirebaseFirestore.instance.collection('users').doc(credential.user!.uid).set({
        'email': _emailController.text.trim(),
        'role': _selectedRole,
        'name': _nameController.text.trim(),
        if (_isFarmer) 'phone': _phoneController.text.trim(),
        if (_isFarmer) 'location': _locationController.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      messenger.showSnackBar(
        SnackBar(content: Text('Hesabınız oluşturuldu. Hoş geldiniz, ${_nameController.text.trim()}!')),
      );
      // AuthGate yeni oturumu görüp doğru ana sayfayı açtı, kayıt ekranını kapatıyoruz
      navigator.popUntil((route) => route.isFirst);
    } on FirebaseAuthException catch (e) {
      _showSnackBar(authErrorMessage(e));
    } catch (e) {
      // Profil yazılamadıysa rolsüz bir hesap kalmasın
      try {
        await credential?.user?.delete();
      } catch (_) {}
      _showSnackBar('Kayıt tamamlanamadı: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _passwordAgainController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Kayıt Ol')),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Form(
                key: _formKey,
                autovalidateMode: _autovalidate,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('Nasıl kullanacaksınız?', style: theme.textTheme.titleLarge),
                    const SizedBox(height: 4),
                    Text(
                      'Hesap türü sonradan değiştirilemez.',
                      style: theme.textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _RoleOption(
                            icon: Icons.agriculture_outlined,
                            title: 'Çiftçi',
                            subtitle: 'Ürünlerimi satacağım',
                            selected: _selectedRole == 'farmer',
                            onTap: () => setState(() {
                              _selectedRole = 'farmer';
                              _showRoleError = false;
                            }),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _RoleOption(
                            icon: Icons.shopping_basket_outlined,
                            title: 'Müşteri',
                            subtitle: 'Taze ürün alacağım',
                            selected: _selectedRole == 'customer',
                            onTap: () => setState(() {
                              _selectedRole = 'customer';
                              _showRoleError = false;
                            }),
                          ),
                        ),
                      ],
                    ),
                    if (_showRoleError)
                      Padding(
                        padding: const EdgeInsets.only(top: 8, left: 4),
                        child: Text(
                          'Lütfen hesap türünü seçin',
                          style: theme.textTheme.bodySmall?.copyWith(color: scheme.error),
                        ),
                      ),
                    const SizedBox(height: 28),
                    Text('Bilgileriniz', style: theme.textTheme.titleMedium),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _nameController,
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.next,
                      validator: (v) => requiredField(v, message: 'Ad soyad gerekli'),
                      decoration: const InputDecoration(
                        labelText: 'Ad Soyad',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                    ),
                    // Çiftçinin telefonu ve konumu ürün sayfasında müşteriye gösteriliyor
                    AnimatedSize(
                      duration: const Duration(milliseconds: 200),
                      alignment: Alignment.topCenter,
                      child: _isFarmer
                          ? Column(
                              children: [
                                const SizedBox(height: 14),
                                TextFormField(
                                  controller: _phoneController,
                                  keyboardType: TextInputType.phone,
                                  textInputAction: TextInputAction.next,
                                  validator: validatePhone,
                                  decoration: const InputDecoration(
                                    labelText: 'Telefon',
                                    hintText: '05xx xxx xx xx',
                                    prefixIcon: Icon(Icons.phone_outlined),
                                  ),
                                ),
                                const SizedBox(height: 14),
                                TextFormField(
                                  controller: _locationController,
                                  textCapitalization: TextCapitalization.words,
                                  textInputAction: TextInputAction.next,
                                  validator: (v) => requiredField(v, message: 'Konum gerekli'),
                                  decoration: const InputDecoration(
                                    labelText: 'Konum',
                                    hintText: 'İlçe, İl',
                                    prefixIcon: Icon(Icons.place_outlined),
                                  ),
                                ),
                              ],
                            )
                          : const SizedBox(width: double.infinity),
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
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
                      textInputAction: TextInputAction.next,
                      validator: validatePassword,
                      decoration: InputDecoration(
                        labelText: 'Şifre',
                        helperText: 'En az 6 karakter',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          tooltip: _obscurePassword ? 'Şifreyi göster' : 'Şifreyi gizle',
                          icon: Icon(_obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _passwordAgainController,
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.done,
                      validator: (v) => v != _passwordController.text ? 'Şifreler aynı değil' : null,
                      decoration: const InputDecoration(
                        labelText: 'Şifre (tekrar)',
                        prefixIcon: Icon(Icons.lock_outline),
                      ),
                    ),
                    const SizedBox(height: 28),
                    FilledButton(
                      onPressed: _isLoading ? null : _register,
                      child: _isLoading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(strokeWidth: 2.5),
                            )
                          : const Text('Kayıt Ol'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RoleOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  const _RoleOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final fg = selected ? scheme.onPrimaryContainer : scheme.onSurface;

    return Semantics(
      button: true,
      selected: selected,
      label: '$title: $subtitle',
      child: Material(
        color: selected ? scheme.primaryContainer : theme.cardTheme.color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: selected ? scheme.primary : scheme.outlineVariant,
            width: selected ? 2 : 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: selected ? scheme.primary : scheme.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(icon, color: selected ? scheme.onPrimary : scheme.primary),
                    ),
                    Icon(
                      selected ? Icons.check_circle : Icons.radio_button_unchecked,
                      color: selected ? scheme.primary : scheme.outlineVariant,
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(title, style: theme.textTheme.titleMedium?.copyWith(color: fg)),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: selected ? scheme.onPrimaryContainer : scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
