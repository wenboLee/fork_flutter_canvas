import 'package:flutter/material.dart';
import 'package:flutter_canvas/route/main.dart';
import 'package:flutter_canvas/widget/comm.dart';
import 'package:flutter_canvas/widget/utils.dart';

class DebugMainPage extends StatefulWidget {
  final String title;

  DebugMainPage({Key? key, required this.title}) : super(key: key);

  _DebugMainPageState createState() => _DebugMainPageState();
}

class _DebugMainPageState extends State<DebugMainPage> {
  List<String> pagesKey = [], titles = [];
  late ScrollController _controller;
  bool showToTopBtn = true;
  double offset = 44.0 * 5;

  @override
  void initState() {
    super.initState();
    _controller = ScrollController();
    pagesKey = routes(context).keys.toList()
      ..remove(RouteConstant.DebugMainPage);
    pagesKey.forEach((key) =>
        {titles.add((routes(context)[key]!(context) as dynamic).title)});
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
        itemCount: pagesKey.length,
        separatorBuilder: (BuildContext context, int index) => Container(
          padding: EdgeInsets.only(left: 16, right: 16),
          child: Divider(
            height: 1,
            color: randomColor(),
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
              color: randomColor(),
              boxShadow: [
                BoxShadow(
                    color: randomColor(), offset: Offset.zero, blurRadius: 10)
              ],
            ),
            child: Center(
              child: Text(
                '${titles[index].substring(0, 1).toUpperCase()}${titles[index].substring(1, 2).toLowerCase()}',
                style: TextStyle(
                    shadows: [
                      BoxShadow(
                          color: Colors.black,
                          offset: Offset.zero,
                          blurRadius: 1)
                    ],
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ),
          ),
          title: Text(
            '${titles[index]}',
            style: TextStyle(
              shadows: [
                BoxShadow(
                    color: Colors.black, offset: Offset.zero, blurRadius: 1)
              ],
              color: randomColor(),
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text(
            '${routeWidgetName(pagesKey[index])}',
            style: TextStyle(
              shadows: [
                BoxShadow(
                    color: Colors.black, offset: Offset.zero, blurRadius: 1)
              ],
              color: randomColor(),
              fontWeight: FontWeight.bold,
            ),
          ),
          trailing: Icon(
            Icons.keyboard_arrow_right,
            size: 30,
            color: randomColor(),
          ),
        ),
      ),
      floatingActionButton: showToTopBtn
          ? actionButton(
              () {
                _controller.animateTo(0.0,
                    duration: Duration(milliseconds: 300), curve: Curves.ease);
              },
              iconData: Icons.arrow_upward,
            )
          : Container(),
    );
  }
}
