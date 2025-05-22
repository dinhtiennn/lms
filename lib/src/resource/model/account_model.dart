class AccountModel {
  final String? accountId;
  final String? accountFullname;
  final String? accountUsername;
  final String? avatar;

  AccountModel({
    this.accountId,
    this.accountFullname,
    required this.accountUsername,
    this.avatar,
  });

  factory AccountModel.fromJson(Map<String, dynamic> json) {
    return AccountModel(
      accountId: json['accountId'],
      accountFullname: json['accountFullname'],
      accountUsername: json['accountUsername'],
      avatar: json['avatar'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accountId': accountId,
      'accountFullname': accountFullname,
      'accountUsername': accountUsername,
      'avatar': avatar,
    };
  }

  static List<AccountModel> listFromJson(List<dynamic> jsonList) {
    return jsonList.map((json) => AccountModel.fromJson(json)).toList();
  }
}
