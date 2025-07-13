// ✅ FLUTTER - dosen_proposal.dart (tanpa tgl_ujian)
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../constants/env.dart'; // baseUrl

class DosenProposal extends StatefulWidget {
  const DosenProposal({super.key});

  @override
  State<DosenProposal> createState() => _DosenProposalState();
}

class _DosenProposalState extends State<DosenProposal> {
  List<dynamic> proposalList = [];
  bool loading = true;
  String errorMsg = '';
  int? selectedId;
  int currentPage = 1;
  final int itemsPerPage = 5;

  @override
  void initState() {
    super.initState();
    fetchProposal();
  }

  Future<void> fetchProposal() async {
    setState(() {
      loading = true;
      errorMsg = '';
    });

    try {
      final response = await http.get(Uri.parse('$baseUrl/api/proposal'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          proposalList = data;
        });
      } else {
        setState(() {
          errorMsg = 'Gagal memuat data proposal.';
        });
      }
    } catch (e) {
      setState(() {
        errorMsg = 'Gagal memuat data proposal.';
      });
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  void handleApprove(int id) {
    selectedId = id;
    submitApproval();
  }

  Future<void> submitApproval() async {
    try {
      await http.put(
        Uri.parse('$baseUrl/api/proposal/status/$selectedId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'status_persetujuan': 'Y',
          'tgl_persetujuan': DateTime.now().toIso8601String().split('T')[0],
        }),
      );
      fetchProposal();
    } catch (e) {
      _showDialog('❌ Gagal menyetujui proposal.');
    }
  }

  Future<void> setStatusReject(int id) async {
    try {
      await http.put(
        Uri.parse('$baseUrl/api/proposal/status/$id'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'status_persetujuan': 'T',
          'tgl_persetujuan': DateTime.now().toIso8601String().split('T')[0],
        }),
      );
      fetchProposal();
    } catch (e) {
      _showDialog('❌ Gagal menolak proposal.');
    }
  }

  String statusText(String? status) {
    if (status == 'Y') return '✅ Disetujui';
    if (status == 'T') return '❌ Ditolak';
    return '⌛ Belum Diproses';
  }

  String formatTanggal(String? tgl) {
    if (tgl == null || tgl.isEmpty) return '-';
    final dtUtc = DateTime.tryParse(tgl)?.toUtc();
    if (dtUtc == null) return '-';

    final dtWib = dtUtc.add(const Duration(hours: 7));

    return '${dtWib.day.toString().padLeft(2, '0')} ${_bulan(dtWib.month)} ${dtWib.year} ${dtWib.hour.toString().padLeft(2, '0')}:${dtWib.minute.toString().padLeft(2, '0')}';
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

  void _showDialog(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Peringatan'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalPages = (proposalList.length / itemsPerPage).ceil();
    final start = (currentPage - 1) * itemsPerPage;
    final end = (start + itemsPerPage > proposalList.length)
        ? proposalList.length
        : start + itemsPerPage;
    final currentData = proposalList.sublist(start, end);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: loading
            ? const Center(child: CircularProgressIndicator())
            : errorMsg.isNotEmpty
            ? Text(errorMsg)
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '📑 Proposal Mahasiswa',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columns: const [
                          DataColumn(label: Text('#')),
                          DataColumn(label: Text('NIM')),
                          DataColumn(label: Text('Nama')),
                          DataColumn(label: Text('Judul')),
                          DataColumn(label: Text('Topik')),
                          DataColumn(label: Text('Tahun')),
                          DataColumn(label: Text('Status')),
                          DataColumn(label: Text('Tgl Ujian')),
                          DataColumn(label: Text('Aksi')),
                        ],
                        rows: currentData.asMap().entries.map((entry) {
                          final i = entry.key;
                          final p = entry.value;
                          return DataRow(
                            cells: [
                              DataCell(Text('${start + i + 1}')),
                              DataCell(Text(p['nim'] ?? '-')),
                              DataCell(Text(p['nama_mahasiswa'] ?? '-')),
                              DataCell(Text(p['judul_ta'] ?? '-')),
                              DataCell(Text(p['nama_topik'] ?? '-')),
                              DataCell(Text(p['tahun']?.toString() ?? '-')),
                              DataCell(
                                Text(statusText(p['status_persetujuan'])),
                              ),
                              DataCell(Text(formatTanggal(p['tgl_ujian']))),
                              DataCell(
                                Row(
                                  children: [
                                    TextButton(
                                      onPressed: () => handleApprove(p['id']),
                                      child: const Text('Setujui'),
                                    ),
                                    TextButton(
                                      onPressed: () => setStatusReject(p['id']),
                                      child: const Text('Tolak'),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Halaman $currentPage dari $totalPages"),
                      Row(
                        children: [
                          TextButton(
                            onPressed: currentPage > 1
                                ? () => setState(() => currentPage -= 1)
                                : null,
                            child: const Text('⬅ Sebelumnya'),
                          ),
                          TextButton(
                            onPressed: currentPage < totalPages
                                ? () => setState(() => currentPage += 1)
                                : null,
                            child: const Text('Berikutnya ➡'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }
}
