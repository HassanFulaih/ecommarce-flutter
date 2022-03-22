import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth.dart';
import '../providers/cart.dart' show Cart;
import '../providers/orders.dart';
import '../screens/auth_screen.dart';
import '../widgets/cart_item.dart';

class CartPage extends StatefulWidget {
  const CartPage({Key? key}) : super(key: key);

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<Cart>(context);
    return Center(
      child: cart.items.isEmpty
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const <Widget>[
                Icon(Icons.remove_shopping_cart_rounded, size: 128),
                SizedBox(height: 24),
                Text(
                  'لم تقم بأضافة اي عنصرالى عربة التسوق',
                  style: TextStyle(fontSize: 22),
                  textAlign: TextAlign.center,
                ),
              ],
            )
          : Column(
              children: [
                Card(
                  margin: const EdgeInsets.all(15),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'المجموع',
                          style: TextStyle(fontSize: 20),
                        ),
                        const Spacer(),
                        Chip(
                          label: Text(
                            '\$${cart.totalAmount.toStringAsFixed(2)}',
                            style: TextStyle(
                              color: Theme.of(context)
                                  .primaryTextTheme
                                  .headline6!
                                  .color,
                            ),
                          ),
                          backgroundColor: Theme.of(context).primaryColor,
                        ),
                        OrderButton(cart: cart),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'قم بسحب أي عنصر لحذفه من عربة التسوق',
                  style: TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.builder(
                    itemCount: cart.items.length,
                    itemBuilder: (ctx, int index) => CartItem(
                      cart.items.values.toList()[index].id,
                      cart.items.keys.toList()[index],
                      cart.items.values.toList()[index].price,
                      cart.items.values.toList()[index].quantity,
                      cart.items.values.toList()[index].title,
                      cart.items.values.toList()[index].category,
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class OrderButton extends StatefulWidget {
  final Cart cart;
  const OrderButton({
    Key? key,
    required this.cart,
  }) : super(key: key);

  @override
  _OrderButtonState createState() => _OrderButtonState();
}

class _OrderButtonState extends State<OrderButton> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    bool isAuth = Provider.of<Auth>(context, listen: false).isAuth;
    final _dialog = AlertDialog(
      title: const Text(
        '!لم تقم بتسجيل الدخول',
        textAlign: TextAlign.center,
      ),
      content: const Text('تحتاج الى تسجيل الدخول لإنهاء الطلب'),
      actionsAlignment: MainAxisAlignment.start,
      actions: [
        TextButton(
          child: const Text('تسجيل الدخول'),
          onPressed: () {
            Navigator.of(context).pop();
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (ctx) => const AuthScreen(),
              ),
            );
          },
        ),
        TextButton(
          child: const Text('اغلاق'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
    return TextButton(
      child: _isLoading
          ? const CircularProgressIndicator()
          : const Text('اٍتمام الطلب'),
      onPressed: (widget.cart.totalAmount <= 0 || _isLoading)
          ? null
          : isAuth
              ? () => showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text(
                        'تأكيد الطلب',
                        textAlign: TextAlign.center,
                      ),
                      contentTextStyle: const TextStyle(fontSize: 18),
                      content: Container(
                        padding: const EdgeInsets.all(8),
                        child: const Text('''
                            عند الضغط على موافق فأنك تقوم بطلب المنتج وسيتم اعطائه لشركة التوصيل ولا يمكن التراجع عن هذا الطلب بعد ذلك، فهل انت متأكد من طلبك؛ مع ملاحظة ان تطبيق (اسم التطبيق) يجمع لك اكثر من متجر بتطبيق واحد، فهذا يعني انك اذا طلبت منتجات من اكثر من تصنيفين مختلفين فهذا يجعل اجور التوصيل × ٢، لان كل منتج يطلب من متجر مختلف؛ اجور التوصيل داخل بغداد من الفين الى خمسة الاف دينار، 
                            عند الضغط على تنفيذ الطلب سيتم افراغ محتويات العربة ويمكنك مراجعة طلباتك من خلال حسابي -> سجل الطلبات
                          ''', textAlign: TextAlign.right),
                      ),
                      actionsAlignment: MainAxisAlignment.start,
                      actions: [
                        TextButton(
                          child: const Text('تنفيذ الطلب'),
                          onPressed: () async {
                            Navigator.of(context).pop();
                            setState(() {
                              _isLoading = true;
                            });
                            await Provider.of<Orders>(context, listen: false)
                                .addOrder(
                              widget.cart.items.values.toList(),
                              widget.cart.totalAmount,
                            );
                            setState(() {
                              _isLoading = false;
                            });
                            widget.cart.clear();
                          },
                        ),
                        TextButton(
                          child: const Text('اغلاق'),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    ),
                  )
              : () => showDialog(
                    context: context,
                    builder: (ctx) => _dialog,
                  ),
      style: ButtonStyle(
          foregroundColor: MaterialStateProperty.all<Color>(
        Theme.of(context).primaryColor,
      )),
    );
  }
}
