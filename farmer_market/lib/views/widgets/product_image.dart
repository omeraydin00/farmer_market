import 'package:cached_network_image/cached_network_image.dart';
import 'package:material_ui/material_ui.dart';

/// Ürün fotoğrafı. Adres boşsa ya da resim açılamazsa düz bir yer tutucu gösterir,
/// eskiden boş string ile Image.network çağrılıp kırmızı hata kutusu çıkıyordu.
class ProductImage extends StatelessWidget {
  final String? url;
  final double? width;
  final double? height;
  final BorderRadius borderRadius;

  const ProductImage({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.borderRadius = BorderRadius.zero,
  });

  @override
  Widget build(BuildContext context) {
    final hasUrl = url != null && url!.trim().isNotEmpty;

    return ClipRRect(
      borderRadius: borderRadius,
      child: SizedBox(
        width: width,
        height: height,
        child: hasUrl
            ? CachedNetworkImage(
                imageUrl: url!.trim(),
                fit: BoxFit.cover,
                fadeInDuration: const Duration(milliseconds: 200),
                placeholder: (context, _) => const _Placeholder(loading: true),
                errorWidget: (context, _, _) => const _Placeholder(broken: true),
              )
            : const _Placeholder(),
      ),
    );
  }
}

class _Placeholder extends StatelessWidget {
  final bool loading;
  final bool broken;

  const _Placeholder({this.loading = false, this.broken = false});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      color: scheme.surfaceContainerHigh,
      alignment: Alignment.center,
      child: loading
          ? null
          : Icon(
              broken ? Icons.broken_image_outlined : Icons.eco_outlined,
              color: scheme.outline,
              size: 32,
            ),
    );
  }
}
