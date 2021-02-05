import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_canvas/widget/ball.dart';
import 'package:flutter_canvas/widget/box.dart';

Color randomColor({alpha = 255}) {
  var red = 55 + Random().nextInt(201);
  var greed = 55 + Random().nextInt(201);
  var blue = 55 + Random().nextInt(201);
  if (red > 100 && greed > 100 && blue > 100) {
    return randomColor(alpha: alpha);
  } else {
    return Color.fromARGB(alpha, red, greed, blue);
  }
}

double randomScope(List<double> scope) {
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

// 点是否在圆内
bool isPoint(Ball ball, Offset point) {
  return ball.r >= sqrt(pow(point.dx - ball.x, 2) + pow(point.dy - ball.y, 2));
}

// 点是否在盒子内
bool isBoxPoint(Box box, Offset point) {
  return point.dx >= box.x &&
      point.dx <= box.x + box.w &&
      point.dy >= box.y &&
      point.dy <= box.y + box.h;
}

// 两点间间距
double getDist(Offset p1, Offset p2) {
  return sqrt(pow(p2.dx - p1.dx, 2) + pow(p2.dy - p1.dy, 2));
}

// 矩形之间碰撞检测
bool rectHit(Box box1, Box box2) {
  return (box1.x + box1.w >= box2.x &&
      box1.x <= box2.x + box2.w &&
      box1.y + box1.h >= box2.y &&
      box1.y <= box2.y + box2.h);
}

// 对小球进行边界反弹处理
void checkBallBounce(Ball ball, Size size, double bounce) {
  if (ball.x - ball.r <= 0) {
    ball.x = ball.r;
    ball.vx *= bounce;
  } else if (ball.x + ball.r >= size.width) {
    ball.x = size.width - ball.r;
    ball.vx *= bounce;
  }
  if (ball.y - ball.r <= 0) {
    ball.y = ball.r;
    ball.vy *= bounce;
  } else if (ball.y + ball.r >= size.height) {
    ball.y = size.height - ball.r;
    ball.vy *= bounce;
  }
}

// 根据动能守恒对2小球进行弹动处理
void checkBallHit(Ball b1, Ball b2) {
  var dx = b2.x - b1.x;
  var dy = b2.y - b1.y;
  var dist = sqrt(pow(dx, 2) + pow(dy, 2));
  if (dist < b1.r + b2.r) {
    var angle = atan2(dy, dx);
    var sinAngle = sin(angle);
    var cosAngle = cos(angle);

    // 以b1为参照物，设定b1中心点为旋转基点
    double x1 = 0, y1 = 0;
    var x2 = dx * cosAngle + dy * sinAngle;
    var y2 = dy * cosAngle - dx * sinAngle;

    // 旋转b1和b2的速度
    var vx1 = b1.vx * cosAngle + b1.vy * sinAngle;
    var vy1 = b1.vy * cosAngle - b1.vx * sinAngle;
    var vx2 = b2.vx * cosAngle + b2.vy * sinAngle;
    var vy2 = b2.vy * cosAngle - b2.vx * sinAngle;

    // 求出b1和b2碰撞后的速度,动能守恒
    var vx1Final = ((b1.m - b2.m) * vx1 + 2 * b2.m * vx2) / (b1.m + b2.m);
    var vx2Final = ((b2.m - b1.m) * vx2 + 2 * b1.m * vx1) / (b1.m + b2.m);

    // 处理两个小球碰撞后，将他们归位
    var lep = (b1.r + b2.r) - (x2 - x1).abs();
    x1 = x1 + (vx1Final < 0 ? -lep / 2 : lep / 2);
    x2 = x2 + (vx2Final < 0 ? -lep / 2 : lep / 2);

    // 由于相对b1旋转，旋转回去+b1
    b2.x = b1.x + (x2 * cosAngle - y2 * sinAngle);
    b2.y = b1.y + (y2 * cosAngle + x2 * sinAngle);
    b1.x = b1.x + (x1 * cosAngle - y1 * sinAngle);
    b1.y = b1.y + (y1 * cosAngle + x1 * sinAngle);

    // 旋转回b1和b2速度
    b1.vx = vx1Final * cosAngle - vy1 * sinAngle;
    b1.vy = vy1 * cosAngle + vx1Final * sinAngle;
    b2.vx = vx2Final * cosAngle - vy2 * sinAngle;
    b2.vy = vy2 * cosAngle + vx2Final * sinAngle;
  }
}

// 计算文本高度
double calculateTextHeight({
  BuildContext context,
  String value,
  TextStyle style,
  double maxWidth,
  int maxLines,
}) {
  TextPainter painter = TextPainter(
    locale: Localizations.maybeLocaleOf(context),
    maxLines: maxLines,
    textDirection: TextDirection.ltr,
    text: TextSpan(
      text: value,
      style: style,
    ),
  )..layout(maxWidth: maxWidth);
  return painter.height;
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

class IconFontUtil {
  static Future<List<ParsPathModel>> read(String networkUrl,
      {String prefix = 'icon', Color defFillColor = Colors.black}) async {
    List<ParsPathModel> svgList = [];
    if (networkUrl != null && networkUrl.isNotEmpty) {
      String result = await _httpRead(networkUrl);
      if (result.isNotEmpty) {
        // 第一步取出<svg></svg> 标签对里内容
        String parse1 =
            _netJSSvgParse(result, RegExp(r'(?<=\<svg\>).*?(?=\</svg\>)'));
        if (parse1.isNotEmpty) {
          // 第二步取出<symbol></symbol> 标签对
          List<String> parse2 =
              _netJSSvgParseList(parse1, RegExp(r'\<symbol(.*?)\</symbol\>'));
          // 第三步取出name, 取出path
          parse2.forEach((element) {
            // 处理非法name字符
            String name =
                _netJSSvgParse(element, RegExp('''(?<=id="$prefix).*?(?=")'''))
                    .replaceAllMapped(RegExp(r'[^a-zA-Z0-9_]'), (match) => '_');
            String viewBox =
                _netJSSvgParse(element, RegExp(r'''(?<=viewBox=").*?(?=")'''));
            List<double> viewBoxList =
                _parseList(viewBox, RegExp(r'''\d+(\.\d+)?'''));
            List<String> pathList = _netJSSvgParseList(
                element, RegExp(r'(\<path d=").*?(\</path\>)'));
            // 每一条path 生成独立数据
            List<PathInfoModel> pathDataMap = [];
            if (pathList.isNotEmpty) {
              pathDataMap = pathList.map((pathXml) {
                String path = _netJSSvgParse(
                    pathXml, RegExp(r'''(?<=\<path d=").*?(?=")'''));
                String fill =
                    _netJSSvgParse(pathXml, RegExp(r'''(?<=fill=").*?(?=")'''));
                String opacity = _netJSSvgParse(
                    pathXml, RegExp(r'''(?<=opacity=").*?(?=")'''));
                Color fillColor = defFillColor;
                if (fill.isNotEmpty) {
                  fillColor = HexColor.fromHex(fill);
                }
                if (fillColor != null && opacity.isNotEmpty) {
                  fillColor = fillColor.withOpacity(double.tryParse(opacity));
                }
                return PathInfoModel(path: path, fillColor: fillColor);
              }).toList();
            }
            var viewBoxModel = ViewBoxModel(
                minX: viewBoxList[0],
                minY: viewBoxList[1],
                width: viewBoxList[2],
                height: viewBoxList[3]);
            svgList.add(ParsPathModel(
                name: name, pathList: pathDataMap, viewBox: viewBoxModel));
          });
        }
      }
    }
    return svgList;
  }

  static Future<String> _httpRead(String url) async {
    var newUrl = url;
    if (!newUrl.startsWith('https')) {
      newUrl = 'https:$url';
    }
    var httpClient = HttpClient();
    String result = '';
    try {
      var request = await httpClient.getUrl(Uri.parse(newUrl));
      var response = await request.close();
      if (response.statusCode == HttpStatus.ok) {
        result = await response.transform(utf8.decoder).join();
      }
    } catch (exception) {}
    return result;
  }

  static String _netJSSvgParse(String input, RegExp exp) {
    Iterable<Match> matches = exp.allMatches(input);
    String output = '';
    for (Match m in matches) {
      String match = m.group(0);
      output += match;
    }
    return output;
  }

  static List<String> _netJSSvgParseList(String input, RegExp exp) {
    Iterable<Match> matches = exp.allMatches(input);
    List<String> output = [];
    for (Match m in matches) {
      String match = m.group(0);
      output.add(match);
    }
    return output;
  }

  static List<double> _parseList(String input, RegExp exp) {
    Iterable<Match> matches = exp.allMatches(input);
    List<double> output = [];
    for (Match m in matches) {
      double match = double.tryParse(m.group(0));
      output.add(match);
    }
    return output;
  }
}

class ParsPathModel {
  final String name;
  final List<PathInfoModel> pathList;
  final ViewBoxModel viewBox;

  const ParsPathModel({this.name, this.pathList, this.viewBox});
}

class ViewBoxModel {
  final double minX;
  final double minY;
  final double width;
  final double height;

  const ViewBoxModel({this.minX, this.minY, this.width, this.height});
}

class PathInfoModel {
  final String path;
  final Color fillColor;

  const PathInfoModel({this.path, this.fillColor});
}

extension HexColor on Color {
  /// String is in the format "aabbcc" or "ffaabbcc" with an optional leading "#".
  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  /// Prefixes a hash sign if [leadingHashSign] is set to `true` (default is `true`).
  String toHex({bool leadingHashSign = true}) => '${leadingHashSign ? '#' : ''}'
      '${alpha.toRadixString(16).padLeft(2, '0')}'
      '${red.toRadixString(16).padLeft(2, '0')}'
      '${green.toRadixString(16).padLeft(2, '0')}'
      '${blue.toRadixString(16).padLeft(2, '0')}';
}
