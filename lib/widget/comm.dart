import 'package:flutter/material.dart';
import 'package:flutter_canvas/widget/utils.dart';
import 'dart:ui' as ui;
import 'dart:math' as math;

AppBar appBar(title) {
  return AppBar(
    title: Text(
      title,
      style: TextStyle(color: Colors.white),
    ),
    iconTheme: IconThemeData(color: Colors.white),
    brightness: Brightness.dark,
  );
}

FloatingActionButton actionButton(Function() onPressed,
    {IconData iconData = Icons.refresh}) {
  return FloatingActionButton(
    backgroundColor: randomColor(alpha: 200),
    child: Icon(
      iconData,
      size: 30,
    ),
    onPressed: onPressed,
  );
}

double angle = 0;

void drawAuthorText(Canvas canvas, [Offset offset = Offset.zero]) {
  canvas.save();
  double x1, y1, x2, y2, r1 = 50, r2 = 30;

  angle += 0.015;
  angle %= math.pi * 2;
  var textArr = ['Flutter-Canvas', '请叫我code哥'];
  for (var j = 0; j < textArr.length; j++) {
    var text = textArr[j];
    List<String> charList = text.characters.toList();
    for (var i = 0; i < charList.length; i++) {
      var char = charList[i];
      // 文本构造器
      ui.ParagraphBuilder pb = ui.ParagraphBuilder(
        ui.ParagraphStyle(
          textAlign: TextAlign.left,
          fontWeight: FontWeight.bold,
          fontStyle: FontStyle.normal,
          fontSize: 15.0,
        ),
      );
      pb.pushStyle(ui.TextStyle(color: Colors.black54));
      pb.addText(char);
      // 文本的宽度约束
      ui.ParagraphConstraints pc = ui.ParagraphConstraints(width: 20);
      // 这里需要先layout,将宽度约束填入,否则无法绘制
      ui.Paragraph paragraph = pb.build()..layout(pc);
      Offset offsetText;
      if (j == 0) {
        x1 = r1 + r1 * math.cos(angle + toRad(i * 20));
        y1 = r1 + r1 * math.sin(angle + toRad(i * 20));
        offsetText = Offset(x1, y1);
      } else {
        x2 = r2 +
            r2 * math.cos(toRad(360) - angle + toRad(i * 30)) +
            (r1 - r2).abs();
        y2 = r2 +
            r2 * math.sin(toRad(360) - angle + toRad(i * 30)) +
            (r1 - r2).abs();
        offsetText = Offset(x2, y2);
      }
      canvas.drawParagraph(
          paragraph, offsetText.translate(offset.dx, offset.dy));
    }
  }
  canvas.restore();
}

//void _drawTextPaintShowSize(Canvas canvas) {
//  TextPainter textPainter = TextPainter(
//      text: TextSpan(
//          text: 'Flutter Unit',
//          style: TextStyle(
//              fontSize: 40,
//              color: Colors.black)),
//      textAlign: TextAlign.center,
//      textDirection: TextDirection.ltr);
//  textPainter.layout(); // 进行布局
//  Size size = textPainter.size; // 尺寸必须在布局后获取
//  textPainter.paint(canvas, Offset(-size.width / 2, -size.height / 2));
//
//  canvas.drawRect(
//      Rect.fromLTRB(0, 0, size.width, size.height)
//          .translate(-size.width / 2, -size.height / 2),
//      _paint..color = Colors.blue.withAlpha(33));
//}
