import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/products.dart';
import './product_item.dart';

class ProductsGrid extends StatelessWidget {
  final bool showFavs;
  final String? categoryId;

  const ProductsGrid(this.showFavs, {Key? key, this.categoryId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final productData = Provider.of<Products>(context);
    final products = showFavs
        ? productData.favoriteItems
        : categoryId == null
            ? productData.items
            : productData.items
                .where((item) => item.category == categoryId)
                .toList();
    return (products.isEmpty)
        ? Center(
            child: showFavs
                ? emptyMessage(
                    Icons.favorite_border_outlined,
                    'لم تقم بأضافة اي عنصر الى قائمة المفضلة',
                  )
                : emptyMessage(
                    Icons.grid_view_outlined,
                    'ليس هناك أي منتجات حتى الآن',
                  ))
        : Flexible(
            child: GridView.builder(
              padding: const EdgeInsets.all(10.0),
              itemCount: products.length,
              itemBuilder: (ctx, i) => ChangeNotifierProvider.value(
                value: products[i],
                child: const ProductItem(isList: false),
              ),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount:
                    MediaQuery.of(context).orientation == Orientation.portrait
                        ? 2
                        : 3,
                childAspectRatio: 3 / 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
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
