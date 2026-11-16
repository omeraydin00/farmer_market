import 'dart:async';

import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/utils/validators.dart';
import '../../models/product.dart';
import '../widgets/product_image.dart';

/// Formdan çıkan, Firestore'a yazılmaya hazır değerler
class ProductFormValues {
  final String name;
  final double price;
  final int stockKg;
  final String imageUrl;
  final String description;
  final String phone;

  ProductFormValues({
    required this.name,
    required this.price,
    required this.stockKg,
    required this.imageUrl,
    required this.description,
    required this.phone,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
      'stockKg': stockKg,
      'imageUrl': imageUrl,
      'description': description,
      'sellerPhone': phone,
    };
  }
}

/// Ekleme ve düzenleme sayfalarının ortak formu. Önceden iki sayfada ayrı ayrı
/// yazılmıştı, düzenleme ekranında stok alanı hiç yoktu.
class ProductForm extends StatefulWidget {
  final Product? initial;
  final String? defaultPhone;
  final String submitLabel;
  final Future<void> Function(ProductFormValues values) onSubmit;

  const ProductForm({
    super.key,
    this.initial,
    this.defaultPhone,
    required this.submitLabel,
    required this.onSubmit,
  });

  @override
  State<ProductForm> createState() => _ProductFormState();
}

class _ProductFormState extends State<ProductForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _priceController;
  late final TextEditingController _stockKgController;
  late final TextEditingController _imageUrlController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _phoneController;
  String? _previewUrl;
  Timer? _previewTimer;
  bool _isSaving = false;
  AutovalidateMode _autovalidate = AutovalidateMode.disabled;

  @override
  void initState() {
    super.initState();
    final p = widget.initial;
    _nameController = TextEditingController(text: p?.name ?? '');
    _priceController = TextEditingController(
      text: p == null ? '' : p.price.toStringAsFixed(2).replaceAll('.', ','),
    );
    _stockKgController = TextEditingController(text: p == null ? '' : '${p.stockKg}');
    _imageUrlController = TextEditingController(text: p?.imageUrl ?? '');
    _descriptionController = TextEditingController(text: p?.description ?? '');
    _phoneController = TextEditingController(text: p?.sellerPhone ?? widget.defaultPhone ?? '');
    _previewUrl = p?.imageUrl;
  }

  @override
  void dispose() {
    _previewTimer?.cancel();
    _nameController.dispose();
    _priceController.dispose();
    _stockKgController.dispose();
    _imageUrlController.dispose();
    _descriptionController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _onImageUrlChanged(String value) {
    // Yazma bitince önizlemeyi güncelle, her harfte yarım adres indirilmeye çalışılmasın
    _previewTimer?.cancel();
    _previewTimer = Timer(const Duration(milliseconds: 600), () {
      final url = value.trim();
      if (mounted && (url.isEmpty || validateImageUrl(url) == null)) {
        setState(() => _previewUrl = url);
      }
    });
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) {
      setState(() => _autovalidate = AutovalidateMode.onUserInteraction);
      return;
    }

    setState(() => _isSaving = true);
    try {
      await widget.onSubmit(ProductFormValues(
        name: _nameController.text.trim(),
        price: parsePrice(_priceController.text)!,
        stockKg: int.parse(_stockKgController.text.trim()),
        imageUrl: _imageUrlController.text.trim(),
        description: _descriptionController.text.trim(),
        phone: _phoneController.text.trim(),
      ));
    } finally {
      // Kaydettikten sonra sayfa kapanmış olabilir
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Form(
      key: _formKey,
      autovalidateMode: _autovalidate,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: ProductImage(
              url: _previewUrl,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _imageUrlController,
            keyboardType: TextInputType.url,
            validator: validateImageUrl,
            onChanged: _onImageUrlChanged,
            decoration: const InputDecoration(
              labelText: 'Resim URL',
              hintText: 'https://...',
              helperText: 'Ürün fotoğrafının bağlantısı (isteğe bağlı)',
              prefixIcon: Icon(Icons.image_outlined),
            ),
          ),
          const SizedBox(height: 24),
          Text('Ürün bilgileri', style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),
          TextFormField(
            controller: _nameController,
            textCapitalization: TextCapitalization.sentences,
            textInputAction: TextInputAction.next,
            validator: (v) => requiredField(v, message: 'Ürün adı gerekli'),
            decoration: const InputDecoration(
              labelText: 'Ürün Adı',
              hintText: 'ör. Salkım domates',
              prefixIcon: Icon(Icons.eco_outlined),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TextFormField(
                  controller: _priceController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d.,]'))],
                  textInputAction: TextInputAction.next,
                  validator: validatePrice,
                  decoration: const InputDecoration(
                    labelText: 'Fiyat',
                    suffixText: '₺/kg',
                    prefixIcon: Icon(Icons.sell_outlined),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _stockKgController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  textInputAction: TextInputAction.next,
                  validator: validateStock,
                  decoration: const InputDecoration(
                    labelText: 'Stok',
                    suffixText: 'kg',
                    prefixIcon: Icon(Icons.scale_outlined),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 6, 12, 0),
            child: Text(
              'Stok ${Product.lowStockKg} kg altına düşünce ürün "Az kaldı" olarak işaretlenir.',
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _descriptionController,
            minLines: 3,
            maxLines: 5,
            maxLength: 300,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              labelText: 'Açıklama',
              hintText: 'Nasıl yetiştirildi, ne zaman toplandı...',
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 10),
          Text('İletişim', style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),
          TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            validator: validatePhone,
            decoration: const InputDecoration(
              labelText: 'Telefon Numarası',
              helperText: 'Müşteriler bu numaradan sizi arayacak',
              prefixIcon: Icon(Icons.phone_outlined),
            ),
          ),
          const SizedBox(height: 28),
          FilledButton.icon(
            onPressed: _isSaving ? null : _submit,
            icon: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2.5),
                  )
                : const Icon(Icons.check),
            label: Text(_isSaving ? 'Kaydediliyor...' : widget.submitLabel),
          ),
        ],
      ),
    );
  }
}
