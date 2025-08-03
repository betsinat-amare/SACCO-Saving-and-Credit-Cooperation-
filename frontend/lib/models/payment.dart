class Payment {
  final String id;
  final String userId;
  final double amount;
  final DateTime date;
  final String status;

  Payment({
    required this.id,
    required this.userId,
    required this.amount,
    required this.date,
    required this.status,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'] ?? json['_id'] ?? '',
      userId:
          json['user'] is String
              ? json['user']
              : (json['user']?['id'] ?? json['user']?['_id'] ?? ''),
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      date: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
      status: json['status'] ?? '',
    );
  }
}
