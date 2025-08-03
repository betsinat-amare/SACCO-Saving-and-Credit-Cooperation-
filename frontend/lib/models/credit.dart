class Credit {
  final String id;
  final String userId;
  final String? userName;
  final double amount;
  final double remainingDebt;
  final DateTime date;
  final String status;

  Credit({
    required this.id,
    required this.userId,
    this.userName,
    required this.amount,
    required this.remainingDebt,
    required this.date,
    required this.status,
  });

  factory Credit.fromJson(Map<String, dynamic> json) {
    return Credit(
      id: json['id'] ?? json['_id'] ?? '',
      userId:
          json['user'] is String
              ? json['user']
              : (json['user']?['id'] ?? json['user']?['_id'] ?? ''),
      userName: json['user'] is Map ? json['user']['name'] : null,
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      remainingDebt: (json['remaining_debt'] as num?)?.toDouble() ?? 0.0,
      date: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
      status: json['status'] ?? '',
    );
  }
}
