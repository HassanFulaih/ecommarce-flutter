import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth.dart';
import '../providers/cart.dart';
import '../providers/product.dart';
import '../screens/product_detail_screen.dart';

class ProductItem extends StatelessWidget {
  final bool isList;
  const ProductItem({Key? key, required this.isList}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final product = Provider.of<Product>(context, listen: false);
    final cart = Provider.of<Cart>(context, listen: false);
    final authData = Provider.of<Auth>(context, listen: false);

    return isList
        ? ListTile(
            onTap: () => Navigator.of(context).pushNamed(
              ProductDetailScreen.routeName,
              arguments: product.id,
            ),
            leading: Hero(
              tag: product.id,
              child: CircleAvatar(
                backgroundImage: NetworkImage(product.imageUrl),
              ),
            ),
            title: Text(product.title),
            subtitle: Text('\$${product.price}'),
            trailing: SizedBox(
              width: 100,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  favButton(context, authData),
                  cartButton(context, cart, product),
                ],
              ),
            ),
          )
        : ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: GridTile(
              child: GestureDetector(
                onTap: () => Navigator.of(context).pushNamed(
                  ProductDetailScreen.routeName,
                  arguments: product.id,
                ),
                child: Hero(
                  tag: product.id,
                  child: FadeInImage(
                    placeholder: const AssetImage(
                        'assets/images/product-placeholder.png'),
                    image: NetworkImage(product.imageUrl),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              footer: GridTileBar(
                backgroundColor: Colors.black87,
                leading: favButton(context, authData),
                title: Text(product.title, textAlign: TextAlign.center),
                trailing: cartButton(context, cart, product),
              ),
            ),
          );
  }

  IconButton cartButton(BuildContext context, Cart cart, Product product) {
    return IconButton(
      icon: const Icon(Icons.shopping_cart),
      color: Theme.of(context).colorScheme.secondary,
      onPressed: () {
        cart.addItem(
            product.id, product.category, product.price, product.title);
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'تمت إضافة المنتج إلى العربة',
              style: TextStyle(
                color: Theme.of(context).canvasColor.computeLuminance() > 0.5
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
                cart.removeSingleItem(product.id);
              },
            ),
          ),
        );
      },
    );
  }

  Consumer<Product> favButton(BuildContext context, Auth authData) {
    return Consumer<Product>(
      builder: (ctx, product, _) => IconButton(
        icon: Icon(product.isFavorite ? Icons.favorite : Icons.favorite_border),
        color: Theme.of(context).colorScheme.secondary,
        onPressed: () {
          product.toggleFavoriteStatus(authData.token, authData.userId);
        },
      ),
    );
  }
}
