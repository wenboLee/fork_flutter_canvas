import 'package:flutter/material.dart';
import 'package:flutter_canvas/pages/anim01/anim0101.dart';
import 'package:flutter_canvas/pages/anim01/anim0102.dart';
import 'package:flutter_canvas/pages/debug/main.dart';
import 'package:flutter_canvas/pages/main.dart';

///路由表url名称
class RouteConstant {
  static const String DebugMainPage = '/';
  static const String MainPage = '/main';
  static const String Anim0101Page = '/anim0101Page';
  static const String Anim0102Page = '/anim0102Page';
}

///通过 routeName名称 返回 Widget的名称
String routeWidgetName(String routeName) {
  var defaultRouteName = 'MainPage';
  var map = {
    RouteConstant.DebugMainPage: 'DebugMainPage',
    RouteConstant.MainPage: 'MainPage',
    RouteConstant.Anim0101Page: 'Anim0101Page',
    RouteConstant.Anim0102Page: 'Anim0102Page',
  };
  return map.containsKey(routeName) ? map[routeName] : defaultRouteName;
}

///路由表  部分title不是页面需要，但是必填是为了直观查看
Map<String, WidgetBuilder> routes(BuildContext context) {
  return {
    RouteConstant.MainPage: (context) => MainPage(title: 'main'),
    RouteConstant.DebugMainPage: (context) => DebugMainPage(title: 'debug-route'),
    RouteConstant.Anim0101Page: (context) => Anim0101Page(title: '任意方向上的加速度'),
    RouteConstant.Anim0102Page: (context) => Anim0102Page(title: '单轴加速度'),
  };
}
