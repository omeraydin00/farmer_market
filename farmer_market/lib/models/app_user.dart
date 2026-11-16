class AppUser {
  final String uid;
  final String email;
  final String role; // 'farmer' veya 'customer'
  final String name;
  final String? phone;
  final String? location;

  AppUser({
    required this.uid,
    required this.email,
    required this.role,
    required this.name,
    this.phone,
    this.location,
  });

  bool get isFarmer => role == 'farmer';
  bool get isCustomer => role == 'customer';
  bool get hasValidRole => isFarmer || isCustomer;

  String get roleLabel => isFarmer ? 'Çiftçi' : 'Müşteri';

  /// Adı olmayan eski hesaplarda e-postanın baş kısmı gösteriliyor
  String get displayName => name.trim().isNotEmpty ? name.trim() : email.split('@').first;

  factory AppUser.fromMap(Map<String, dynamic> map, String uid) {
    return AppUser(
      uid: uid,
      email: map['email'] ?? '',
      role: map['role'] ?? '',
      name: map['name'] ?? '',
      phone: map['phone'],
      location: map['location'],
    );
  }
}
