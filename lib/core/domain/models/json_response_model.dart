class JsonResponseModel {
  static final JsonResponseModel _instance = JsonResponseModel._internal();

  factory JsonResponseModel.instance() {
    return _instance;
  }

  JsonResponseModel._internal();

  //Handle Fetch Nullable From Json
  String? getStringJson(
    Map<String, dynamic> json,
    String key, {
    dynamic defaultValue = "",
  }) {
    return json[key] == null ? defaultValue : json[key].toString();
  }

  int getIntJson(Map<String, dynamic> json, String key) {
    return int.parse(json[key] == null ? "0" : json[key].toString());
  }

  double getDoubleJson(Map<String, dynamic> json, String key) {
    return double.parse(json[key] == null ? "0.0" : json[key].toString());
  }

  bool getBoolJson(
    Map<String, dynamic> json,
    String key, {
    bool returnValue = false,
  }) {
    if (json[key] == null) {
      return false;
    } else if (json[key].toString() == '1') {
      return true;
    } else if (json[key].toString() == '0') {
      return returnValue;
    } else {
      return json[key].toString().toLowerCase() == 'true';
    }
  }

  T getObjectJson<T>(
    Map<String, dynamic> json,
    String key,
    Function(Map<String, dynamic> json) fromJson,
    Map<String, dynamic> toJson,
  ) {
    return json[key] != null ? fromJson(json[key]) : fromJson(toJson);
  }

  List<T> getListJson<T>(
    Map<String, dynamic> json,
    String key,
    Function(Map<String, dynamic> json) fromJson,
  ) {
    List<T> list = [];
    if (json[key] != null) {
      json[key].forEach((v) {
        list.add(fromJson(v));
      });
    }
    return list;
  }

  //Handle Send Nullable To Json
  String setStringJson(String? variable, {String returnValue = ""}) {
    return variable ?? returnValue;
  }

  int setIntJson(int? variable, {int returnValue = 0}) {
    return variable ?? returnValue;
  }

  double setDoubleJson(double? variable, {double returnValue = 0.0}) {
    return variable ?? returnValue;
  }

  bool setBoolJson(bool? variable, {bool returnValue = false}) {
    return variable ?? returnValue;
  }

  List<T> setListJson<T>(List<T>? list) {
    return list ?? [];
  }
}
