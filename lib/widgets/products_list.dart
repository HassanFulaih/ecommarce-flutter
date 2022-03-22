import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/widgets/product_item.dart';

import '../providers/products.dart';

class ProductsList extends StatelessWidget {
  final String? categoryId;

  const ProductsList({Key? key, this.categoryId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final productData = Provider.of<Products>(context);
    final products = categoryId == null
        ? productData.items
        : productData.items
            .where((item) => item.category == categoryId)
            .toList();
    return (products.isEmpty)
        ? Center(
            child: emptyMessage(
            Icons.notes_sharp,
            'ليس هناك أي منتجات حتى الآن',
          ))
        : Flexible(
            child: ListView.builder(
              padding: const EdgeInsets.all(10.0),
              itemCount: products.length,
              itemBuilder: (ctx, i) => ChangeNotifierProvider.value(
                value: products[i],
                child: const ProductItem(isList: true),
              ),
            ),
          );
  }

  Column emptyMessage(icon, data) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Icon(icon, size: 108),
        const SizedBox(height: 8),
        Text(
          data,
          style: const TextStyle(fontSize: 22),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
