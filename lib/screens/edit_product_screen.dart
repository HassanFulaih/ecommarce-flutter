import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/custom_dropdown.dart';

import '../providers/product.dart';
import '../providers/products.dart';

class EditProductScreen extends StatefulWidget {
  static const routeName = '/edit_product';

  const EditProductScreen({Key? key}) : super(key: key);

  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _priceFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _imageUrlController = TextEditingController();
  final _imageUrlFocusNode = FocusNode();
  final _formKey = GlobalKey<FormState>();
  String _selectedCategory = 'أدوية';
  List<String> categoryList = ['أدوية', 'مواد طبية', 'مواد تجميلية'];

  Product _editedProduct = Product(
    id: '',
    title: '',
    category: '',
    description: '',
    price: 0,
    imageUrl: '',
  );
  var _initialValues = {
    'title': '',
    'description': '',
    'price': '',
    'imageUrl': '',
  };
  var _isInit = true;
  var _isLoading = false;

  @override
  void initState() {
    super.initState();
    _imageUrlFocusNode.addListener(_updateImageUrl);
  }

  @override
  didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      final String? productId =
          ModalRoute.of(context)!.settings.arguments as String?;
      if (productId != null) {
        _editedProduct =
            Provider.of<Products>(context, listen: false).findById(productId);
        _initialValues = {
          'title': _editedProduct.title,
          'description': _editedProduct.description,
          'price': _editedProduct.price.toString(),
          'imageUrl': '',
        };
        _selectedCategory = _editedProduct.category;
        _imageUrlController.text = _editedProduct.imageUrl;
      }
      _isInit = false;
    }
  }

  @override
  void dispose() {
    super.dispose();
    _imageUrlFocusNode.removeListener(_updateImageUrl);
    _priceFocusNode.dispose();
    _imageUrlFocusNode.dispose();
    _imageUrlController.dispose();
    _descriptionFocusNode.dispose();
  }

  void _updateImageUrl() {
    if (!_imageUrlFocusNode.hasFocus) {
      if ((!_imageUrlController.text.startsWith('http') &&
              !_imageUrlController.text.startsWith('https')) ||
          (!_imageUrlController.text.endsWith('.png') &&
              !_imageUrlController.text.endsWith('.jpg') &&
              !_imageUrlController.text.endsWith('.jpeg'))) {
        return;
      }
      setState(() {});
    }
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
    if (_editedProduct.id.isNotEmpty) {
      await Provider.of<Products>(context, listen: false)
          .updateProduct(_editedProduct.id, _editedProduct);
    } else {
      try {
        await Provider.of<Products>(context, listen: false)
            .addProduct(_editedProduct);
      } catch (e) {
        log('Error: $e');
        await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('An error occurred!'),
            content: const Text('Something went wrong.'),
            actions: [
              TextButton(
                child: const Text('Okay!'),
                onPressed: () => Navigator.of(ctx).pop(),
              ),
            ],
          ),
        );
      }
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
          title: const Text('تعديل أو أضافة منتج'),
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
                        initialValue: _initialValues['title'],
                        decoration: const InputDecoration(labelText: 'العنوان'),
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (_) {
                          FocusScope.of(context).requestFocus(_priceFocusNode);
                        },
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'رجاءََ أدخل العنوان';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _editedProduct = Product(
                            id: _editedProduct.id,
                            price: _editedProduct.price,
                            title: value!,
                            category: _selectedCategory,
                            description: _editedProduct.description,
                            imageUrl: _editedProduct.imageUrl,
                            isFavorite: _editedProduct.isFavorite,
                          );
                        },
                      ),
                      TextFormField(
                        initialValue: _initialValues['price'],
                        decoration: const InputDecoration(labelText: 'السعر'),
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.number,
                        focusNode: _priceFocusNode,
                        onFieldSubmitted: (_) {
                          FocusScope.of(context)
                              .requestFocus(_descriptionFocusNode);
                        },
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'رجاءََ أدخل السعر';
                          }
                          if (double.tryParse(value) == null) {
                            return 'رجاءََ أدخل رقم صحيح';
                          }
                          if (double.parse(value) <= 0) {
                            return 'رجاءََ أدخل رقم أكبر من صفر';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _editedProduct = Product(
                            id: _editedProduct.id,
                            price: double.parse(value!),
                            title: _editedProduct.title,
                            category: _selectedCategory,
                            description: _editedProduct.description,
                            imageUrl: _editedProduct.imageUrl,
                            isFavorite: _editedProduct.isFavorite,
                          );
                        },
                      ),
                      TextFormField(
                        initialValue: _initialValues['description'],
                        decoration: const InputDecoration(labelText: 'الوصف'),
                        maxLines: 3,
                        keyboardType: TextInputType.multiline,
                        focusNode: _descriptionFocusNode,
                        // validator: (value) {
                        //   if (value!.isEmpty) {
                        //     return 'رجاءَ أدخل الوصف';
                        //   }
                        //   if (value.length < 10) {
                        //     return 'يجب أن يكون الوصف أكثر من 10 حروف';
                        //   }
                        //   return null;
                        // },
                        onSaved: (value) {
                          _editedProduct = Product(
                            id: _editedProduct.id,
                            price: _editedProduct.price,
                            title: _editedProduct.title,
                            category: _selectedCategory,
                            description: value??'',
                            imageUrl: _editedProduct.imageUrl,
                            isFavorite: _editedProduct.isFavorite,
                          );
                        },
                      ),
                      const SizedBox(height: 10),
                      CustomDropdown(
                        categoryList,
                        (String? newValue) {
                          setState(() {
                            _selectedCategory = newValue!;
                          });
                        },
                        _selectedCategory,
                        title: 'الفئة',
                      ),
                      const SizedBox(height: 10),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            margin: const EdgeInsets.only(top: 8, right: 10),
                            decoration: BoxDecoration(
                              border: Border.all(width: 1, color: Colors.grey),
                            ),
                            child: _imageUrlController.text.isEmpty
                                ? const Center(child: Text('أدخل رابط الصورة'))
                                : FittedBox(
                                    child: Image.network(
                                      _imageUrlController.text,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextFormField(
                              controller: _imageUrlController,
                              decoration: const InputDecoration(
                                labelText: 'رابط الصورة',
                              ),
                              keyboardType: TextInputType.url,
                              focusNode: _imageUrlFocusNode,
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'رجاءَ أدخل رابط الصورة';
                                }
                                if (!value.startsWith('http') &&
                                    !value.startsWith('https')) {
                                  return 'رجاءَ أدخل رابط صحيح';
                                }
                                if (!value.endsWith('png') &&
                                    !value.endsWith('jpg') &&
                                    !value.endsWith('jpeg')) {
                                  return 'رجاءَ أدخل رابط الصورة بصيغة صحيحة';
                                }
                                return null;
                              },
                              onSaved: (value) {
                                _editedProduct = Product(
                                  id: _editedProduct.id,
                                  price: _editedProduct.price,
                                  title: _editedProduct.title,
                                  category: _selectedCategory,
                                  description: _editedProduct.description,
                                  imageUrl: value!,
                                  isFavorite: _editedProduct.isFavorite,
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
