class MajorModel {
  final String? id;
  final String? name;

  MajorModel({
    this.id,
    this.name,
  });

  factory MajorModel.fromJson(Map<String, dynamic> json) => MajorModel(
        id: json["id"],
        name: json["name"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
      };

  static List<MajorModel> listFromJson(List<dynamic> jsonList) {
    return jsonList.map((json) => MajorModel.fromJson(json)).toList();
  }
}
