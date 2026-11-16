import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:material_ui/material_ui.dart';

import '../../models/app_user.dart';
import '../../models/product.dart';
import 'product_form.dart';

class EditProductPage extends StatelessWidget {
  final Product product;
  final AppUser user;

  const EditProductPage({super.key, required this.product, required this.user});

  // Eskiden bu sayfaya sadece ad ve fiyat geliyordu, resim, açıklama ve telefon
  // alanları boş açılıyor ve kaydedince Firestore'daki değerlerin üstüne boş yazılıyordu.
  // Artık ürünün tamamı geliyor.
  Future<void> _updateProduct(BuildContext context, ProductFormValues values) async {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    try {
      await FirebaseFirestore.instance.collection('products').doc(product.id).update({
        ...values.toMap(),
        'sellerName': user.displayName,
        'sellerLocation': user.location,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      messenger.showSnackBar(const SnackBar(content: Text('Ürün güncellendi')));
      navigator.pop();
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Güncellenemedi: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ürünü Düzenle')),
      body: ProductForm(
        initial: product,
        defaultPhone: user.phone,
        submitLabel: 'Güncelle',
        onSubmit: (values) => _updateProduct(context, values),
      ),
    );
  }
}
