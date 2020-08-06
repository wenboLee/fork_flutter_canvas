import 'package:flutter/material.dart';
import 'package:flutter_canvas/pages/anim/anim01.dart';
import 'package:flutter_canvas/pages/anim/anim02.dart';
import 'package:flutter_canvas/pages/anim/anim03.dart';
import 'package:flutter_canvas/pages/anim/anim04.dart';
import 'package:flutter_canvas/pages/debug/main.dart';
import 'package:flutter_canvas/pages/main.dart';

///路由表url名称
class RouteConstant {
  static const String DebugMainPage = '/';
  static const String MainPage = '/main';
  static const String Anim0101Page = '/anim0101Page';
  static const String Anim0102Page = '/anim0102Page';
  static const String Anim0103Page = '/anim0103Page';
  static const String Anim0104Page = '/anim0104Page';
}

///通过 routeName名称 返回 Widget的名称
String routeWidgetName(String routeName) {
  var defaultRouteName = 'MainPage';
  var map = {
    RouteConstant.DebugMainPage: 'DebugMainPage',
    RouteConstant.MainPage: 'MainPage',
    RouteConstant.Anim0101Page: 'Anim0101Page',
    RouteConstant.Anim0102Page: 'Anim0102Page',
    RouteConstant.Anim0103Page: 'Anim0103Page',
    RouteConstant.Anim0104Page: 'Anim0104Page',
  };
  return map.containsKey(routeName) ? map[routeName] : defaultRouteName;
}

///路由表  部分title不是页面需要，但是必填是为了直观查看
Map<String, WidgetBuilder> routes(BuildContext context) {
  return {
    RouteConstant.MainPage: (context) => MainPage(title: 'main'),
    RouteConstant.DebugMainPage: (context) => DebugMainPage(title: 'debug-route'),
    RouteConstant.Anim0101Page: (context) => Anim01Page(title: '任意方向上的加速度'),
    RouteConstant.Anim0102Page: (context) => Anim02Page(title: '单轴加速度'),
    RouteConstant.Anim0103Page: (context) => Anim03Page(title: '单轴运动'),
    RouteConstant.Anim0104Page: (context) => Anim04Page(title: '圆周运动'),
  };
}
