import 'package:flutter/material.dart';
import 'package:mobile_ai_erp/di/service_locator.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/brand.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/brands/brand_detail_body.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/navigation/product_metadata_navigator.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/navigation/product_metadata_route_args.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/store/product_metadata_store.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/widgets/metadata_detail_shell.dart';

class ProductMetadataBrandDetailScreen extends StatefulWidget {
  const ProductMetadataBrandDetailScreen({super.key, required this.args});

  final BrandDetailArgs args;

  @override
  State<ProductMetadataBrandDetailScreen> createState() =>
      _ProductMetadataBrandDetailScreenState();
}

class _ProductMetadataBrandDetailScreenState
    extends State<ProductMetadataBrandDetailScreen> {
  final ProductMetadataStore _store = getIt<ProductMetadataStore>();
  late Future<void> _loadBrandFuture;
  Brand? _brand;
  bool _hasChanged = false;

  @override
  void initState() {
    super.initState();
    _loadBrandFuture = _loadBrand();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _loadBrandFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return _shell(const Center(child: CircularProgressIndicator()));
        }
        final brand = _brand;
        if (brand == null) {
          return _shell(const Center(child: Text('Brand not found.')));
        }

        return _shell(
          BrandDetailBody(brand: brand),
          actions: <Widget>[
            IconButton(
              onPressed: () => _editBrand(brand),
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'Edit brand',
            ),
          ],
        );
      },
    );
  }

  Widget _shell(Widget body, {List<Widget>? actions}) {
    return MetadataDetailShell(
      title: 'Brand detail',
      hasChanged: _hasChanged,
      body: body,
      actions: actions,
    );
  }

  Future<void> _loadBrand() async {
    try {
      _brand = await _store.getBrandById(widget.args.brandId);
    } catch (_) {
      _brand = null;
    }
  }

  Future<void> _editBrand(Brand brand) async {
    final didChange = await ProductMetadataNavigator.openBrandForm<bool>(
      context,
      args: BrandFormArgs(brandId: brand.id),
    );
    if (didChange == true && mounted) {
      _hasChanged = true;
      await _loadBrand();
      final updatedBrand = _brand;
      if (!mounted) {
        return;
      }
      if (updatedBrand == null) {
        Navigator.of(context).pop(true);
        return;
      }
      setState(() {});
    }
  }
}
