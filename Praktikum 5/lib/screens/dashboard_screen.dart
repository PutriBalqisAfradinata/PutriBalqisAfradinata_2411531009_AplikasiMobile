
import 'package:flutter/material.dart';

import '../database/app_database.dart';
import '../models/app_user.dart';
import '../models/transaction_model.dart';
import '../widgets/formatters.dart';
import '../widgets/transaction_tile.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key, required this.user});

  final AppUser user;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<TransactionModel> _transactions = [];
  bool _loading = true;
  bool _hideBalance = false;

  static const Color primaryYellow = Color(0xFFFFA000);
  static const Color backgroundColor = Color(0xFFF5F7FA);

  int get _income => _transactions
      .where((item) => item.isIncome)
      .fold(0, (sum, item) => sum + item.amount);

  int get _expenses => _transactions
      .where((item) => !item.isIncome)
      .fold(0, (sum, item) => sum + item.amount);

  int get _balance => _income - _expenses;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    try {
      final items = await AppDatabase.instance
          .getTransactions(widget.user.id);

      if (!mounted) return;

      setState(() {
        _transactions = items;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat transaksi: $e')),
      );
    }
  }

  Future<void> _openAddForm() async {
    await Navigator.pushNamed(
      context,
      '/add',
      arguments: widget.user.id,
    );

    await _loadTransactions();
  }

  Future<void> _openDetail(TransactionModel transaction) async {
    await Navigator.pushNamed(
      context,
      '/detail',
      arguments: transaction,
    );

    await _loadTransactions();
  }

  void _showTransferInfo() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Fitur transfer belum tersedia.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final recent = _transactions.take(4).toList();

    return Scaffold(
      backgroundColor: backgroundColor,

      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadTransactions,
          color: primaryYellow,
          child: _loading
              ? const Center(
                  child: CircularProgressIndicator(
                    color: primaryYellow,
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.only(bottom: 100),
                  children: [

                    // HEADER SALDO
                    Container(
                      padding: const EdgeInsets.fromLTRB(
                        24, 24, 24, 28,
                      ),
                      decoration: const BoxDecoration(
                        color: primaryYellow,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(24),
                          bottomRight: Radius.circular(24),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Halo,',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    '${widget.user.name}!',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 21,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),

                              CircleAvatar(
                                radius: 25,
                                backgroundColor:
                                    Colors.white.withOpacity(0.25),
                                child: const Icon(
                                  Icons.person,
                                  color: Colors.white,
                                  size: 28,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 28),

                          const Text(
                            'Saldo Utama',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 15,
                            ),
                          ),

                          const SizedBox(height: 5),

                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  _hideBalance
                                      ? '••••••••'
                                      : formatRupiah(_balance),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 29,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),

                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    _hideBalance = !_hideBalance;
                                  });
                                },
                                icon: Icon(
                                  _hideBalance
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // MENU AKSI
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 22,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: _ActionItem(
                              icon: Icons.arrow_downward,
                              label: 'Pemasukan',
                              color: Colors.green,
                              background: const Color(0xFFFFF3CD),
                              onTap: _openAddForm,
                            ),
                          ),

                          Expanded(
                            child: _ActionItem(
                              icon: Icons.arrow_upward,
                              label: 'Pengeluaran',
                              color: Colors.redAccent,
                              background: const Color(0xFFFFE2E2),
                              onTap: _openAddForm,
                            ),
                          ),

                          Expanded(
                            child: _ActionItem(
                              icon: Icons.swap_horiz,
                              label: 'Transfer',
                              color: Colors.blue,
                              background: const Color(0xFFE0ECFF),
                              onTap: _showTransferInfo,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // RINGKASAN TRANSAKSI
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Ringkasan Keuangan',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 14),

                          Row(
                            children: [
                              Expanded(
                                child: _SummaryCard(
                                  title: 'Pemasukan',
                                  amount: _income,
                                  icon: Icons.south_west,
                                  color: Colors.green,
                                ),
                              ),

                              const SizedBox(width: 12),

                              Expanded(
                                child: _SummaryCard(
                                  title: 'Pengeluaran',
                                  amount: _expenses,
                                  icon: Icons.north_east,
                                  color: Colors.redAccent,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // TRANSAKSI TERBARU
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        20, 26, 20, 10,
                      ),
                      child: Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Transaksi Terakhir',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          IconButton(
                            onPressed: _loadTransactions,
                            icon: const Icon(
                              Icons.refresh,
                              color: primaryYellow,
                            ),
                            tooltip: 'Muat ulang',
                          ),
                        ],
                      ),
                    ),

                    if (recent.isEmpty)
                      Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 20,
                        ),
                        padding: const EdgeInsets.all(25),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.receipt_long,
                              size: 45,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'Belum ada transaksi',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              'Tekan tombol Tambah untuk mencatat transaksi.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      ...recent.map(
                        (item) => Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                          ),
                          child: TransactionTile(
                            transaction: item,
                            onTap: () => _openDetail(item),
                          ),
                        ),
                      ),
                  ],
                ),
        ),
      ),

      // TOMBOL TAMBAH
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddForm,
        backgroundColor: primaryYellow,
        foregroundColor: Colors.white,
        elevation: 3,
        icon: const Icon(Icons.add),
        label: const Text(
          'Tambah',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

// WIDGET MENU AKSI
class _ActionItem extends StatelessWidget {
  const _ActionItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.background,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final Color background;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(
              icon,
              color: color,
              size: 27,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// WIDGET RINGKASAN
class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.title,
    required this.amount,
    required this.icon,
    required this.color,
  });

  final String title;
  final int amount;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: color,
            size: 23,
          ),

          const SizedBox(height: 10),

          Text(
            title,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            formatRupiah(amount),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
