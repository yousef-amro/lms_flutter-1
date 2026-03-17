import 'package:lms_app/core/domain/models/json_response_model.dart';

class CoreModel {
  final String id;
  final String name;

  CoreModel({required this.id, required this.name});

  factory CoreModel.fromJson(Map<String, dynamic> json) {
    final jsonHelper = JsonResponseModel.instance();

    return CoreModel(
      id: jsonHelper.getStringJson(json, 'id') ?? '',
      name: jsonHelper.getStringJson(json, 'name') ?? '',
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'name': name};

  static List<Map<String, dynamic>> toListJson(List<CoreModel> baseList) {
    List<Map<String, dynamic>> map = [];
    for (var value in baseList) {
      map.add(value.toJson());
    }
    return map;
  }

  @override
  String toString() {
    return name;
  }
}
