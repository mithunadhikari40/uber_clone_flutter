import 'package:flutter/material.dart';

class PickupLocationView extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final Function(String) onSubmitted;
  final Function(String) onTextChanged;

  PickupLocationView(
      {this.controller, this.hintText, this.onSubmitted, this.onTextChanged});

  @override
  Widget build(BuildContext context) {
    return TextField(
      style: TextStyle(fontSize: 24.0),
      cursorColor: Colors.black,
      controller: controller,
      textInputAction: TextInputAction.go,
      onSubmitted: (value) {
        onSubmitted(value);
      },
      onChanged: (String value) {
        onTextChanged(value);
      },
      decoration: InputDecoration(
        icon: Container(
          margin: EdgeInsets.only(left: 10, top: 16),
          width: 120,
          height: 48,
          child: Icon(Icons.location_city),
        ),
        hintText: hintText,
        border: InputBorder.none,
        contentPadding: EdgeInsets.only(left: 15.0, top: 16.0),
      ),
    );
  }
}
