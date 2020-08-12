import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'dart:math' as math;

AppBar appBar(title) {
  return AppBar(
    title: Text(
      title,
      style: TextStyle(color: Colors.white),
    ),
    iconTheme: IconThemeData(color: Colors.white),
  );
}

double angle = 0;

void drawAuthorText(Canvas canvas, Size size) {
  double textW = 300;
  angle += 0.005;
  angle %= math.pi * 2;

  var translationX = ((size.width - textW) / 8) * (math.sin(angle) + 1) * 0.14;
  var textArr = ['Flutter Canvas', '请叫我code哥'];
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
      var color = Colors.black54;
      int alpha =
          10 * translationX.toInt() > 255 ? 255 : 10 * translationX.toInt();
      pb.pushStyle(ui.TextStyle(
          color: Color.fromARGB(alpha, color.red, color.green, color.blue)));
      pb.addText(char);
      // 文本的宽度约束
      ui.ParagraphConstraints pc = ui.ParagraphConstraints(width: textW);
      // 这里需要先layout,将宽度约束填入,否则无法绘制
      ui.Paragraph paragraph = pb.build()..layout(pc);
      // 文字左上角起始点
      Offset offset =
          Offset(translationX * (i + 1).toDouble(), 18 * (j + 1).toDouble());
      canvas.drawParagraph(paragraph, offset);
    }
  }
}
