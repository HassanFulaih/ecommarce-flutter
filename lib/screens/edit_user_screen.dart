import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth.dart';
import '../widgets/custom_dropdown.dart';

class EditUserScreen extends StatefulWidget {
  static const routeName = '/edit_user';

  const EditUserScreen({Key? key}) : super(key: key);

  @override
  _EditUserScreenState createState() => _EditUserScreenState();
}

class _EditUserScreenState extends State<EditUserScreen> {
  final _phoneNumberFocusNode = FocusNode();
  final _regionFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();
  final _paswordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  List<String> governorateList = [
    'أربيل',
    'الأنبار',
    'بابل',
    'بغداد',
    'البصرة',
    'دهوك',
    'ديالى',
    'ذي قار',
    'السليمانية',
    'صلاح الدين',
    'القادسية',
    'كربلاء',
    'كركوك',
    'ميسان',
    'المثنى',
    'النجف',
    'نينوى',
    'واسط',
  ];

  Map<String, String> _authData = {
    'name': '',
    'phone_number': '',
    'governorate': 'بغداد',
    'region': '',
    'password': '',
    'password_confirmation': '',
  };

  var _isInit = true;
  var _isLoading = false;

  @override
  didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      final auth = Provider.of<Auth>(context, listen: false);

      _authData = {
        'name': auth.name!,
        'phone_number': auth.phoneNumber!,
        'governorate': auth.governorate!,
        'region': auth.region!,
      };
      _isInit = false;
    }
  }

  @override
  void dispose() {
    super.dispose();
    _phoneNumberFocusNode.dispose();
    _regionFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    _paswordController.dispose();
  }

  Future<void> _saveForm() async {
    final isValid = _formKey.currentState!.validate();
    if (!isValid) {
      return;
    }
    _formKey.currentState!.save();
    setState(() {
      _isLoading = true;
    });
    try {
      await Provider.of<Auth>(context, listen: false).update(
        _authData['name']!,
        _authData['phone_number']!,
        _authData['governorate']!,
        _authData['region']!,
        _authData['password']!,
        _authData['password_confirmation']!,
      );
    } catch (e) {
      log('Error: $e');
      await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('خطأ'),
          content: const Text('حدث خطأ ما'),
          actionsAlignment: MainAxisAlignment.start,
          actions: [
            TextButton(
              child: const Text('موافق'),
              onPressed: () => Navigator.of(ctx).pop(),
            ),
          ],
        ),
      );
    }

    setState(() {
      _isLoading = false;
    });
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF1D1E33),
          elevation: 0,
          title: const Text('تعديل معلومات حسابك'),
          actions: [
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _saveForm,
            )
          ],
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    children: [
                      TextFormField(
                        key: const ValueKey('name'),
                        initialValue: _authData['name'],
                        decoration: const InputDecoration(labelText: 'الاسم'),
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (_) {
                          FocusScope.of(context)
                              .requestFocus(_phoneNumberFocusNode);
                        },
                        validator: (value) {
                          if (value!.isEmpty || value.length < 7)
                            return 'الاسم جدا قصير';
                          return null;
                        },
                        onSaved: (val) {
                          _authData['name'] = val!;
                        },
                      ),
                      TextFormField(
                        textDirection: TextDirection.ltr,
                        key: const ValueKey('phone_number'),
                        initialValue: _authData['phone_number'],
                        decoration:
                            const InputDecoration(labelText: 'رقم الهاتف'),
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.phone,
                        focusNode: _phoneNumberFocusNode,
                        onFieldSubmitted: (_) {
                          FocusScope.of(context).requestFocus(_regionFocusNode);
                        },
                        validator: (val) {
                          if (val!.isEmpty ||
                              !val.startsWith('07') ||
                              val.length != 11) {
                            return 'تنسيق رقم الهاتف غير صحيح';
                          }
                          return null;
                        },
                        onSaved: (val) {
                          _authData['phone_number'] = val!;
                        },
                      ),
                      CustomDropdown(
                        governorateList,
                        (String? newValue) {
                          setState(() {
                            _authData['governorate'] = newValue!;
                          });
                        },
                        _authData['governorate']!,
                        title: 'المحافظة - التطبيق حاليا يدعم فقط محافظة بغداد',
                      ),
                      TextFormField(
                        key: const ValueKey('region'),
                        initialValue: _authData['region'],
                        decoration: const InputDecoration(labelText: 'العنوان'),
                        keyboardType: TextInputType.text,
                        focusNode: _regionFocusNode,
                        onFieldSubmitted: (_) {
                          FocusScope.of(context)
                              .requestFocus(_passwordFocusNode);
                        },
                        validator: (val) {
                          if (val!.isEmpty || val.length < 7)
                            return 'العنوان جدا قصير';
                          return null;
                        },
                        onSaved: (val) {
                          _authData['region'] = val!;
                        },
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        key: const ValueKey('password'),
                        decoration:
                            const InputDecoration(labelText: 'الرمز السري'),
                        obscureText: true,
                        keyboardType: TextInputType.text,
                        controller: _paswordController,
                        focusNode: _passwordFocusNode,
                        onFieldSubmitted: (_) {
                          FocusScope.of(context)
                              .requestFocus(_confirmPasswordFocusNode);
                        },
                        validator: (val) {
                          if (val!.isEmpty || val.length < 6) {
                            return 'الرمز السري جدا قصير';
                          }
                          return null;
                        },
                        onSaved: (val) {
                          _authData['password'] = val!;
                        },
                      ),
                      TextFormField(
                        key: const ValueKey('password_confirmation'),
                        decoration: const InputDecoration(
                            labelText: 'تأكيد الرمز السري'),
                        keyboardType: TextInputType.text,
                        focusNode: _confirmPasswordFocusNode,
                        obscureText: true,
                        validator: (val) {
                          if (val != _paswordController.text) {
                            return 'الرمز غير متطابق';
                          }
                          return null;
                        },
                        onSaved: (val) {
                          _authData['password_confirmation'] = val!;
                        },
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
