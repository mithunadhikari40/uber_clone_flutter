import 'package:flutter/material.dart';

class CustomRadioListTile extends StatefulWidget {
  final List<RadioModel> sampleData;
  final Function(int, String) selectedData;

  CustomRadioListTile({this.sampleData, this.selectedData});

  @override
  createState() {
    return CustomRadioListTileState();
  }
}

class CustomRadioListTileState extends State<CustomRadioListTile> {
  List<RadioModel> sampleData;

  @override
  void initState() {
    super.initState();
    sampleData = widget.sampleData;
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: sampleData.length,
      scrollDirection: Axis.horizontal,
      itemBuilder: (BuildContext context, int index) {
        return InkWell(
          highlightColor: Colors.red,
          splashColor: Colors.blueAccent,
          onTap: () {
            if (sampleData[index].isSelected) {
              setState(() {
                sampleData.forEach((element) => element.isSelected = false);
              });
            } else {
              setState(() {
                sampleData.forEach((element) => element.isSelected = false);
                sampleData[index].isSelected = !sampleData[index].isSelected;
              });
            }
            widget.selectedData(index, sampleData[index].text);
          },
          child: RadioItem(sampleData[index]),
        );
      },
    );
  }
}

class RadioItem extends StatelessWidget {
  final RadioModel _item;

  RadioItem(this._item);

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Container(
      margin: EdgeInsets.all(5.0),
      height: 50.0,
      width: width / 3.5,
      child: Center(
        child: Text(_item.buttonText,
            style: TextStyle(
                color: _item.isSelected ? Colors.white : Colors.black,
                //fontWeight: FontWeight.bold,
                fontSize: 18.0)),
      ),
      decoration: BoxDecoration(
        color: _item.isSelected ? Colors.teal : Colors.transparent,
        border: Border.all(
            width: 1.0,
            color: _item.isSelected ? Colors.blueAccent : Colors.grey),
        borderRadius: const BorderRadius.all(const Radius.circular(12.0)),
      ),
    );
  }
}

class RadioModel {
  bool isSelected;
  final String buttonText;
  final String text;

  RadioModel(this.isSelected, this.buttonText, this.text);
}
