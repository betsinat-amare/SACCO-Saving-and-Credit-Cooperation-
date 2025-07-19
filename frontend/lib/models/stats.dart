class CooperativeStats {
  final double totalCapital;
  final int totalMembers;
  final double totalCredits;
  final double totalSavings;
  final String meetingDay;

  CooperativeStats({
    required this.totalCapital,
    required this.totalMembers,
    required this.totalCredits,
    required this.totalSavings,
    required this.meetingDay,
  });

  factory CooperativeStats.fromJson(Map<String, dynamic> json) {
    return CooperativeStats(
      totalCapital: (json['total_capital'] as num?)?.toDouble() ?? 0.0,
      totalMembers: json['total_members'] ?? 0,
      totalCredits: (json['total_credits'] as num?)?.toDouble() ?? 0.0,
      totalSavings: (json['total_savings'] as num?)?.toDouble() ?? 0.0,
      meetingDay: json['meeting_day'] ?? '',
    );
  }
}
