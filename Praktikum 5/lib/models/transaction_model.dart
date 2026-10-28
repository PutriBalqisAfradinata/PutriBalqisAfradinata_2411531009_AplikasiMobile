class TransactionModel {
  const TransactionModel({
    this.id,
    required this.userId,
    required this.title,
    required this.amount,
    required this.type,
    required this.category,
    required this.date,
    this.note = '',
  });

  final int? id;
  final int userId;
  final String title;
  final int amount;
  final String type; // Pemasukan atau Pengeluaran
  final String category;
  final DateTime date;
  final String note;

  bool get isIncome => type == 'Pemasukan';

  Map<String, Object?> toMap() => {
        'id': id,
        'user_id': userId,
        'title': title,
        'amount': amount,
        'type': type,
        'category': category,
        'date': date.toIso8601String(),
        'note': note,
      };

  factory TransactionModel.fromMap(Map<String, Object?> map) => TransactionModel(
        id: map['id'] as int?,
        userId: map['user_id'] as int,
        title: map['title'] as String,
        amount: map['amount'] as int,
        type: map['type'] as String,
        category: map['category'] as String,
        date: DateTime.parse(map['date'] as String),
        note: (map['note'] as String?) ?? '',
      );
}
