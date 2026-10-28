import 'package:flutter/material.dart';
import '../database/app_database.dart';
import '../models/transaction_model.dart';
import '../widgets/formatters.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key, required this.userId});
  final int userId;

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  String _type = 'Pengeluaran';
  String _category = 'Makanan';
  DateTime _selectedDate = DateTime.now();
  bool _saving = false;

  static const Map<String, List<String>> _categories = {
    'Pemasukan': ['Gaji', 'Bonus', 'Hadiah', 'Investasi', 'Lainnya'],
    'Pengeluaran': ['Makanan', 'Transportasi', 'Belanja', 'Tagihan', 'Hiburan', 'Kesehatan', 'Lainnya'],
  };

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _chooseDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (selected != null) setState(() => _selectedDate = selected);
  }

  Future<void> _saveTransaction() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final amount = int.parse(_amountController.text.trim());
      await AppDatabase.instance.insertTransaction(TransactionModel(
        userId: widget.userId,
        title: _titleController.text.trim(),
        amount: amount,
        type: _type,
        category: _category,
        date: _selectedDate,
        note: _noteController.text.trim(),
      ));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Transaksi berhasil disimpan.')));
      Navigator.pop(context, true);
    } catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal menyimpan transaksi: $error')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final availableCategories = _categories[_type]!;
    if (!availableCategories.contains(_category)) _category = availableCategories.first;

    return Scaffold(
      
    appBar: AppBar(
      title: const Text('Tambah Transaksi'),
      backgroundColor: const Color(0xFFFFA000),
      foregroundColor: Colors.white,
    ),

      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const Text('Jenis Transaksi', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 10),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'Pemasukan', label: Text('Pemasukan'), icon: Icon(Icons.south_west)),
                  ButtonSegment(value: 'Pengeluaran', label: Text('Pengeluaran'), icon: Icon(Icons.north_east)),
                ],
                selected: {_type},
                onSelectionChanged: (selection) => setState(() {
                  _type = selection.first;
                  _category = _categories[_type]!.first;
                }),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _titleController,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(labelText: 'Nama transaksi', prefixIcon: Icon(Icons.edit_note)),
                validator: (value) => value == null || value.trim().isEmpty ? 'Nama transaksi wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Nominal (Rupiah)', prefixIcon: Icon(Icons.payments_outlined)),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return 'Nominal wajib diisi';
                  final amount = int.tryParse(value.trim());
                  if (amount == null) return 'Nominal harus berupa angka bulat tanpa titik';
                  if (amount <= 0) return 'Nominal harus lebih dari nol';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _category,
                decoration: const InputDecoration(labelText: 'Kategori', prefixIcon: Icon(Icons.category_outlined)),
                items: availableCategories.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
                onChanged: (value) => setState(() => _category = value ?? availableCategories.first),
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: _chooseDate,
                borderRadius: BorderRadius.circular(12),
                child: InputDecorator(
                  decoration: const InputDecoration(labelText: 'Tanggal transaksi', prefixIcon: Icon(Icons.calendar_month)),
                  child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text(formatDate(_selectedDate)),
                    const Icon(Icons.edit_calendar, size: 20),
                  ]),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _noteController,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Catatan (opsional)', prefixIcon: Icon(Icons.notes), alignLabelWithHint: true),
              ),
              const SizedBox(height: 28),
    
              ElevatedButton.icon(
                onPressed: _saving ? null : _saveTransaction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFA000),
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.save_outlined),
                label: Text(_saving ? 'Menyimpan...' : 'Simpan Transaksi'),
              ),

            ],
          ),
        ),
      ),
    );
  }
}
