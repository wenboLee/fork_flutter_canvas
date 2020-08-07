import 'package:flutter/material.dart';
import 'package:flutter_canvas/pages/anim/anim01.dart';
import 'package:flutter_canvas/pages/anim/anim02.dart';
import 'package:flutter_canvas/pages/anim/anim03.dart';
import 'package:flutter_canvas/pages/anim/anim04.dart';
import 'package:flutter_canvas/pages/anim/anim05.dart';
import 'package:flutter_canvas/pages/anim/anim06.dart';
import 'package:flutter_canvas/pages/anim/anim07.dart';
import 'package:flutter_canvas/pages/anim/anim08.dart';
import 'package:flutter_canvas/pages/anim/anim09.dart';
import 'package:flutter_canvas/pages/anim/anim10.dart';
import 'package:flutter_canvas/pages/debug/main.dart';
import 'package:flutter_canvas/pages/main.dart';

///路由表url名称
class RouteConstant {
  static const String DebugMainPage = '/';
  static const String MainPage = '/main';
  static const String Anim01Page = '/anim01Page';
  static const String Anim02Page = '/anim02Page';
  static const String Anim03Page = '/anim03Page';
  static const String Anim04Page = '/anim04Page';
  static const String Anim05Page = '/anim05Page';
  static const String Anim06Page = '/anim06Page';
  static const String Anim07Page = '/anim07Page';
  static const String Anim08Page = '/anim08Page';
  static const String Anim09Page = '/anim09Page';
  static const String Anim10Page = '/anim10Page';
}

///通过 routeName名称 返回 Widget的名称
String routeWidgetName(String routeName) {
  var defaultRouteName = 'MainPage';
  var map = {
    RouteConstant.DebugMainPage: 'DebugMainPage',
    RouteConstant.MainPage: 'MainPage',
    RouteConstant.Anim01Page: 'Anim01Page',
    RouteConstant.Anim02Page: 'Anim02Page',
    RouteConstant.Anim03Page: 'Anim03Page',
    RouteConstant.Anim04Page: 'Anim04Page',
    RouteConstant.Anim05Page: 'Anim05Page',
    RouteConstant.Anim06Page: 'Anim06Page',
    RouteConstant.Anim07Page: 'Anim07Page',
    RouteConstant.Anim08Page: 'Anim08Page',
    RouteConstant.Anim09Page: 'Anim09Page',
    RouteConstant.Anim10Page: 'Anim10Page',
  };
  return map.containsKey(routeName) ? map[routeName] : defaultRouteName;
}

///路由表  部分title不是页面需要，但是必填是为了直观查看
Map<String, WidgetBuilder> routes(BuildContext context) {
  return {
    RouteConstant.MainPage: (context) => MainPage(title: 'main'),
    RouteConstant.DebugMainPage: (context) => DebugMainPage(title: 'debug'),
    RouteConstant.Anim01Page: (context) => Anim01Page(title: '任意方向上的加速度'),
    RouteConstant.Anim02Page: (context) => Anim02Page(title: '单轴加速度'),
    RouteConstant.Anim03Page: (context) => Anim03Page(title: '单轴运动'),
    RouteConstant.Anim04Page: (context) => Anim04Page(title: '圆周运动'),
    RouteConstant.Anim05Page: (context) => Anim05Page(title: '小球的掉落'),
    RouteConstant.Anim06Page: (context) => Anim06Page(title: '平滑运动'),
    RouteConstant.Anim07Page: (context) => Anim07Page(title: '椭圆运动'),
    RouteConstant.Anim08Page: (context) => Anim08Page(title: '箭头旋转运动'),
    RouteConstant.Anim09Page: (context) => Anim09Page(title: '箭头跟随手指运动'),
    RouteConstant.Anim10Page: (context) => Anim10Page(title: '线性运动'),
  };
}
