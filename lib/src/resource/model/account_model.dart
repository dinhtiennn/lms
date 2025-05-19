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
      accountId: json['accountId'] as String,
      accountFullname: json['accountFullname'] as String,
      accountUsername: json['accountUsername'] as String,
      avatar: json['avatar'] as String?,
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

  static List<AccountModel> listFromJson(List<dynamic> list) {
    return list.map((e) => AccountModel.fromJson(e as Map<String, dynamic>)).toList();
  }
}
