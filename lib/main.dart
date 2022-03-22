import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/screens/splash_screen.dart';

import './providers/auth.dart';
import './providers/cart.dart';
import './providers/orders.dart';
import './providers/products.dart';
import './providers/theme_provider.dart';
import './screens/edit_product_screen.dart';
import './screens/edit_user_screen.dart';
import './screens/orders_screen.dart';
import './screens/product_detail_screen.dart';
import './screens/user_products_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (BuildContext context) {
            return ThemeProvider();
          },
        ),
        ChangeNotifierProvider.value(value: Auth()),
        ChangeNotifierProvider.value(value: Cart()),
        ChangeNotifierProxyProvider<Auth, Products>(
          create: (_) => Products(),
          update: (ctx, authValue, previousProducts) => previousProducts!
            ..getData(
              authValue.token,
              authValue.userId,
              previousProducts.items,
            ),
        ),
        ChangeNotifierProxyProvider<Auth, Orders>(
          create: (_) => Orders(),
          update: (ctx, authValue, previousOrders) => previousOrders!
            ..getData(
              authValue.token!,
              authValue.userId!,
              previousOrders.orders,
              name: authValue.name!,
              phoneNumber: authValue.phoneNumber!,
              governorate: authValue.governorate!,
              region: authValue.region!,
            ),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Provider.of<ThemeProvider>(context, listen: false).getThemeMode();
    // final logout = Provider.of<Auth>(context, listen: false).logout();
    // final tryAutoLogin =
    Provider.of<Auth>(context, listen: false).tryAutoLogin();
    var tm = Provider.of<ThemeProvider>(context, listen: true).themeMode;
    return Consumer<Auth>(
      builder: (ctx, auth, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'MyShop',
          themeMode: tm,
          theme: ThemeData(
            // fontFamily: 'Lato',
            canvasColor: const Color(0xFFedf0ef), //#edf0ef #e0e0e0
            colorScheme: ColorScheme.fromSwatch(
              primarySwatch: Colors.teal,
              brightness: Brightness.light,
            ).copyWith(
              secondary: Colors.deepOrange,
            ),
          ),
          darkTheme: ThemeData(
            //fontFamily: 'Lato',
            canvasColor: const Color(0xFF1D1E33), //#1d232f  FF1D1E33
            dialogBackgroundColor: const Color(0xFF1D3462),
            colorScheme: ColorScheme.fromSwatch(
              primarySwatch: Colors.teal,
              brightness: Brightness.dark,
            ).copyWith(
              secondary: Colors.deepOrange,
            ),
          ),
          home: MySplash(isAuth: auth.isAuth),
          
          //auth.isAuth ? const HomePage() : const AuthScreen(),
          
          
          // : FutureBuilder(
          //     future:  tryAutoLogin,
          //     builder: (ctx, AsyncSnapshot authSnapshot) {
          //       print('isAuth: ${auth.isAuth}');

          //       return authSnapshot.connectionState ==
          //               ConnectionState.waiting
          //           ? const SplashScreen()
          //           : const AuthScreen();
          //     },
          //   ),
          routes: {
            ProductDetailScreen.routeName: (_) => const ProductDetailScreen(),
            OrderScreen.routeName: (_) => const OrderScreen(),
            UserProductsScreen.routeName: (_) => const UserProductsScreen(),
            EditProductScreen.routeName: (_) => const EditProductScreen(),
            EditUserScreen.routeName: (_) => const EditUserScreen(),
            //HomePage.routeName: (_) => const HomePage(),
          },
        );
      },
    );
  }
}
