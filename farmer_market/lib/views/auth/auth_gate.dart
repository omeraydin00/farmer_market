import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:material_ui/material_ui.dart';

import '../../models/app_user.dart';
import '../home/customer_home_page.dart';
import '../home/farmer_home_page.dart';
import 'login_page.dart';

/// Uygulamanın tek giriş noktası. Oturum ve kullanıcı rolü değiştikçe
/// doğru ekranı kendisi seçiyor, diğer sayfalar ayrıca yönlendirme yapmıyor.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _LoadingScreen();
        }

        final user = snapshot.data;
        if (user == null) {
          return const LoginPage();
        }

        // Her kullanıcı için ayrı key, hesap değişince profil akışı yeniden kurulsun
        return _ProfileGate(key: ValueKey(user.uid), uid: user.uid);
      },
    );
  }
}

class _ProfileGate extends StatefulWidget {
  final String uid;

  const _ProfileGate({super.key, required this.uid});

  @override
  State<_ProfileGate> createState() => _ProfileGateState();
}

class _ProfileGateState extends State<_ProfileGate> {
  // Eskiden FutureBuilder build içinde get() yapıyordu. Kayıt sırasında kullanıcı
  // belgesi henüz yazılmadan okununca giriş ekranına düşüyordu. Akış dinlenince
  // belge oluştuğu an doğru ana sayfa açılıyor.
  late final Stream<DocumentSnapshot<Map<String, dynamic>>> _userStream =
      FirebaseFirestore.instance.collection('users').doc(widget.uid).snapshots();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: _userStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const _MissingProfileScreen(
            message: 'Hesap bilgileri yüklenemedi. Bağlantınızı kontrol edip tekrar deneyin.',
          );
        }
        if (!snapshot.hasData) {
          return const _LoadingScreen();
        }

        final doc = snapshot.data!;
        if (!doc.exists) {
          return const _MissingProfileScreen(
            message: 'Bu hesaba ait kullanıcı bilgisi bulunamadı.',
          );
        }

        final appUser = AppUser.fromMap(doc.data()!, doc.id);
        if (appUser.isFarmer) return FarmerHomePage(user: appUser);
        if (appUser.isCustomer) return CustomerHomePage(user: appUser);

        return const _MissingProfileScreen(
          message: 'Hesabınızın rolü tanımlı değil (Çiftçi / Müşteri).',
        );
      },
    );
  }
}

class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}

/// Oturum açık ama profil belgesi yoksa (ya da rol bozuksa) kullanıcı
/// eskiden giriş ekranında takılı kalıyordu, burada en azından çıkış yapabiliyor.
class _MissingProfileScreen extends StatelessWidget {
  final String message;

  const _MissingProfileScreen({required this.message});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.person_off_outlined, size: 56, color: theme.colorScheme.outline),
                const SizedBox(height: 16),
                Text(message, textAlign: TextAlign.center, style: theme.textTheme.bodyLarge),
                const SizedBox(height: 24),
                FilledButton.tonal(
                  onPressed: () => FirebaseAuth.instance.signOut(),
                  child: const Text('Çıkış Yap'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
