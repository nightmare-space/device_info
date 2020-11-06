
import 'package:flutter/material.dart';

class DividerAndText extends StatelessWidget {
  const DividerAndText(this.text, {Key key}) : super(key: key);
  final String text;
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        const Divider(
          indent: 12.0,
          endIndent: 12.0,
          height: 2.0,
        ),
        Material(
          color: Theme.of(context).scaffoldBackgroundColor,
          child: Text(text),
        )
      ],
    );
  }
}
