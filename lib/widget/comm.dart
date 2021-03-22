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

void drawAuthorText(Canvas canvas, Size size) {
  canvas.save();
  angle += 0.04;
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
      double spacing = 10, lineHeight = 30, swing = 15;
      // 文字左上角起始点
      Offset offset = Offset(
          math.cos(angle + toRad(1 * i)) * spacing +
              spacing * (i + 1).toDouble(),
          lineHeight * (j + 1).toDouble() +
              math.sin(angle + toRad(30 * i)) * swing);
      canvas.drawParagraph(paragraph, offset);
    }
  }
  canvas.restore();
}

//void _drawTextPaint(Canvas canvas) {
//  var textPainter = TextPainter(
//      text: TextSpan(
//          text: 'Flutter Unit',
//          style: TextStyle(fontSize: 40,color: Colors.black)),
//      textAlign: TextAlign.center,
//      textDirection: TextDirection.ltr);
//  textPainter.layout(); // 进行布局
//  textPainter.paint(canvas, Offset.zero); // 进行绘制
//}
