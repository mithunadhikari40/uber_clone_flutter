import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:flutter/material.dart';
import 'package:uber_clone/models/search_suggestion.dart';

class AutoCompleteTextView extends StatelessWidget {
  final TextEditingController controller;
  final List<SearchSuggestion> suggestions;
  final GlobalKey<AutoCompleteTextFieldState<SearchSuggestion>> autoCompleteKey;
  final Function(SearchSuggestion) onItemSubmitted;
  final Function(String) textSubmitted;
  final Function(String) textChange;
  final Function(bool) onChangeFocus;
  final String hintText;
  final FocusNode focusNode;

  AutoCompleteTextView({
    Key key,
    @required this.controller,
    @required this.autoCompleteKey,
    @required this.suggestions,
    @required this.onItemSubmitted,
    @required this.textSubmitted,
    @required this.textChange,
    this.onChangeFocus,
    @required this.hintText,
  })  : focusNode = FocusNode(),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    focusNode?.addListener(() {
      onChangeFocus(focusNode.hasFocus);
    });

    return AutoCompleteTextField<SearchSuggestion>(
      key: autoCompleteKey,
      suggestions: suggestions,
      decoration: buildInputDecoration(),
      itemSubmitted: (SearchSuggestion item) {
        onItemSubmitted(item);
//        setState(() => _selectedLocation = item.formattedAddress);
//        if (item.address.length > 2) sendRequest(item.address);
      },
      submitOnSuggestionTap: true,
      controller: controller,
      clearOnSubmit: false,
      focusNode: focusNode,
      suggestionsAmount: 5,
      textSubmitted: (String text) {
//        addSuggestion(text);
        textSubmitted(text);
//        if (text.length > 2) sendRequest(text);
      },
      textChanged: (String text) {
        if (text.length > 2) textChange(text);
//        if (text.length > 2) addSuggestion(text);
      },
      itemBuilder: (BuildContext context, SearchSuggestion value) {
        return Column(
          children: <Widget>[
            buildSuggestionItems(value),
            Divider(
              height: 5,
            )
          ],
        );
      },
      itemFilter: (SearchSuggestion suggestion, String query) {
        return suggestion.formattedAddress
            .toLowerCase()
            .contains(query.toLowerCase());
      },
      itemSorter: (SearchSuggestion a, SearchSuggestion b) {
        return a.distance == b.distance ? 0 : a.distance > b.distance ? 1 : -1;
      },
    );
  }

  Padding buildSuggestionItems(SearchSuggestion value) {
    print(
        "Matched text is ${value.matchedText} and remaining text is ${value.remainingText}");
    return Padding(
      child: ListTile(
        title: Text(value.address),
        trailing:
            value.isPlace ? Text('${value.distance} k.m') : Icon(Icons.forward),
        subtitle: RichText(
          text: TextSpan(
            children: <TextSpan>[
              TextSpan(
                text: value.matchedText,
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
              ),
              TextSpan(
                text: value.remainingText,
                style: TextStyle(color: Colors.grey[500]),
              ),
            ],
          ),
        ),
//        subtitle: Text(value.formattedAddress),
        leading: CircleAvatar(
          child: Image.network(value.icon),
        ),
//              contentPadding: EdgeInsets.all(0),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
    );
  }

  InputDecoration buildInputDecoration() {
    return InputDecoration(
      hintText: hintText,
      border: InputBorder.none,
      contentPadding: const EdgeInsets.only(left: 15.0, top: 16.0),
      icon: Container(
        margin: EdgeInsets.only(left: 20, top: 5),
        width: 10,
        height: 10,
        child: const Icon(
          Icons.local_taxi,
          color: Colors.black,
        ),
      ),
    );
  }

  void updateSuggestion(List<SearchSuggestion> list) {
    autoCompleteKey.currentState.updateSuggestions(list);
  }
}
