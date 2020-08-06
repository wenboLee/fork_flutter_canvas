import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_canvas/route/main.dart';
import 'package:flutter_canvas/widget/comm.dart';

class DebugMainPage extends StatefulWidget {
  final String title;

  DebugMainPage({Key key, this.title}) : super(key: key);

  _DebugMainPageState createState() => _DebugMainPageState();
}

class _DebugMainPageState extends State<DebugMainPage> {
  List<String> pagesKey = [], titles = [];
  ScrollController _controller;
  bool showToTopBtn = true;
  double offset = 44.0 * 5;

  Color _randomColor() {
    var red = Random.secure().nextInt(255);
    var greed = Random.secure().nextInt(255);
    var blue = Random.secure().nextInt(255);
    if (red > 100 && greed > 100 && blue > 100) {
      return _randomColor();
    } else {
      return Color.fromARGB(255, red, greed, blue);
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = ScrollController();
    pagesKey = routes(context).keys.toList();
    pagesKey.forEach((key) => {
      titles.add((routes(null)[key](null) as dynamic).title)
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF4F4F8),
      appBar: appBar(widget.title),
      body: ListView.separated(
        controller: _controller,
        itemCount: pagesKey?.length ?? 0,
        separatorBuilder: (BuildContext context, int index) => Container(
          padding: EdgeInsets.only(left: 16, right: 16),
          child: Divider(
            height: 1,
            color: Color(0xff3470e1),
          ),
        ),
        itemBuilder: (BuildContext context, int index) => ListTile(
          onTap: () {
            Navigator.pushNamed(context, pagesKey[index]);
          },
          leading: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _randomColor(),
              boxShadow: [
                BoxShadow(
                    color: Color(0xff3470e1),
                    offset: Offset.zero,
                    blurRadius: 10)
              ],
            ),
            child: Center(
              child: Text(
                '${routeWidgetName(pagesKey[index])?.substring(0, 1)?.toUpperCase() ?? ''}${routeWidgetName(pagesKey[index])?.substring(1, 2)?.toLowerCase() ?? ''}',
                style: TextStyle(
                    shadows: [
                      BoxShadow(
                          color: Color(0xff3470e1),
                          offset: Offset.zero,
                          blurRadius: 5)
                    ],
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ),
          ),
          title: Text(
            '${routeWidgetName(pagesKey[index])}',
            style: TextStyle(
              color: _randomColor(),
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text(
            '${pagesKey[index]}=>${titles[index]}',
            style: TextStyle(
              color: _randomColor(),
              fontWeight: FontWeight.bold,
            ),
          ),
          trailing: Icon(
            Icons.keyboard_arrow_right,
            size: 30,
            color: _randomColor(),
          ),
        ),
      ),
      floatingActionButton: showToTopBtn
          ? FloatingActionButton(
              child: Icon(
                Icons.arrow_upward,
                size: 30,
              ),
              onPressed: () {
                _controller.animateTo(0.0,
                    duration: Duration(milliseconds: 200), curve: Curves.ease);
              })
          : Container(),
    );
  }
}
