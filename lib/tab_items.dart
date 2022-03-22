import 'package:flutter/material.dart';

enum TabItem { one, two, three, four }

const Map<TabItem, String> tabName = {
  TabItem.one: 'الرئيسية',
  TabItem.two: 'عربة التسوق',
  TabItem.three: 'المفضلة',
  TabItem.four: 'حسابي',
};

const Map<TabItem, MaterialColor> activeTabColor = {
  TabItem.one: Colors.red,
  TabItem.two: Colors.blue,
  TabItem.three: Colors.purple,
  TabItem.four: Colors.green,
};