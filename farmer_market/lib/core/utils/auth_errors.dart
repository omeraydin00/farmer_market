import 'package:firebase_auth/firebase_auth.dart';

// Firebase hata kodlarını kullanıcıya gösterilecek mesaja çevirir.
// Yeni SDK'lar yanlış şifre / olmayan kullanıcı için ayrı kod yerine
// 'invalid-credential' döndürüyor, eski kodlar da duruyor.
String authErrorMessage(FirebaseAuthException e) {
  switch (e.code) {
    case 'invalid-credential':
    case 'wrong-password':
    case 'user-not-found':
      return 'E-posta veya şifre hatalı.';
    case 'invalid-email':
      return 'Geçersiz e-posta adresi.';
    case 'user-disabled':
      return 'Bu hesap devre dışı bırakılmış.';
    case 'email-already-in-use':
      return 'Bu e-posta zaten kayıtlı.';
    case 'weak-password':
      return 'Şifre en az 6 karakter olmalı.';
    case 'too-many-requests':
      return 'Çok fazla deneme yapıldı, biraz sonra tekrar deneyin.';
    case 'network-request-failed':
      return 'İnternet bağlantısı yok gibi görünüyor.';
    default:
      return 'Bir hata oluştu (${e.code}).';
  }
}
