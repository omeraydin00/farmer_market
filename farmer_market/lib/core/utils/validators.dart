// Form alanlarında ortak kullanılan doğrulamalar

String? requiredField(String? value, {String message = 'Bu alan boş bırakılamaz'}) {
  if (value == null || value.trim().isEmpty) return message;
  return null;
}

String? validateEmail(String? value) {
  final email = value?.trim() ?? '';
  if (email.isEmpty) return 'E-posta gerekli';
  if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
    return 'Geçerli bir e-posta girin';
  }
  return null;
}

String? validatePassword(String? value) {
  if (value == null || value.isEmpty) return 'Şifre gerekli';
  if (value.length < 6) return 'Şifre en az 6 karakter olmalı';
  return null;
}

String? validatePhone(String? value) {
  final digits = (value ?? '').replaceAll(RegExp(r'\D'), '');
  if (digits.isEmpty) return 'Telefon numarası gerekli';
  if (digits.length < 10 || digits.length > 12) return 'Geçerli bir telefon numarası girin';
  return null;
}

/// "42,50" ve "42.50" ikisini de kabul eder
double? parsePrice(String? value) {
  return double.tryParse((value ?? '').trim().replaceAll(',', '.'));
}

String? validatePrice(String? value) {
  final price = parsePrice(value);
  if (price == null) return 'Geçerli bir fiyat girin';
  if (price <= 0) return 'Fiyat sıfırdan büyük olmalı';
  return null;
}

String? validateStock(String? value) {
  final stock = int.tryParse((value ?? '').trim());
  if (stock == null) return 'Stok tam sayı olmalı (kg)';
  if (stock < 0) return 'Stok negatif olamaz';
  return null;
}

String? validateImageUrl(String? value) {
  final url = value?.trim() ?? '';
  if (url.isEmpty) return null; // resim zorunlu değil
  final uri = Uri.tryParse(url);
  if (uri == null || !(uri.scheme == 'http' || uri.scheme == 'https') || uri.host.isEmpty) {
    return 'http:// veya https:// ile başlayan bir adres girin';
  }
  return null;
}
