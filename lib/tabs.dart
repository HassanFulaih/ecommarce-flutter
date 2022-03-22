import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:search_page/search_page.dart';

import 'providers/auth.dart';
import 'providers/cart.dart';
import 'providers/product.dart';
import 'providers/products.dart';
import 'providers/theme_provider.dart';
import 'screens/product_detail_screen.dart';
import 'screens/user_products_screen.dart';
import 'tab_items.dart';
import 'tabs/account.dart';
import 'tabs/cart.dart';
import 'tabs/favourites.dart';
import 'tabs/home.dart';
import 'widgets/badge.dart';

class Person {
  static List<Person> people = [
    Person('Mike', 'Barron', 64),
    Person('Todd', 'Black', 30),
    Person('Ahmad', 'Edwards', 55),
    Person('Anthony', 'Johnson', 67),
    Person('Annette', 'Brooks', 39),
  ];

  final String name, surname;
  final num age;

  Person(this.name, this.surname, this.age);
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var _currentTab = TabItem.one;

  void _selectTab(TabItem tabItem) {
    setState(() => _currentTab = tabItem);
  }

  @override
  Widget build(BuildContext context) {
    var tm = Provider.of<ThemeProvider>(context, listen: true).themeMode;
    final cart = Provider.of<Cart>(context);
    final auth = Provider.of<Auth>(context, listen: false);
    final bool isAuth = auth.isAuth;
    final products = Provider.of<Products>(context, listen: false);
    final favoriteItems = products.favoriteItems;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          shape: const MyShapeBorder(20),
          backgroundColor: const Color(0xFF1D1E33),
          elevation: 0,
          title: const Text('Lar Test'),
          actions: [
            // IconButton(
            //   icon: const Icon(Icons.replay),
            //   onPressed: () {
            //     Provider.of<Products>(context, listen: false)
            //         .fetchAndSetProducts();
            //   },
            // ),
            // if (auth.isAuth &&
            //     (auth.phoneNumber == '07719313658' ||
            //         auth.phoneNumber == '07827157828'))

            if (auth.name!=null)
              if (auth.name!.contains('حسن') || auth.name!.contains('زهر'))
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => Navigator.of(context)
                      .pushNamed(UserProductsScreen.routeName),
                ),
            IconButton(
              icon: const Icon(Icons.search),
              tooltip: 'Search products',
              onPressed: () => showSearch(
                useRootNavigator: true,
                context: context,
                delegate: SearchPage<Product>(
                  items: products.items,
                  searchLabel: 'ابحث عن منتج',
                  suggestion: const Center(
                    child:
                        Text('البحث عن منتج عن طريق الاسم او الوصف او السعر'),
                  ),
                  failure: const Center(
                    child: Text(':( لم يتم ايجاد اي شيء'),
                  ),
                  filter: (product) => [
                    product.title,
                    product.description,
                    product.price.toString(),
                  ],
                  barTheme: Theme.of(context).copyWith(
                    backgroundColor: Colors.white,
                    primaryColor: Colors.white,
                    appBarTheme: AppBarTheme(
                      color:
                          Theme.of(context).canvasColor.computeLuminance() > 0.5
                              ? const Color(0xFFedf0ef)
                              : const Color(0xFF1D1E33),
                      elevation: 0,
                    ),
                    textTheme: Theme.of(context).textTheme.copyWith(
                          headline6: TextStyle(
                            color: Theme.of(context)
                                .primaryTextTheme
                                .headline6!
                                .color,
                            fontSize: 20,
                          ),
                        ),
                    inputDecorationTheme: InputDecorationTheme(
                      hintStyle: TextStyle(
                        color:
                            Theme.of(context).primaryTextTheme.caption!.color,
                        fontSize: 20,
                      ),
                      focusedErrorBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      border: InputBorder.none,
                    ),
                  ),
                  builder: (product) => Directionality(
                    textDirection: TextDirection.rtl,
                    child: ListTile(
                      onTap: () => Navigator.of(context).pushNamed(
                        ProductDetailScreen.routeName,
                        arguments: product.id,
                      ),
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(product.imageUrl),
                      ),
                      title: Text(product.title),
                      subtitle: Text(product.description),
                      //trailing: Text('\$${product.price}'),
                      trailing: IconButton(
                        icon: Icon(product.isFavorite
                            ? Icons.favorite
                            : Icons.favorite_border),
                        color: Theme.of(context).colorScheme.secondary,
                        onPressed: () {
                          product.toggleFavoriteStatus(auth.token, auth.userId);
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
            IconButton(
              icon: Icon(
                  tm == ThemeMode.light ? Icons.dark_mode : Icons.wb_sunny),
              onPressed: () {
                Provider.of<ThemeProvider>(context, listen: false)
                    .changeMode(tm == ThemeMode.light ? 'd' : 'l');
              },
            ),
            // Consumer<Cart>(
            //   builder: (_, Cart cart, ch) {
            //     //print(cart.itemCount.toString());
            //     return Badge(
            //       child: ch!,
            //       value: cart.itemCount.toString(),
            //     );
            //   },
            //   child: IconButton(
            //     icon: const Icon(Icons.shopping_cart),
            //     onPressed: () => _selectTab(TabItem.two),
            //   ),
            // ),
            // IconButton(
            //   icon: const Icon(Icons.account_circle),
            //   onPressed: () {
            //     _selectTab(TabItem.four);
            //   },
            // ),
          ],
        ),
        body: _buildBody(),
        bottomNavigationBar: BottomNavigation(
          currentTab: _currentTab,
          onSelectTab: _selectTab,
        ),
        floatingActionButton:
            (_currentTab == TabItem.two && cart.items.isNotEmpty)
                ? FloatingActionButton.extended(
                    label: const Text('حذف محتويات العربة'),
                    onPressed: () => cart.clear(),
                    icon: const Icon(Icons.delete),
                  )
                : (_currentTab == TabItem.three &&
                        !isAuth &&
                        favoriteItems.isNotEmpty)
                    ? const FloatingActionButton.extended(
                        label: Text(
                            'قائمة المفضلة هي مؤقتة، تحتاج إلى تسجيل الدخول لجعلها متاحة'),
                        onPressed: null,
                      )
                    : null,
      ),
    );
  }

  Widget _buildBody() {
    if (_currentTab == TabItem.one)
      return const Home();
    else if (_currentTab == TabItem.two)
      return const CartPage();
    else if (_currentTab == TabItem.three) {
      return const Favourites();
    } else {
      return const Account();
    }
  }
}

class MyShapeBorder extends ContinuousRectangleBorder {
  const MyShapeBorder(this.curveHeight);
  final double curveHeight;

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) => Path()
    ..lineTo(0, rect.size.height)
    ..quadraticBezierTo(
      rect.size.width / 114,
      rect.size.height + curveHeight * 1.5,
      rect.size.width,
      rect.size.height,
    )
    ..lineTo(rect.size.width, 0)
    ..close();
}

class BottomNavigation extends StatelessWidget {
  final TabItem currentTab;
  final ValueChanged<TabItem> onSelectTab;

  const BottomNavigation(
      {Key? key, required this.currentTab, required this.onSelectTab})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CurvedNavigationBar(
      index: currentTab.index,
      animationDuration: const Duration(milliseconds: 300),
      items: [
        _buildItem(TabItem.one),
        _buildItem(TabItem.two),
        _buildItem(TabItem.three),
        _buildItem(TabItem.four),
      ],
      onTap: (index) => onSelectTab(
        TabItem.values[index],
      ),
      height: 60,
      backgroundColor: Theme.of(context).canvasColor,
      color: Theme.of(context).canvasColor.computeLuminance() > 0.5
          ? const Color(0xFF1D1E33)
          : const Color(0xFFedf0ef),
      //iconSize: 30,
      // selectedFontSize: 19,
      // unselectedFontSize: 17,
      // unselectedLabelStyle: const TextStyle(
      //   color: Colors.green,
      //   fontWeight: FontWeight.bold,
      //   overflow: TextOverflow.ellipsis,
      // ),
      // selectedItemColor: Colors.indigo,
    );
  }

  _buildItem(TabItem tabItem) {
    return tabItem == TabItem.two
        ? Consumer<Cart>(
            builder: (_, Cart cart, ch) {
              //print(cart.itemCount.toString());
              return QBadge(
                child: ch!,
                value: cart.itemCount.toString(),
              );
            },
            child: Icon(
              Icons.shopping_cart,
              color:
                  currentTab == tabItem ? activeTabColor[tabItem] : Colors.grey,
            ),
          )
        : Icon(
            tabItem == TabItem.one
                ? Icons.home_outlined
                : tabItem == TabItem.three
                    ? Icons.favorite_outline
                    : Icons.person_outline,
            color:
                currentTab == tabItem ? activeTabColor[tabItem] : Colors.grey,
          );
    //label: tabName[tabItem],
  }
}
