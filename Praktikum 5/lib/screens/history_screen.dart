import 'package:flutter/material.dart';
import '../database/app_database.dart';
import '../models/transaction_model.dart';
import '../widgets/transaction_tile.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key, required this.userId});
  final int userId;

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<TransactionModel> _transactions = [];
  bool _loading = true;
  String _filter = 'Semua';

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

Future<void> _loadTransactions() async {
  final items = await AppDatabase.instance
      .getTransactions(widget.userId);

  debugPrint('USER ID RIWAYAT: ${widget.userId}');
  debugPrint('JUMLAH TRANSAKSI RIWAYAT: ${items.length}');
  debugPrint('DATA TRANSAKSI RIWAYAT: ${items.map((e) => e.title).toList()}');

  if (!mounted) return;

  setState(() {
    _transactions = items;
    _loading = false;
  });
}

  Future<void> _openDetail(TransactionModel item) async {
    await Navigator.pushNamed(context, '/detail', arguments: item);
    await _loadTransactions();
  }

  @override
  Widget build(BuildContext context) {
    final visibleItems = _transactions.where((item) {
      if (_filter == 'Pemasukan') return item.isIncome;
      if (_filter == 'Pengeluaran') return !item.isIncome;
      return true;
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat Transaksi'),   backgroundColor: const Color(0xFFFFA000),
  foregroundColor: Colors.white,),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadTransactions,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(value: 'Semua', label: Text('Semua')),
                      ButtonSegment(value: 'Pemasukan', label: Text('Masuk')),
                      ButtonSegment(value: 'Pengeluaran', label: Text('Keluar')),
                    ],
                    selected: {_filter},
                    onSelectionChanged: (selection) => setState(() => _filter = selection.first),
                  ),
                  const SizedBox(height: 16),
                  if (visibleItems.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 64),
                      child: Column(children: [
                        Icon(Icons.history, size: 52, color: Colors.grey.shade400),
                        const SizedBox(height: 12),
                        const Text('Belum ada riwayat transaksi'),
                      ]),
                    )
                  else
                    ...visibleItems.map((item) => TransactionTile(transaction: item, onTap: () => _openDetail(item))),
                ],
              ),
            ),
    );
  }
}
