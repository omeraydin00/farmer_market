import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  // Bu miktarın altına düşen ürünlerde "az kaldı" uyarısı gösteriliyor
  static const int lowStockKg = 20;

  final String id;
  final String name;
  final double price; // kg fiyatı
  final String? imageUrl;
  final String? description;
  final String? ownerId;
  final String? sellerName;
  final String? sellerPhone;
  final String? sellerLocation;
  final int stockKg;
  final DateTime? createdAt;

  Product({
    required this.id,
    required this.name,
    required this.price,
    this.imageUrl,
    this.description,
    this.ownerId,
    this.sellerName,
    this.sellerPhone,
    this.sellerLocation,
    required this.stockKg,
    this.createdAt,
  });

  bool get isOutOfStock => stockKg <= 0;
  bool get isLowStock => !isOutOfStock && stockKg < lowStockKg;
  bool get hasImage => imageUrl != null && imageUrl!.trim().isNotEmpty;

  factory Product.fromMap(Map<String, dynamic> map, String id) {
    final created = map['createdAt'];
    return Product(
      id: id,
      name: map['name'] ?? '',
      price: (map['price'] as num? ?? 0).toDouble(),
      imageUrl: map['imageUrl'],
      description: map['description'],
      ownerId: map['ownerId'],
      sellerName: map['sellerName'],
      sellerPhone: map['sellerPhone'],
      sellerLocation: map['sellerLocation'],
      // Eskiden "as int" yapılıyordu, stok double kaydedilmişse liste komple çöküyordu
      stockKg: (map['stockKg'] as num? ?? 0).toInt(),
      createdAt: created is Timestamp ? created.toDate() : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
      'imageUrl': imageUrl,
      'description': description,
      'ownerId': ownerId,
      'sellerName': sellerName,
      'sellerPhone': sellerPhone,
      'sellerLocation': sellerLocation,
      'stockKg': stockKg,
    };
  }
}
