import 'package:farmer_market/core/utils/formatters.dart';
import 'package:farmer_market/core/utils/validators.dart';
import 'package:farmer_market/models/product.dart';
import 'package:farmer_market/views/widgets/sort_chips.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Product.fromMap', () {
    test('stok double kaydedilmişse de okunuyor', () {
      final p = Product.fromMap({'name': 'Domates', 'price': 40, 'stockKg': 12.0}, 'x');
      expect(p.stockKg, 12);
      expect(p.price, 40.0);
    });

    test('eksik alanlar varsayılan değer alıyor', () {
      final p = Product.fromMap({}, 'x');
      expect(p.name, '');
      expect(p.stockKg, 0);
      expect(p.isOutOfStock, isTrue);
      expect(p.hasImage, isFalse);
    });

    test('az kaldı eşiği', () {
      Product withStock(int kg) => Product(id: 'x', name: 'Biber', price: 10, stockKg: kg);
      expect(withStock(Product.lowStockKg - 1).isLowStock, isTrue);
      expect(withStock(Product.lowStockKg).isLowStock, isFalse);
      expect(withStock(0).isLowStock, isFalse);
    });
  });

  test('fiyata göre sıralama', () {
    final list = [
      Product(id: 'a', name: 'A', price: 30, stockKg: 1),
      Product(id: 'b', name: 'B', price: 10, stockKg: 1),
      Product(id: 'c', name: 'C', price: 20, stockKg: 1),
    ];
    expect(ProductSort.artan.apply(list).map((p) => p.id), ['b', 'c', 'a']);
    expect(ProductSort.azalan.apply(list).map((p) => p.id), ['a', 'c', 'b']);
  });

  test('Türkçe küçük harf', () {
    expect(trLower('ISPANAK'), 'ıspanak');
    expect(trLower('İNCİR'), 'incir');
  });

  test('fiyat virgülle de yazılabiliyor', () {
    expect(parsePrice('42,50'), 42.5);
    expect(validatePrice('0'), isNotNull);
    expect(validatePrice('12.5'), isNull);
  });

  test('resim adresi doğrulama', () {
    expect(validateImageUrl(''), isNull);
    expect(validateImageUrl('domates.jpg'), isNotNull);
    expect(validateImageUrl('https://ornek.com/domates.jpg'), isNull);
  });
}
