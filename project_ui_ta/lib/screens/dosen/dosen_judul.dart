import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../constants/env.dart'; // pastikan file ini ada dan baseUrl tersedia

class DosenJudul extends StatefulWidget {
  const DosenJudul({super.key});

  @override
  State<DosenJudul> createState() => _DosenJudulState();
}

class _DosenJudulState extends State<DosenJudul> {
  List<dynamic> listJudul = [];
  int currentPage = 1;
  final int itemsPerPage = 5;

  @override
  void initState() {
    super.initState();
    fetchJudul();
  }

  Future<void> fetchJudul() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/judul/with-status'),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        data.sort((a, b) {
          final dateA =
              DateTime.tryParse(a['tgl_ujian'] ?? '') ?? DateTime(1970);
          final dateB =
              DateTime.tryParse(b['tgl_ujian'] ?? '') ?? DateTime(1970);
          return dateB.compareTo(dateA);
        });
        setState(() {
          listJudul = data;
        });
      } else {
        debugPrint("Gagal fetch: ${response.body}");
      }
    } catch (e) {
      debugPrint("Error: $e");
    }
  }

  String formatTanggal(String? tanggal) {
    if (tanggal == null || tanggal.isEmpty) return "-";
    final date = DateTime.tryParse(tanggal);
    if (date == null) return "-";
    return "${date.day.toString().padLeft(2, '0')} "
        "${_bulan(date.month)} ${date.year} "
        "${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
  }

  String _bulan(int month) {
    const bulan = [
      '',
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    return bulan[month];
  }

  Widget getStatusLabel(String? status) {
    switch (status) {
      case 'Y':
        return const Text("✅ Disetujui", style: TextStyle(color: Colors.green));
      case 'T':
        return const Text("❌ Ditolak", style: TextStyle(color: Colors.red));
      default:
        return const Text(
          "⌛ Belum Diproses",
          style: TextStyle(color: Colors.grey),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalPages = (listJudul.length / itemsPerPage).ceil();
    final start = (currentPage - 1) * itemsPerPage;
    final end = (start + itemsPerPage) > listJudul.length
        ? listJudul.length
        : (start + itemsPerPage);
    final paginated = listJudul.sublist(start, end);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Text(
            '📄 Daftar Pengajuan Judul Mahasiswa',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('#')),
                DataColumn(label: Text('NIM')),
                DataColumn(label: Text('Nama')),
                DataColumn(label: Text('Judul')),
                DataColumn(label: Text('Topik')),
                DataColumn(label: Text('Prodi')),
                DataColumn(label: Text('Pembimbing')),
                DataColumn(label: Text('Penguji 1')),
                DataColumn(label: Text('Penguji 2')),
                DataColumn(label: Text('Tahun')),
                DataColumn(label: Text('Tanggal Ujian')),
                DataColumn(label: Text('Status')),
              ],
              rows: paginated.isNotEmpty
                  ? paginated.asMap().entries.map((entry) {
                      final i = entry.key;
                      final item = entry.value;
                      return DataRow(
                        cells: [
                          DataCell(Text('${start + i + 1}')),
                          DataCell(Text(item['nim'] ?? '-')),
                          DataCell(Text(item['nama_mahasiswa'] ?? '-')),
                          DataCell(Text(item['judul_ta'] ?? '-')),
                          DataCell(Text(item['nama_topik'] ?? '-')),
                          DataCell(Text(item['nama_prodi'] ?? '-')),
                          DataCell(Text(item['nama_pembimbing'] ?? '-')),
                          DataCell(Text(item['nama_penguji'] ?? '-')),
                          DataCell(Text(item['nama_penguji2'] ?? '-')),
                          DataCell(Text(item['tahun']?.toString() ?? '-')),
                          DataCell(Text(formatTanggal(item['tgl_ujian']))),
                          DataCell(getStatusLabel(item['status_persetujuan'])),
                        ],
                      );
                    }).toList()
                  : [
                      DataRow(
                        cells: [
                          DataCell(
                            Container(
                              alignment: Alignment.center,
                              padding: const EdgeInsets.all(16),
                              width: MediaQuery.of(context).size.width,
                              child: const Text(
                                "Tidak ada data judul TA.",
                                style: TextStyle(color: Colors.grey),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          ...List.generate(11, (_) => const DataCell(Text(''))),
                        ],
                      ),
                    ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Halaman $currentPage dari $totalPages"),
              Row(
                children: [
                  TextButton(
                    onPressed: currentPage > 1
                        ? () => setState(() => currentPage--)
                        : null,
                    child: const Text('⬅ Prev'),
                  ),
                  TextButton(
                    onPressed: currentPage < totalPages
                        ? () => setState(() => currentPage++)
                        : null,
                    child: const Text('Next ➡'),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
