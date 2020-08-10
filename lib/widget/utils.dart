import 'dart:math';
import 'package:flutter/material.dart';

Color randomColor() {
  var red = 55 + Random().nextInt(201);
  var greed = 55 + Random().nextInt(201);
  var blue = 55 + Random().nextInt(201);
  if (red > 100 && greed > 100 && blue > 100) {
    return randomColor();
  } else {
    return Color.fromARGB(255, red, greed, blue);
  }
}

double randomScope(List<int> scope) {
  // 默认从小到大scope.sort()
  scope.sort((a, b) => a.compareTo(b));
  return Random().nextDouble() * (scope[1] - scope[0]) + scope[0];
}

// 角度转弧度
double toRad(angle) {
  return pi / 180 * angle;
}

// 弧度转角度
double toAngle(rad) {
  return rad * 180 / pi;
}

class Toast {
  static OverlayEntry _overlayEntry;
  static bool _showing = false;
  static DateTime _startedTime;
  static int _duration = 3000;
  static String _msg;

  static void show(BuildContext context, String msg, {double top = 0.0}) async {
    assert(msg != null);
    _msg = msg;
    _startedTime = DateTime.now();

    OverlayState overlayState = Overlay.of(context);
    _showing = true;
    if (_overlayEntry == null) {
      _overlayEntry = OverlayEntry(
          builder: (BuildContext context) => Positioned(
                top: top > 0 ? top : MediaQuery.of(context).size.height * 2 / 3,
                child: Container(
                    padding: EdgeInsets.all(80),
                    alignment: Alignment.center,
                    width: MediaQuery.of(context).size.width,
                    child: Container(
                      decoration: BoxDecoration(
                          color: Color(0xff3470e1),
                          borderRadius: BorderRadius.all(Radius.circular(20))),
                      padding: EdgeInsets.only(
                          left: 15, right: 15, top: 5, bottom: 5),
                      child: AnimatedOpacity(
                        opacity: _showing ? 1.0 : 0.0,
                        duration: _showing
                            ? Duration(milliseconds: 100)
                            : Duration(milliseconds: 400),
                        child: Text(
                          _msg,
                          style: TextStyle(
                            fontSize: 12.0,
                            decoration: TextDecoration.none,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    )),
              ));
      overlayState.insert(_overlayEntry);
    } else {
      if (_overlayEntry != null) {
        _overlayEntry.markNeedsBuild();
      }
    }
    await Future.delayed(Duration(milliseconds: _duration)); //等待3秒

    if (DateTime.now().difference(_startedTime).inMilliseconds >= _duration) {
      _showing = false;
      if (_overlayEntry != null) {
        Future.delayed(Duration.zero, () {
          _overlayEntry.markNeedsBuild();
          _overlayEntry.remove();
          _overlayEntry = null;
        });
      }
    }
  }
}
