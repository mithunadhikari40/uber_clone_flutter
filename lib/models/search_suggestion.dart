class SearchSuggestion {
  String id;
  String address;
  String formattedAddress;
  double distance;
  String icon;
  String matchedText;
  String remainingText;
  bool isPlace = true;

  SearchSuggestion(
      {this.id,
      this.address,
      this.formattedAddress,
      this.distance,
      this.icon,
      this.matchedText,
      this.isPlace,
      this.remainingText});

  Map<String, dynamic> toJson() => <String, dynamic>{
        "id": id,
        "address": address,
        "formattedAddress": formattedAddress,
        "distance": distance,
        "icon": icon,
        "matchedText": matchedText,
        "remainingText": remainingText,
        "isPlace": isPlace,
      };

  @override
  String toString() {
    return this.address;
  }
}
