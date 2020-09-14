import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SimpleAutoCompleteTextView extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onSubmitted;
  final Function(bool) onFocusGained;
  final String hintText;
  final TextInputType textInputType;
  final int maxLength;
  final FocusNode focusNode = new FocusNode();
  final bool shouldHideKeyboard;

  SimpleAutoCompleteTextView(
      {Key key,
      this.controller,
      this.onFocusGained,
      this.onSubmitted,
      this.textInputType,
      this.maxLength,
      this.shouldHideKeyboard,
      this.hintText})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    focusNode.addListener(() {
      onFocusGained(focusNode.hasFocus);
    });
    if (shouldHideKeyboard) {
      SystemChannels.textInput.invokeMethod('TextInput.hide');
    } else {
      SystemChannels.textInput.invokeMethod('TextInput.show');
//      FocusScope.of(context).requestFocus(focusNode);

    }

    return TextField(
      focusNode: focusNode,
      maxLength: maxLength,
      style: TextStyle(fontSize: 24.0),
      cursorColor: Colors.black,
      keyboardType: textInputType,
      controller: controller,
      textInputAction: TextInputAction.go,
      onSubmitted: (value) {
        onSubmitted(value);
      },
//      onChanged: (String value) {
//        onSubmitted(value);
//      },
      decoration: InputDecoration(
        icon: Container(
          margin: EdgeInsets.only(left: 10, top: 16),
          width: 120,
          height: 48,
          child: Row(
            children: <Widget>[
              FadeInImage.assetNetwork(
                placeholder: "assets/images/bangladesh_flag.png",
                image:
                    "https://europa.eu/capacity4dev/system/files/images/photo/bangladesh.gif",
                width: 48,
                height: 48,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.0),
              ),
              Text(
                "+977-",
                style: TextStyle(fontSize: 20.0),
              )
            ],
          ),
        ),
        hintText: hintText,
        border: InputBorder.none,
        contentPadding: EdgeInsets.only(left: 15.0, top: 16.0),
      ),
    );
  }
}
