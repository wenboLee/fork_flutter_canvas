import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_canvas/route/main.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        platform: defaultTargetPlatform == TargetPlatform.android
            ? TargetPlatform.iOS
            : defaultTargetPlatform,
        brightness: Theme.of(context).brightness,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        // primaryColorBrightness: Brightness.dark,
      ),
      initialRoute: RouteConstant.DebugMainPage,
      routes: routes(context),
      navigatorObservers: [
        NavObserver(),
      ],
    );
  }
}

class NavObserver extends NavigatorObserver {
  @override
  void didPush(Route route, Route? previousRoute) {
    print('push ${route.settings.name}');
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    print('pop ${route.settings.name}');
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    print('replace ${newRoute!.settings.name}');
  }
}
