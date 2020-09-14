class SearchPlaces {
  String id;
  String address;
  String formattedAddress;
  double lat;
  double lon;
  double rating;
  String icon;

  SearchPlaces(this.id, this.address, this.formattedAddress, this.lat, this.lon,
      this.rating,this.icon);

  SearchPlaces.fromJson(Map<String, dynamic> json)
      : id = json["id"] as String,
        address = json["name"] as String,
        formattedAddress = getFormattedAddress(json["formatted_address"]),
        rating = double.parse(json["rating"].toString()),
        lat = (json["geometry"]["location"]["lat"]) as double,
        lon = (json["geometry"]["location"]["lng"]) as double,
        icon = json["icon"] as String;

  Map<String, dynamic> toJson() => <String, dynamic>{
        "id": id,
        "address": address,
        "formattedAddress": formattedAddress,
        "lat": lat,
        "lon": lon,
        "rating": rating,
        "icon": icon,
      };

  static String getFormattedAddress(String json) {
    List<String> list = json.split(",");
    if (list.length >= 2) {
      return getAddressPretty('${list[0]} ${list[1]}');
    }
    return getAddressPretty(json);
  }

  static String getAddressPretty(String json) {
    List<String> list = json.split("");
    json = '';
    list.forEach((String some) {
      print('${some.codeUnits[0]}');

      if (some.codeUnits[0] < 48 || some.codeUnits[0] > 57) {
        json += some;
      }
    });
    json = json.replaceFirst("  ", " ");
    json = json.replaceFirst(" ,", ",");
    return json;
  }
}
