import 'dart:developer' as developer;
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/http_exception.dart';
import '../providers/auth.dart';
import '../tabs.dart';
import '../widgets/custom_dropdown.dart';

class AuthScreen extends StatelessWidget {
  static const routeName = '/auth';

  const AuthScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;

    return Scaffold(
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    // const Color.fromRGBO(215, 117, 255, 1).withOpacity(0.5),
                    // const Color.fromRGBO(255, 188, 117, 1).withOpacity(0.9),

                    Color(0xFF1D1E33),
                    Color(0xFFedf0ef),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  stops: [0, 1],
                ),
              ),
            ),
            SingleChildScrollView(
              child: SizedBox(
                height: deviceSize.height,
                width: deviceSize.width,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Flexible(
                      flex: 4,
                      child: AnimatedContainer(
                        //margin: const EdgeInsets.only(bottom: 20),
                        padding: const EdgeInsets.symmetric(
                            vertical: 4, horizontal: 12),
                        transform: Matrix4.rotationZ(-7 * pi / 180)
                          ..translate(-10.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.teal[300],
                          boxShadow: const [
                            BoxShadow(
                              blurRadius: 8,
                              color: Colors.black26,
                              offset: Offset(0, 2),
                            )
                          ],
                        ),
                        duration: const Duration(seconds: 1),
                        child: Text(
                          '???????????? ????????????????????',
                          style: TextStyle(
                            color: Colors.grey[50],
                            fontSize: 40,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Flexible(
                      flex: deviceSize.width > 600 ? 6 : 7,
                      child: const AuthCard(),
                    ),
                    const SizedBox(height: 8),
                    Flexible(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (ctx) => const HomePage(),
                            ),
                          );
                        },
                        child: const Text(
                          '?????????????????? ?????????????? ??????????',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AuthCard extends StatefulWidget {
  const AuthCard({Key? key}) : super(key: key);

  @override
  _AuthCardState createState() => _AuthCardState();
}

enum AuthMode { Login, SignUp }

class _AuthCardState extends State<AuthCard>
    with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey();
  AuthMode _authMode = AuthMode.Login;

  final Map<String, String> _authData = {
    'name': '',
    'phone_number': '',
    'governorate': '??????????',
    'region': '',
    'password': '',
  };

  var _isLoading = false;

  final _paswordController = TextEditingController();
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _opacityAnimation;

  List<String> governorateList = [
    '??????????',
    '??????????????',
    '????????',
    '??????????',
    '????????????',
    '????????',
    '??????????',
    '???? ??????',
    '????????????????????',
    '???????? ??????????',
    '????????????????',
    '????????????',
    '??????????',
    '??????????',
    '????????????',
    '??????????',
    '??????????',
    '????????',
  ];

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.15),
      end: const Offset(0, 0),
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.fastOutSlowIn,
      ),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
    _paswordController.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    FocusScope.of(context).unfocus();
    _formKey.currentState!.save();
    setState(() => _isLoading = true);
    try {
      if (_authMode == AuthMode.Login) {
        await Provider.of<Auth>(context, listen: false)
            .login(_authData['phone_number']!, _authData['password']!);
        // await Provider.of<Auth>(context, listen: false)
        //     .displayToken();
      } else {
        await Provider.of<Auth>(context, listen: false).signUp(
          _authData['name']!,
          _authData['phone_number']!,
          _authData['governorate']!,
          _authData['region']!,
          _authData['password']!,
        );
      }

      // Navigator.of(context).pushReplacement(
      //   MaterialPageRoute(
      //     builder: (ctx) => const HomePage(),
      //   ),
      // );
    } on HttpException catch (error) {
      developer.log(error.toString());
      var errorMessage = '?????? ???????? ????????????????';
      if (error.toString().contains('The phone number field is required.')) {
        errorMessage = '?????? ?????????? ???????????? ??????????';
      }

      if (error.toString().contains('phone-number not found!')) {
        errorMessage = '?????? ???????????? ???????????? ???? ??????';
      } else if (error.toString().contains('INVALID_EMAIL')) {
        errorMessage = '?????? ???????????? ???????????????????? ?????? ????????';
      } else if (error.toString().contains('WEAK_PASSWORD')) {
        errorMessage = '???????? ???????????? ?????????? ??????';
      } else if (error.toString().contains('EMAIL_NOT_FOUND')) {
        errorMessage = '?????? ???????????? ???????????????????? ?????? ????????';
      } else if (error.toString().contains('Password does not exist!')) {
        errorMessage = '???????? ???????????? ?????? ??????????';
      }
      _showErrorDialog(errorMessage);
      rethrow;
    } catch (error) {
      developer.log('Error: $error');
      const errorMessage = '?????? ???????? ???????????????? ?? ???????? ???????????????? ?????? ????????';
      _showErrorDialog(errorMessage);
      rethrow;
    }
    setState(() => _isLoading = false);
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('???????? ?????? ????', textAlign: TextAlign.center),
        content: Text(message, textAlign: TextAlign.center),
        actionsAlignment: MainAxisAlignment.start,
        actions: [
          TextButton(
            child: const Text('??????????'),
            onPressed: () => Navigator.of(ctx).pop(),
          )
        ],
      ),
    );
  }

  void _switchAuthMode() {
    if (_authMode == AuthMode.Login) {
      setState(() {
        _authMode = AuthMode.SignUp;
      });
      _controller.forward();
    } else {
      setState(() {
        _authMode = AuthMode.Login;
      });
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    final isLandScape = deviceSize.width > deviceSize.height;
    return Card(
      color: const Color(0xFF1d232f),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 8.0,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
        height: _authMode == AuthMode.SignUp ? 360 : 270,
        constraints:
            BoxConstraints(minHeight: _authMode == AuthMode.SignUp ? 570 : 270),
        width: deviceSize.width * 0.85,
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                if (_authMode == AuthMode.SignUp)
                  TextFormField(
                    key: const ValueKey('name'),
                    decoration: const InputDecoration(
                      labelText: '?????????? ???????????? ???????????? ??????????????',
                      labelStyle: TextStyle(color: Colors.white70),
                    ),
                    style: const TextStyle(color: Colors.white),
                    keyboardType: TextInputType.text,
                    validator: (val) {
                      if (val!.isEmpty || val.length < 7)
                        return '?????????? ?????? ????????';
                      return null;
                    },
                    onSaved: (val) {
                      _authData['name'] = val!;
                    },
                  ),
                TextFormField(
                  key: const ValueKey('phone_number'),
                  textDirection: TextDirection.ltr,
                  decoration: const InputDecoration(
                    labelText: '?????? ????????????',
                    labelStyle: TextStyle(color: Colors.white70),
                  ),
                  style: const TextStyle(color: Colors.white),
                  keyboardType: TextInputType.phone,
                  validator: (val) {
                    if (val!.isEmpty ||
                        !val.startsWith('07') ||
                        val.length != 11) {
                      return '?????????? ?????? ???????????? ?????? ????????';
                    }
                    return null;
                  },
                  onSaved: (val) {
                    _authData['phone_number'] = val!;
                  },
                ),
                if (_authMode == AuthMode.SignUp)
                  CustomDropdown(
                    governorateList,
                    (String? newValue) {
                      setState(() {
                        _authData['governorate'] = newValue!;
                      });
                    },
                    _authData['governorate']!,
                    title: '???????????????? - ?????????????? ?????????? ???????? ?????? ???????????? ??????????',
                  ),
                if (_authMode == AuthMode.SignUp)
                  TextFormField(
                    key: const ValueKey('region'),
                    decoration: const InputDecoration(
                      labelText: '?????????????? ???????????? ???????????? ??????????????',
                      labelStyle: TextStyle(color: Colors.white70),
                    ),
                    style: const TextStyle(color: Colors.white),
                    keyboardType: TextInputType.text,
                    validator: (val) {
                      if (val!.isEmpty || val.length < 7)
                        return '?????????????? ?????? ????????';
                      return null;
                    },
                    onSaved: (val) {
                      _authData['region'] = val!;
                    },
                  ),
                TextFormField(
                  key: const ValueKey('password'),
                  textDirection: TextDirection.ltr,
                  decoration: const InputDecoration(
                    labelText: '?????????? ??????????',
                    labelStyle: TextStyle(color: Colors.white70),
                  ),
                  style: const TextStyle(color: Colors.white),
                  obscureText: true,
                  controller: _paswordController,
                  validator: (val) {
                    if (val!.isEmpty || val.length < 6) {
                      return '?????????? ?????????? ?????? ????????';
                    }
                    return null;
                  },
                  onSaved: (val) {
                    _authData['password'] = val!;
                  },
                ),
                AnimatedContainer(
                  constraints: BoxConstraints(
                    minHeight: _authMode == AuthMode.SignUp ? 20 : 0,
                    maxHeight: _authMode == AuthMode.SignUp ? 50 : 0,
                  ),
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeIn,
                  child: FadeTransition(
                    opacity: _opacityAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: TextFormField(
                        textDirection: TextDirection.ltr,
                        enabled: _authMode == AuthMode.SignUp,
                        decoration: const InputDecoration(
                          labelText: '?????????? ?????????? ??????????',
                          labelStyle: TextStyle(color: Colors.white70),
                        ),
                        style: const TextStyle(color: Colors.white),
                        obscureText: true,
                        validator: _authMode == AuthMode.SignUp
                            ? (val) {
                                if (val != _paswordController.text) {
                                  return '?????????? ?????? ????????????';
                                }
                                return null;
                              }
                            : null,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                if (_isLoading) const CircularProgressIndicator(),
                Wrap(
                  direction: isLandScape ? Axis.horizontal : Axis.vertical,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    ElevatedButton(
                      style: ButtonStyle(
                        shape: MaterialStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        padding: MaterialStateProperty.all(
                          const EdgeInsets.symmetric(
                              horizontal: 30, vertical: 8),
                        ),
                        backgroundColor: MaterialStateProperty.all(
                          Colors.teal,
                        ),
                        foregroundColor: MaterialStateProperty.all(
                          Colors.white,
                        ),
                      ),
                      child: Text(_authMode == AuthMode.Login
                          ? '?????????? ????????????'
                          : '?????????? ???????? ????????'),
                      onPressed: _submit,
                    ),
                    TextButton(
                      child: Text(
                        '${_authMode == AuthMode.Login ? '?????????? ???????? ????????' : '?????????? ????????????'} ???????? ???? ??????',
                        style: const TextStyle(
                          fontSize: 19,
                        ),
                      ),
                      onPressed: _switchAuthMode,
                      style: ButtonStyle(
                        padding: MaterialStateProperty.all(
                          const EdgeInsets.symmetric(
                              horizontal: 30, vertical: 4),
                        ),
                        foregroundColor: MaterialStateProperty.all(
                          Colors.blue[100],
                        ),
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
