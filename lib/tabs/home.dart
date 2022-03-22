import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/products.dart';
import '../widgets/products_grid.dart';
import '../widgets/products_list.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  var _isLoading = false;

  @override
  void initState() {
    super.initState();
    _isLoading = true;
    Provider.of<Products>(context, listen: false)
        .fetchAndSetProducts()
        .then((_) => setState(
              () => _isLoading = false,
            ))
        .catchError((_) => setState(
              () => _isLoading = false,
            ));
  }

  bool _isPharmaPressed = true;
  bool _isMedicalPressed = false;
  bool _isCosmaticsPressed = false;

  @override
  Widget build(BuildContext context) {
    var products = Provider.of<Products>(context, listen: false);
    var buttonStyle = ButtonStyle(
      shape: MaterialStateProperty.all(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      backgroundColor: MaterialStateProperty.all(Theme.of(context).errorColor),
      padding: MaterialStateProperty.all(
        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      ),
      textStyle: MaterialStateProperty.all(const TextStyle(
        color: Colors.white,
        //fontSize: 18,
        fontWeight: FontWeight.w700,
      )),
    );
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : RefreshIndicator(
            onRefresh: () => products.fetchAndSetProducts(),
            child: Column(
              children: [
                const SizedBox(height: 18),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox(width: 2),
                      Flexible(
                        child: ElevatedButton(
                          onPressed: _isPharmaPressed
                              ? null
                              : () {
                                  setState(() {
                                    _isPharmaPressed = !_isPharmaPressed;
                                    _isMedicalPressed = false;
                                    _isCosmaticsPressed = false;
                                  });
                                  products.switchCatView('أدوية');
                                },
                          child: const Text('أدوية'),
                          style: buttonStyle.copyWith(
                            backgroundColor: MaterialStateProperty.all(
                                _isPharmaPressed
                                    ? Colors.purple
                                    : Theme.of(context).errorColor),
                          ),
                        ),
                      ),
                      Flexible(
                        child: ElevatedButton(
                          onPressed: _isMedicalPressed
                              ? null
                              : () {
                                  setState(() {
                                    _isMedicalPressed = !_isMedicalPressed;
                                    _isPharmaPressed = false;
                                    _isCosmaticsPressed = false;
                                  });
                                  products.switchCatView('مواد طبية');
                                },
                          child: const Text('مواد طبية'),
                          style: buttonStyle.copyWith(
                            backgroundColor: MaterialStateProperty.all(
                                _isMedicalPressed
                                    ? Colors.purple
                                    : Theme.of(context).errorColor),
                          ),
                        ),
                      ),
                      Flexible(
                        child: ElevatedButton(
                          onPressed: _isCosmaticsPressed
                              ? null
                              : () {
                                  setState(() {
                                    _isCosmaticsPressed = !_isCosmaticsPressed;
                                    _isPharmaPressed = false;
                                    _isMedicalPressed = false;
                                  });
                                  products.switchCatView('مواد تجميلية');
                                },
                          child: const Text('مواد تجميلية'),
                          style: buttonStyle.copyWith(
                            backgroundColor: MaterialStateProperty.all(
                                _isCosmaticsPressed
                                    ? Colors.purple
                                    : Theme.of(context).errorColor),
                          ),
                        ),
                      ),
                      Flexible(
                        child: ElevatedButton(
                          onPressed: () => products.switchView(),
                          child: Icon(
                            !Provider.of<Products>(context).isListView
                                ? Icons.list_outlined
                                : Icons.grid_on_outlined,
                            size: 30,
                          ),
                          style: buttonStyle,
                        ),
                      ),
                      const SizedBox(width: 2),
                    ]),
                //const SizedBox(height: 8),
                if (Provider.of<Products>(context).catView == 'أدوية')
                  Provider.of<Products>(context).isListView
                      ? const ProductsList(categoryId: 'أدوية')
                      : const ProductsGrid(false, categoryId: 'أدوية'),
                if (Provider.of<Products>(context).catView == 'مواد طبية')
                  Provider.of<Products>(context).isListView
                      ? const ProductsList(categoryId: 'مواد طبية')
                      : const ProductsGrid(false, categoryId: 'مواد طبية'),
                if (Provider.of<Products>(context).catView == 'مواد تجميلية')
                  Provider.of<Products>(context).isListView
                      ? const ProductsList(categoryId: 'مواد تجميلية')
                      : const ProductsGrid(false, categoryId: 'مواد تجميلية'),
              ],
            ),
          );
  }

  // Widget block(String categoryName) {
  //   return Column(
  //     children: [
  //       Card(
  //         margin: const EdgeInsets.symmetric(horizontal: 10),
  //         shadowColor: Theme.of(context).colorScheme.primary,
  //         color: Theme.of(context).colorScheme.brightness == Brightness.light
  //             ? Colors.red[400]
  //             : Colors.red[100],
  //         child: Padding(
  //           padding: const EdgeInsets.symmetric(horizontal: 8),
  //           child: Row(
  //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //             children: [
  //               Text(categoryName,
  //                   style: TextStyle(
  //                     fontSize: 20,
  //                     color: Theme.of(context).colorScheme.brightness ==
  //                             Brightness.dark
  //                         ? Colors.black
  //                         : Colors.white,
  //                   )),
  //               TextButton(
  //                 child: Text(
  //                   'أظهار الكل',
  //                   style: TextStyle(
  //                     fontSize: 18,
  //                     color: Theme.of(context).colorScheme.brightness ==
  //                             Brightness.dark
  //                         ? Colors.black
  //                         : Colors.white,
  //                   ),
  //                 ),
  //                 onPressed: () {
  //                   Navigator.of(context).push(MaterialPageRoute(builder: (_) {
  //                     return SeeAllScreen(
  //                       categoryName: categoryName,
  //                     );
  //                   }));
  //                 },
  //               ),
  //             ],
  //           ),
  //         ),
  //       ),
  //       ProductsList(categoryId: categoryName),
  //     ],
  //   );
  // }
}
