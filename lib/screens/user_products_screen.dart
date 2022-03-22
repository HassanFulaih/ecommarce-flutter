import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/products.dart';
import '../widgets/user_product_item.dart';
import './edit_product_screen.dart';

class UserProductsScreen extends StatelessWidget {
  static const routeName = '/user-products';

  const UserProductsScreen({Key? key}) : super(key: key);

  Future<void> _refreshProducts(BuildContext context) async {
    try {
      await Provider.of<Products>(context, listen: false)
          .fetchAndSetProducts(true);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    //final products = Provider.of<Products>(context).items;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor:  const Color(0xFF1D1E33),
          elevation: 0,
          title: const Text('منتجاتك'),
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () =>
                  Navigator.of(context).pushNamed(EditProductScreen.routeName),
            ),
          ],
        ),
        body: FutureBuilder(
          future: _refreshProducts(context),
          builder: (ctx, AsyncSnapshot snapshot) =>
              snapshot.connectionState == ConnectionState.waiting
                  ? const Center(child: CircularProgressIndicator())
                  : RefreshIndicator(
                      onRefresh: () => _refreshProducts(context),
                      child: Consumer<Products>(
                        builder: (ctx, productsData, _) => Padding(
                          padding: const EdgeInsets.all(8),
                          child: ListView.builder(
                            itemCount: productsData.items.length,
                            itemBuilder: (_, int index) => Column(
                              children: [
                                UserProductItem(
                                  productsData.items[index].id,
                                  productsData.items[index].title,
                                  productsData.items[index].imageUrl,
                                ),
                                const Divider(),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
        ),
      ),
    );
  }
}
