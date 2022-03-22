import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rating_dialog/rating_dialog.dart';
import 'package:shop/screens/edit_user_screen.dart';
import 'package:store_redirect/store_redirect.dart';

import '../providers/auth.dart';
import '../screens/auth_screen.dart';
import '../screens/orders_screen.dart';

class Account extends StatefulWidget {
  const Account({Key? key}) : super(key: key);

  @override
  _AccountState createState() => _AccountState();
}

class _AccountState extends State<Account> {
  final _dialog = RatingDialog(
    // your app's name?
    title: const Text(
      'تقييم التطبيق على المتجر',
      textAlign: TextAlign.center,
    ),
    // encourage your user to leave a high rating?
    message: const Text(
      'اختر من ١ الى ٥ نجوم لتقييم التطبيق',
      textAlign: TextAlign.center,
    ),
    // your app's logo?
    image: const FlutterLogo(size: 60),
    commentHint: 'اضف تعليقك هنا',
    submitButtonText: 'أرسال',
    //onCancelled: () => print('cancelled'),
    onSubmitted: (response) {
      log('rating: ${response.rating}, comment: ${response.comment}');

      if (response.rating < 3.0) {
        // send their comments to your email or anywhere you wish
        // ask the user to contact you instead of leaving a bad review
      } else {
        //go to app store
        StoreRedirect.redirect(
            androidAppId: 'shri.complete.fitness.gymtrainingapp',
            iOSAppId: 'com.example.rating');
      }
    },
  );

  @override
  Widget build(BuildContext context) {
    bool isAuth = Provider.of<Auth>(context, listen: true).isAuth;
    String? name = Provider.of<Auth>(context, listen: true).name;

    return ListView(
      children: [
        const SizedBox(height: 20),
        mListTile(
          context,
          Icons.person_outline,
          isAuth ? name! : 'تسجيل الدخول',
          onTap: isAuth
              ? null
              : () => Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (ctx) => const AuthScreen(),
                    ),
                  ),
        ),
        mListTile(
          context,
          Icons.person_pin_outlined,
          'تعديل معلوماتك',
          onTap: isAuth
              ? () => Navigator.of(context).pushNamed(
                    EditUserScreen.routeName,
                    // arguments: id,
                  )
              : null,
        ),
        mListTile(
          context,
          Icons.access_time_rounded,
          'سجل الطلبات',
          onTap: isAuth
              ? () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (ctx) => const OrderScreen(),
                    ),
                  )
              : null,
        ),
        mListTile(
          context,
          Icons.star_border_outlined,
          'تقييم التطبيق',
          onTap: () {
            showDialog(
              context: context,
              builder: (context) => _dialog,
            );
          },
        ),
        mListTile(
          context,
          Icons.exit_to_app_outlined,
          'تسجيل الخروج',
          onTap: isAuth
              ? () async {
                  await Provider.of<Auth>(context, listen: false).logout();
                  Navigator.of(context).pop();
                  Navigator.of(context).pushNamed('/');
                }
              : null,
        ),
        mListTile(
          context,
          Icons.no_accounts,
          'حذف الحساب',
          onTap: isAuth
              ? () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('تحذير', textAlign: TextAlign.center),
                      content: const Text(
                        'انت الان تحاول حذف حسابك نهائيا، هل انت متأكد؟',
                        textAlign: TextAlign.center,
                      ),
                      actionsAlignment: MainAxisAlignment.start,
                      actions: [
                        TextButton(
                            child: const Text('تأكيد الحذف'),
                            onPressed: () {
                              Provider.of<Auth>(context, listen: false)
                                  .delete();
                              Navigator.of(ctx).pop();
                              Navigator.of(ctx).pushNamed('/');
                            }),
                        TextButton(
                          child: const Text('تراجع'),
                          onPressed: () => Navigator.of(ctx).pop(),
                        ),
                      ],
                    ),
                  );
                }
              : null,
        ),
        const ExpansionTile(
          leading: Icon(Icons.info_outline_rounded, size: 33),
          title: Text(
            'عن التطبيق',
            style: TextStyle(fontSize: 26),
          ),
          children: [
            Padding(
              padding: EdgeInsets.all(12.0),
              child: Text(
                'موبايل بوينت : موقع تجارة الكترونية رائد في مجال التسوق عن بعد ، يقدم الموقع أفضل العلامات التجارية العالمية. اصبح بأمكانك الان شراء منتجات مضمونة وعالية الجودة ومن الموردين موثوقين في الارد ومنتشرين حول العالم، براحة تامة من جهازك المحمول. من خلال موبايل بوينت اصبح بأمكانك ايجاد مجموعة واسعة ووفيرة للغاية من المنتجات التي يمتد نطاقها من الأزياء ومستلزمات المنزل والصحة والأجهزة التكنولوجية والألعاب حتى المستلزمات الرياضية والاكسسوارات المختلفة موبايل بوينت يقدم خدمة البحث / تصفح المنتج ، والمراجعة ، مشتريات ، الدفع عبر الإنترنت الدفع النقدي عند التسليم ، والاستفسار عن الطلب ، وتتبع الخدمات اللوجستية ، والصور / التقييم ، وما إلى ذلك من الخدمات. نحن ملتزمون بضمان أعلى معايير الجودة في الخدمة والبضائع من اجل انشاء نمط حياة جديد وبسيط وسعيد لك.',
                style: TextStyle(fontSize: 26),
                textAlign: TextAlign.justify,
              ),
            ),
          ],
        ),
      ],
    );
  }

  ListTile mListTile(BuildContext context, IconData? icon, String data,
      {Function()? onTap}) {
    return ListTile(
      iconColor: data == 'حذف الحساب' ? Colors.red : null,
      textColor: data == 'حذف الحساب' ? Colors.red : null,
      focusColor: data == 'حذف الحساب' ? Colors.red : null,
      hoverColor: data == 'حذف الحساب' ? Colors.red : null,
      selectedColor: data == 'حذف الحساب' ? Colors.red : null,
      selectedTileColor: data == 'حذف الحساب' ? Colors.red : null,
      leading: Icon(icon, size: 33),
      title: Text(
        data,
        style: TextStyle(
          fontSize: 26,
          color: onTap == null
              ? Theme.of(context).colorScheme.brightness == Brightness.dark
                  ? Colors.white.withOpacity(0.5)
                  : Colors.black.withOpacity(0.5)
              : null,
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios),
      onTap: onTap,
      // element['title'] == 'سجل الطلبات'
      //     ? Navigator.pushNamed(context, (element['page'] as String))
      //     : Navigator.push(context, MaterialPageRoute(builder: (context) {
      //         return element['page'];
      //       }));
    );
  }
}
