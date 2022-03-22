import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/cart.dart';
import '../providers/products.dart';

class ProductDetailScreen extends StatelessWidget {
  static const routeName = '/product-detail';

  const ProductDetailScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<Cart>(context, listen: false);
    //final screenSize = MediaQuery.of(context).size;

    final productId = ModalRoute.of(context)!.settings.arguments as String;
    final loadedProduct =
        Provider.of<Products>(context, listen: false).findById(productId);
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              leading: IconButton(
                icon:
                    const Icon(Icons.arrow_back_ios, color: Color(0xFF1D1E33)),
                onPressed: () => Navigator.pop(context),
              ),
              expandedHeight: 300,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                title: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  color: Colors.black54,
                  child: Text(
                    loadedProduct.title,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                  ),
                ),
                background: Hero(
                  tag: loadedProduct.id,
                  child: Image.network(
                    loadedProduct.imageUrl,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildListDelegate(
                [
                  const SizedBox(height: 10),
                  Text(
                    'التصنيف: ${loadedProduct.category}',
                    style: const TextStyle(fontSize: 20),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '\$${loadedProduct.price}',
                    style: const TextStyle(color: Colors.grey, fontSize: 20),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    width: double.infinity,
                    child: Text(
                      loadedProduct.description,
                      textAlign: TextAlign.justify,
                      textDirection: TextDirection.ltr,
                      softWrap: true,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.shopping_cart),
          backgroundColor: Theme.of(context).colorScheme.secondary,
          onPressed: () {
            cart.addItem(loadedProduct.id, loadedProduct.category,
                loadedProduct.price, loadedProduct.title);
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'تمت إضافة المنتج إلى العربة',
                  style: TextStyle(
                    color:
                        Theme.of(context).canvasColor.computeLuminance() > 0.5
                            ? const Color(0xFF1D1E33)
                            : const Color(0xFFedf0ef),
                  ),
                ),
                duration: const Duration(seconds: 2),
                backgroundColor:
                    Theme.of(context).canvasColor.computeLuminance() > 0.5
                        ? const Color(0xFFedf0ef)
                        : const Color(0xFF1D1E33),
                action: SnackBarAction(
                  label: 'تراجع!',
                  onPressed: () {
                    cart.removeSingleItem(loadedProduct.id);
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
