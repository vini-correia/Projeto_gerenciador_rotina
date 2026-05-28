class FinanceTransaction {
  final String id;
  final String userId;
  final String title;
  final double amount;
  final String type;
  final DateTime date;

  FinanceTransaction({
    required this.id,
    required this.userId,
    required this.title,
    required this.amount,
    required this.type,
    required this.date,
  });

  factory FinanceTransaction.fromJson(Map<String, dynamic> json) {
    return FinanceTransaction(
      id: json['id'],
      userId: json['user_id'],
      title: json['title'],
      amount: (json['amount'] as num).toDouble(),
      type: json['type'],
      date: DateTime.parse(json['date']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'title': title,
      'amount': amount,
      'type': type,
      'date': date.toIso8601String(),
    };
  }
}