import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:material_ui/material_ui.dart';

import '../../models/app_user.dart';
import 'product_form.dart';

class AddProductPage extends StatelessWidget {
  final AppUser user;

  const AddProductPage({super.key, required this.user});

  Future<void> _addProduct(BuildContext context, ProductFormValues values) async {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    try {
      await FirebaseFirestore.instance.collection('products').add({
        ...values.toMap(),
        // Ürünün sahibi ve müşteriye gösterilecek çiftçi bilgisi
        'ownerId': user.uid,
        'sellerName': user.displayName,
        'sellerLocation': user.location,
        'createdAt': FieldValue.serverTimestamp(),
      });

      messenger.showSnackBar(SnackBar(content: Text('${values.name} satışa eklendi')));
      navigator.pop();
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Ürün eklenemedi: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Yeni Ürün Ekle')),
      body: ProductForm(
        defaultPhone: user.phone,
        submitLabel: 'Ürünü Kaydet',
        onSubmit: (values) => _addProduct(context, values),
      ),
    );
  }
}
