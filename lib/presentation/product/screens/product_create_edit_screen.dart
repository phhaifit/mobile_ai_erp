import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobile_ai_erp/di/service_locator.dart';
import 'package:mobile_ai_erp/domain/entity/product/product.dart' as domain;
import 'package:mobile_ai_erp/presentation/product/store/product_form_store.dart';
import 'package:mobile_ai_erp/presentation/product/widgets/product_form.dart';
import 'package:mobile_ai_erp/constants/strings.dart';

class ProductCreateEditScreen extends StatefulWidget {
  final domain.Product? product;

  const ProductCreateEditScreen({Key? key, this.product}) : super(key: key);

  @override
  State<ProductCreateEditScreen> createState() => _ProductCreateEditScreenState();
}

class _ProductCreateEditScreenState extends State<ProductCreateEditScreen> {
  final ProductFormStore _formStore = getIt<ProductFormStore>();

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      _formStore.initializeForEdit(widget.product!);
    } else {
      _formStore.reset();
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product != null ? ProductStrings.editTitle : ProductStrings.createTitle),
        elevation: 0,
      ),
      body: Observer(
        builder: (context) {
          if (_formStore.isSubmitting) {
            return Center(child: CircularProgressIndicator());
          }

          return ProductForm(formStore: _formStore);
        },
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
