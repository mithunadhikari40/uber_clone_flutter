import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final Color color;

  final String text;
  final Function onPressed;

  const CustomButton({Key key, this.color, this.text, this.onPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RaisedButton(
      color: color,
      padding: EdgeInsets.symmetric(vertical: 12.0),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 20.0, color: Colors.white),
      ),
      onPressed: () => onPressed,
    );
  }
}
