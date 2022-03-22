import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/products.dart';
import '../widgets/products_grid.dart';

class Favourites extends StatefulWidget {
  const Favourites({Key? key}) : super(key: key);

  @override
  _FavouritesState createState() => _FavouritesState();
}

class _FavouritesState extends State<Favourites> {
  // var _isLoading = false;

  // @override
  // void initState() {
  //   super.initState();
  //   _isLoading = true;
  //   Provider.of<Products>(context, listen: false)
  //       .fetchAndSetProducts()
  //       .then((_) => setState(
  //             () => _isLoading = false,
  //           ))
  //       .catchError((_) => setState(
  //             () => _isLoading = false,
  //           ));
  // }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async => Provider.of<Products>(context, listen: false).fetchAndSetProducts(),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          SizedBox(height: 10),
          ProductsGrid(true),
        ],
      ),
    );
  }
}
