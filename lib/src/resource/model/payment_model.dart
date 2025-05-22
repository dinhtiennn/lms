class PaymentRequest {
  final String courseId;
  final double price;

  PaymentRequest({
    required this.courseId,
    required this.price,
  });

  Map<String, dynamic> toJson() {
    return {
      'courseId': courseId,
      'price': price,
    };
  }
}

class PaymentResponse {
  final String? transactionId;
  final String? status;
  final double? amount;
  final DateTime? createdAt;

  PaymentResponse({
    this.transactionId,
    this.status,
    this.amount,
    this.createdAt,
  });

  factory PaymentResponse.fromJson(Map<String, dynamic> json) {
    return PaymentResponse(
      transactionId: json['transactionId'],
      status: json['status'],
      amount: json['amount']?.toDouble(),
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
    );
  }
}
