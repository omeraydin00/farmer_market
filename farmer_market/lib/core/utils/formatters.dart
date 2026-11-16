import 'package:intl/intl.dart';

final _priceFormat = NumberFormat('#,##0.00', 'tr_TR');

/// 42.5 -> "42,50 ₺"
String formatPrice(double price) => '${_priceFormat.format(price)} ₺';

/// Arama için Türkçe küçük harf. Sadece toLowerCase() kullanınca "I" harfi "i" oluyordu,
/// "ISPANAK" yazan biri "ıspanak" ürününü bulamıyordu.
String trLower(String text) {
  return text.replaceAll('I', 'ı').replaceAll('İ', 'i').toLowerCase();
}

/// "Ayşe Kaya" -> "AK"
String initials(String name) {
  final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
  if (parts.isEmpty) return '?';
  if (parts.length == 1) return parts.first[0].toUpperCase();
  return (parts.first[0] + parts.last[0]).toUpperCase();
}
