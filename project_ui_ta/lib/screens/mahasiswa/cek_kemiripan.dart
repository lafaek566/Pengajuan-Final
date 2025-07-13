import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../constants/env.dart'; // pastikan path sesuai struktur proyekmu

class CekKemiripan extends StatefulWidget {
  const CekKemiripan({super.key});

  @override
  State<CekKemiripan> createState() => _CekKemiripanState();
}

class _CekKemiripanState extends State<CekKemiripan> {
  final TextEditingController _controller = TextEditingController();
  bool loading = false;
  String? error;
  List<dynamic> results = [];

  Future<void> handleCheck() async {
    final query = _controller.text.trim();
    if (query.isEmpty) return;

    setState(() {
      loading = true;
      error = null;
      results = [];
    });

    try {
      final res = await http.get(
        Uri.parse(
          '$baseUrl/api/judul/check?q=${Uri.encodeQueryComponent(query)}',
        ),
      );

      if (res.statusCode == 200) {
        setState(() {
          results = jsonDecode(res.body);
        });
      } else {
        setState(() {
          error = "❌ Gagal mengambil data kemiripan";
        });
      }
    } catch (e) {
      setState(() {
        error = "❌ Gagal mengambil data kemiripan";
      });
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget buildResultCard(Map<String, dynamic> item) {
    final judul = item['judul'] ?? '';
    final distance = item['distance']?.toString() ?? '-';
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        title: Text(
          judul,
          style: const TextStyle(
            color: Colors.blue,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text('Jarak kemiripan: $distance'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🔍 Cek Kemiripan Judul Tugas Akhir'),
        backgroundColor: Colors.blue[700],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Contoh: Sistem Informasi Akademik',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                suffixIcon: loading
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : IconButton(
                        icon: const Icon(Icons.search),
                        onPressed: loading ? null : handleCheck,
                        color: Colors.blue[700],
                      ),
              ),
              onSubmitted: (_) => handleCheck(),
            ),
            const SizedBox(height: 20),
            if (error != null)
              Text(
                error!,
                style: const TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            if (results.isNotEmpty) ...[
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '✨ Hasil Kemiripan',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  itemCount: results.length,
                  itemBuilder: (_, i) => buildResultCard(results[i]),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
