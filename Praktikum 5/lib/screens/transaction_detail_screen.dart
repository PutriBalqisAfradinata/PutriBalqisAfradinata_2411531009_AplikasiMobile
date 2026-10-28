import 'package:flutter/material.dart';
import '../database/app_database.dart';
import '../models/transaction_model.dart';
import '../widgets/formatters.dart';

class TransactionDetailScreen extends StatelessWidget {
  const TransactionDetailScreen({super.key, required this.transaction});
  final TransactionModel transaction;

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.isIncome;
    final color = isIncome ? Colors.green.shade700 : const Color(0xFFFFA000);

    return Scaffold(
      
    appBar: AppBar(
      title: const Text('Detail Transaksi'),
      backgroundColor: const Color(0xFFFFA000),
      foregroundColor: Colors.white,
    ),

      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 16),
          CircleAvatar(
            radius: 42,
            backgroundColor: color.withOpacity(0.12),
            child: Icon(isIncome ? Icons.south_west : Icons.north_east, size: 42, color: color),
          ),
          const SizedBox(height: 20),
          Text(transaction.title, textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('${isIncome ? '+' : '-'} ${formatRupiah(transaction.amount)}', textAlign: TextAlign.center,
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(children: [
                _DetailRow(label: 'Jenis transaksi', value: transaction.type),
                const Divider(height: 24),
                _DetailRow(label: 'Kategori', value: transaction.category),
                const Divider(height: 24),
                _DetailRow(label: 'Tanggal', value: formatDate(transaction.date)),
                if (transaction.note.trim().isNotEmpty) ...[
                  const Divider(height: 24),
                  _DetailRow(label: 'Catatan', value: transaction.note),
                ],
              ]),
            ),
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (dialogContext) => AlertDialog(
                  title: const Text('Hapus transaksi?'),
                  content: const Text('Transaksi yang dihapus tidak dapat dikembalikan.'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Batal')),
                    FilledButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('Hapus')),
                  ],
                ),
              );
              if (confirmed != true || transaction.id == null) return;
              await AppDatabase.instance.deleteTransaction(
                transactionId: transaction.id!,
                userId: transaction.userId,
              );
              if (context.mounted) {
                Navigator.pop(context, true);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Transaksi dihapus.')));
              }
            },
            icon: const Icon(Icons.delete_outline),
            label: const Text('Hapus Transaksi'),
            style: OutlinedButton.styleFrom(foregroundColor:const Color(0xFFFFA000)),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 125, child: Text(label, style: TextStyle(color: Colors.grey.shade600))),
          const SizedBox(width: 12),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w600))),
        ],
      );
}
