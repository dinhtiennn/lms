class TeacherModel {
  final String? id;
  final String? fullName;
  final String? email;
  final String? avatar;
  final String? description;
  final String? contact;

  TeacherModel({
    this.id,
    this.fullName,
    this.email,
    this.avatar,
    this.description,
    this.contact,
  });

  factory TeacherModel.fromJson(Map<String, dynamic> json) => TeacherModel(
        id: json["id"],
        fullName: json["fullName"],
        email: json["email"],
        avatar: json["avatar"],
        description: json["description"],
        contact: json["contact"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "fullName": fullName,
        "email": email,
        "avatar": avatar,
        "description": description,
        "contact": contact,
      };

  TeacherModel copyWith({
    String? id,
    String? fullName,
    String? email,
    String? avatar,
    String? description,
    String? contact,
  }) {
    return TeacherModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      avatar: avatar ?? this.avatar,
      description: description ?? this.description,
      contact: contact ?? this.contact,
    );
  }

  @override
  String toString() {
    return 'TeacherModel{fullName: $id,fullName: $fullName, email: $email, avatar: $avatar, description: $description, contact: $contact}';
  }
}
