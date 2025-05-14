class SocketResultModel<T> {
  int? status;
  String? message;
  T? result;
  bool? successCode;

  SocketResultModel({this.status, this.message, this.result, this.successCode});

  SocketResultModel.fromJson(
    dynamic json, {
    T Function(dynamic)? converter,
  }) {
    successCode = (json["code"] as int) == 0;
    message = json["msg"];
    result = converter != null && json["result"] != null ? converter(json["result"]) : json["result"];
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map["status"] = status;
    map["msg"] = message;
    map["result"] = result;
    return map;
  }

  bool get isSuccess => successCode == true && result != null;
}
