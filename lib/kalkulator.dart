import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Kalkulator Kabataku'),
        ),
        body: const MyCalculator(),
      ),
    );
  }
}

class MyCalculator extends StatefulWidget {
  const MyCalculator({super.key});

  @override
  State<MyCalculator> createState() => _MyCalculatorState();
}

class _MyCalculatorState extends State<MyCalculator> {
  final _angka1Controller = TextEditingController();
  final _angka2Controller = TextEditingController();

  String hasil = '0';

  void hitung(String operasi) {
    double angka1 = double.tryParse(_angka1Controller.text) ?? 0;
    double angka2 = double.tryParse(_angka2Controller.text) ?? 0;

    double hasilPerhitungan = 0;

    if (operasi == 'kali') {
      hasilPerhitungan = angka1 * angka2;
    } else if (operasi == 'bagi') {
      if (angka2 == 0) {
        setState(() {
          hasil = 'Tidak dapat dibagi 0';
        });
        return;
      }
      hasilPerhitungan = angka1 / angka2;
    } else if (operasi == 'tambah') {
      hasilPerhitungan = angka1 + angka2;
    } else if (operasi == 'kurang') {
      hasilPerhitungan = angka1 - angka2;
    }

    setState(() {
      hasil = hasilPerhitungan.toString();
    });
  }

  @override
  void dispose() {
    _angka1Controller.dispose();
    _angka2Controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Masukkan angka pertama :'),
          const SizedBox(
            height: 10,
          ),
          TextField(
            controller: _angka1Controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Angka pertama',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          const Text('Masukkan angka kedua :'),
          const SizedBox(
            height: 10,
          ),
          TextField(
            controller: _angka2Controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Angka kedua',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              ElevatedButton(
                onPressed: () {
                  hitung('kali');
                },
                child: const Text('Kali'),
              ),
              ElevatedButton(
                onPressed: () {
                  hitung('bagi');
                },
                child: const Text('Bagi'),
              ),
              ElevatedButton(
                onPressed: () {
                  hitung('tambah');
                },
                child: const Text('Tambah'),
              ),
              ElevatedButton(
                onPressed: () {
                  hitung('kurang');
                },
                child: const Text('Kurang'),
              ),
            ],
          ),
          const SizedBox(
            height: 30,
          ),
          Text(
            'Hasil: $hasil',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}