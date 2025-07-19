class Savings {
  final String id;
  final String userId;
  final double amount;
  final DateTime date;
  final String status;

  Savings({
    required this.id,
    required this.userId,
    required this.amount,
    required this.date,
    required this.status,
  });

  factory Savings.fromJson(Map<String, dynamic> json) {
    return Savings(
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
